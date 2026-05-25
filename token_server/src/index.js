import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { WebSocketServer } from 'ws';
import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_FILE = path.join(__dirname, '../data/store.json');
const UPLOADS_DIR = path.join(__dirname, '../uploads');
const PORT = process.env.PORT || 3000;
const DEV_MODE = process.env.HMS_DEV_MODE !== 'false';

// Seeded users per assessment
const USERS = [
  {
    id: 'trainer_aarav',
    role: 'trainer',
    name: 'Aarav (Lead Trainer)',
    email: 'aarav@wtf.fitness',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aarav',
  },
  {
    id: 'member_dk',
    role: 'member',
    name: 'DK',
    email: 'dk@wtf.fitness',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=DK',
    assignedTrainerId: 'trainer_aarav',
  },
];

let store = loadStore();

function loadStore() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
    }
  } catch (_) {}
  return {
    messages: [],
    callRequests: [],
    rooms: [],
    sessions: [],
  };
}

function saveStore() {
  fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });
  fs.writeFileSync(DATA_FILE, JSON.stringify(store, null, 2));
}

function chatId(a, b) {
  const ids = [a, b].sort();
  return `chat_${ids[0]}_${ids[1]}`;
}

const app = express();
app.use(cors());
app.use(express.json({ limit: '12mb' }));
app.use('/uploads', express.static(UPLOADS_DIR));

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

function broadcast(type, payload) {
  const msg = JSON.stringify({ type, ...payload });
  wss.clients.forEach((c) => {
    if (c.readyState === 1) c.send(msg);
  });
}

app.get('/health', (_, res) => res.json({ ok: true, devMode: DEV_MODE }));

app.get('/api/users', (_, res) => res.json(USERS));

app.get('/api/users/:id', (req, res) => {
  const u = USERS.find((x) => x.id === req.params.id);
  if (!u) return res.status(404).json({ error: 'Not found' });
  res.json(u);
});

app.post('/api/upload/chat-image', (req, res) => {
  const { base64, mime } = req.body || {};
  if (!base64 || typeof base64 !== 'string') {
    return res.status(400).json({ error: 'base64 required' });
  }
  try {
    const buf = Buffer.from(base64, 'base64');
    if (buf.length > 8 * 1024 * 1024) {
      return res.status(413).json({ error: 'Image too large (max 8MB)' });
    }
    const ext = (mime || '').includes('png') ? 'png' : 'jpg';
    const filename = `${uuidv4()}.${ext}`;
    fs.mkdirSync(UPLOADS_DIR, { recursive: true });
    fs.writeFileSync(path.join(UPLOADS_DIR, filename), buf);
    res.json({ url: `/uploads/${filename}` });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/messages', (req, res) => {
  const { chatId } = req.query;
  const list = store.messages
    .filter((m) => m.chatId === chatId)
    .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
  res.json(list);
});

app.post('/api/messages', (req, res) => {
  const msg = { ...req.body, status: 'sent', createdAt: req.body.createdAt || new Date().toISOString() };
  store.messages.push(msg);
  saveStore();
  broadcast('message', { message: msg });
  // Simulate peer typing + read after delay
  setTimeout(() => {
    const idx = store.messages.findIndex((m) => m.id === msg.id);
    if (idx >= 0) {
      store.messages[idx].status = 'read';
      saveStore();
      broadcast('message_read', { chatId: msg.chatId });
    }
  }, 1200);
  res.status(201).json(msg);
});

app.post('/api/messages/read', (req, res) => {
  const { chatId, readerId } = req.body;
  store.messages.forEach((m) => {
    if (m.chatId === chatId && m.receiverId === readerId) m.status = 'read';
  });
  saveStore();
  broadcast('message_read', { chatId });
  res.json({ ok: true });
});

app.get('/api/call-requests', (req, res) => {
  const { userId } = req.query;
  let list = [...store.callRequests];
  if (userId) {
    list = list.filter(
      (r) => r.memberId === userId || r.trainerId === userId
    );
  }
  res.json(list.sort((a, b) => new Date(b.requestedAt) - new Date(a.requestedAt)));
});

app.post('/api/call-requests', (req, res) => {
  const existing = store.callRequests.filter(
    (r) =>
      r.status === 'approved' &&
      r.scheduledFor === req.body.scheduledFor &&
      (r.trainerId === req.body.trainerId || r.memberId === req.body.memberId)
  );
  if (existing.length) {
    return res.status(409).json({ error: 'Slot already booked' });
  }
  const cr = { ...req.body, status: 'pending' };
  store.callRequests.push(cr);
  saveStore();
  broadcast('call_request', { request: cr });
  res.status(201).json(cr);
});

app.patch('/api/call-requests/:id', async (req, res) => {
  const idx = store.callRequests.findIndex((r) => r.id === req.params.id);
  if (idx < 0) return res.status(404).json({ error: 'Not found' });
  const prev = store.callRequests[idx];
  store.callRequests[idx] = {
    ...prev,
    status: req.body.status,
    declineReason: req.body.declineReason,
  };
  const updated = store.callRequests[idx];

  if (req.body.status === 'approved') {
    const roomId = `room_${updated.id}`;
    const roomMeta = {
      id: uuidv4(),
      callRequestId: updated.id,
      hmsRoomId: roomId,
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    };
    store.rooms.push(roomMeta);

    const dk = USERS.find((u) => u.id === updated.memberId);
    const when = new Date(updated.scheduledFor);
    const timeStr = when.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
    const dateStr = when.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const sysMsg = {
      id: uuidv4(),
      chatId: chatId(updated.memberId, updated.trainerId),
      senderId: 'system',
      receiverId: updated.memberId,
      text: `Call approved for ${dateStr} ${timeStr}.`,
      createdAt: new Date().toISOString(),
      status: 'sent',
      isSystem: true,
    };
    store.messages.push(sysMsg);
    saveStore();
    broadcast('call_approved', { request: updated, room: roomMeta });
  }

  if (req.body.status === 'declined') {
    const sysMsg = {
      id: uuidv4(),
      chatId: chatId(updated.memberId, updated.trainerId),
      senderId: 'system',
      receiverId: updated.memberId,
      text: `Call request declined. Reason: ${req.body.declineReason || 'Not available'}`,
      createdAt: new Date().toISOString(),
      status: 'sent',
      isSystem: true,
    };
    store.messages.push(sysMsg);
    saveStore();
  }

  saveStore();
  broadcast('call_request_updated', { request: updated });
  res.json(updated);
});

app.get('/api/rooms', (req, res) => {
  const room = store.rooms.find((r) => r.callRequestId === req.query.callRequestId);
  if (!room) return res.status(404).json({ error: 'No room' });
  res.json(room);
});

app.get('/api/sessions', (req, res) => {
  const { userId } = req.query;
  let list = [...store.sessions];
  if (userId) {
    list = list.filter((s) => s.memberId === userId || s.trainerId === userId);
  }
  res.json(list.sort((a, b) => new Date(b.startedAt) - new Date(a.startedAt)));
});

app.post('/api/sessions', (req, res) => {
  const log = req.body;
  store.sessions.push(log);
  saveStore();
  res.status(201).json(log);
});

app.patch('/api/sessions/:id', (req, res) => {
  const idx = store.sessions.findIndex((s) => s.id === req.params.id);
  if (idx < 0) return res.status(404).json({ error: 'Not found' });
  store.sessions[idx] = { ...store.sessions[idx], ...req.body };
  saveStore();
  res.json(store.sessions[idx]);
});

// 100ms token endpoint
app.get('/token', async (req, res) => {
  const { userId, role, roomId } = req.query;
  if (!userId || !role) {
    return res.status(400).json({ error: 'userId and role required' });
  }

  try {
    if (DEV_MODE) {
      // Dev mock token — apps use HMS dev template or dashboard token in production
      const mockPayload = {
        type: 'app',
        room_id: roomId || 'dev_room_wtf',
        user_id: userId,
        role,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 3600,
      };
      const token = jwt.sign(
        mockPayload,
        process.env.HMS_APP_SECRET || 'dev_secret_wtf_assessment',
        { algorithm: 'HS256' }
      );
      return res.json({ token, devMode: true, roomId: mockPayload.room_id });
    }

    const managementToken = await getManagementToken();
    let hmsRoomId = roomId;
    if (!hmsRoomId) {
      hmsRoomId = await createRoom(managementToken);
    }
    const authToken = await getAuthToken(managementToken, hmsRoomId, userId, role);
    res.json({ token: authToken, roomId: hmsRoomId });
  } catch (e) {
    console.error('[RTC] Token error', e.message);
    res.status(500).json({ error: e.message });
  }
});

async function getManagementToken() {
  const accessKey = process.env.HMS_APP_ACCESS_KEY;
  const secret = process.env.HMS_APP_SECRET;
  const payload = {
    access_key: accessKey,
    type: 'management',
    version: 2,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 300,
    jti: uuidv4(),
  };
  return jwt.sign(payload, secret, { algorithm: 'HS256' });
}

async function createRoom(managementToken) {
  const templateId = process.env.HMS_TEMPLATE_ID;
  const res = await fetch('https://api.100ms.live/v2/rooms', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${managementToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ name: `wtf-${uuidv4().slice(0, 8)}`, template_id: templateId }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Room create failed');
  return data.id;
}

async function getAuthToken(managementToken, roomId, userId, role) {
  const res = await fetch(`https://api.100ms.live/v2/rooms/${roomId}/auth/token`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${managementToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ user_id: userId, role }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Auth token failed');
  return data.token;
}

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(
      `\nPort ${PORT} is already in use. Server is probably already running.\n` +
        `  Check: curl http://localhost:${PORT}/health\n` +
        `  Stop:    lsof -ti :${PORT} | xargs kill\n` +
        `  Or run:  ../scripts/restart_token_server.sh\n`,
    );
    process.exit(1);
  }
  throw err;
});

server.listen(PORT, () => {
  console.log(`WTF sync + token server on http://localhost:${PORT}`);
  console.log(`DEV_MODE=${DEV_MODE} — set HMS_DEV_MODE=false for real 100ms tokens`);
  console.log(`Chat image upload: POST /api/upload/chat-image`);
});
