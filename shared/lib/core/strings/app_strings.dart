/// All user-facing copy (assessment §11 + UI labels).
abstract final class AppStrings {
  // App
  static const appNameGuru = 'WTF Guru';
  static const appNameTrainer = 'WTF Trainer';

  // Auth / onboarding
  static const onboardingTitle1 = 'Train with your Guru';
  static const onboardingBody1 =
      'Personal coaching, chat, and HD video — all in one app.';
  static const onboardingTitle2 = 'Chat & video calls';
  static const onboardingBody2 =
      'Powered by 100ms for crystal-clear sessions with your trainer.';
  static const createProfile = 'Create your profile';
  static const almostReady = "You're almost ready, DK";
  static const yourName = 'Your name';
  static const chooseTrainer = 'Choose your trainer';
  static const getStarted = 'Get Started';
  static const next = 'Next';
  static const back = 'Back';
  static const trainerLoginTitle = 'Trainer Login';
  static const trainerLoginSubtitle =
      'Mock login — continue as Aarav (Lead Trainer)';
  static const continueAsAarav = 'Continue as Aarav';
  static const signOut = 'Sign out';
  static const signOutSubtitle = 'Clear session and return to login';
  static const account = 'Account';
  static const workspace = 'Workspace';
  static const reconnectServer = 'Reconnect server';
  static const devTools = 'Developer tools';
  static const serverOfflineBanner =
      'Sync server offline — start token_server on your Mac';
  static const memberBadge = 'Member';

  // Home
  static const quickActions = 'Quick actions';
  static const quickActionsSubtitle = 'Everything you need in one place';
  static const chatWithTrainer = 'Chat with Trainer';
  static const chatWithTrainerSub = 'Message your assigned coach';
  static const scheduleCall = 'Schedule Call';
  static const scheduleCallSub = 'Book a 30-min video session';
  static const mySessions = 'My Sessions';
  static const mySessionsSub = 'Logs, ratings & notes';
  static const coachDashboard = 'Coach Dashboard';
  static const members = 'Members';
  static const chats = 'Chats';
  static const requests = 'Requests';
  static const sessions = 'Sessions';

  // Server
  static const syncOffline = 'Sync server offline';
  static const tapRetryServer = 'Tap to retry — server offline';
  static const retryConnection = 'Retry connection';
  static const connected = 'Connected';

  // Chat (assessment §11)
  static const emptyChatTitle = 'Start the conversation';
  static const emptyChatSubtitle = 'No messages yet. Start the conversation.';
  static const sayHi = 'Say hi 👋';
  static const typeMessage = 'Type a message...';
  static const quickGotIt = 'Got it 👍';
  static const quickTalkAt6 = 'Can we talk at 6?';
  static const quickSharePlan = 'Share plan?';
  static const typing = 'typing...';
  static const online = 'Online';
  static const joinCall = 'Join';
  static const messages = 'Messages';
  static const photoPreview = 'Photo';
  static const downloadPhoto = 'Download';
  static const photoSaved = 'Photo saved — check share / files';
  static const downloadFailed = 'Could not download photo';
  static const newMessages = 'new';

  // Schedule (assessment §11)
  static const requestSent =
      'Call requested. Waiting for trainer approval.';
  static const pickDay = 'Pick a day';
  static const timeSlot = 'Time slot (30 min)';
  static const noteForTrainer = 'Note for trainer';
  static const noteHint = 'e.g. Macros review';
  static const requestCall = 'Request Call';
  static const myRequests = 'My Requests';
  static const pendingApproval = 'Pending approval by Aarav';
  static const pending = 'Pending';
  static const approved = 'Approved';
  static const declined = 'Declined';
  static const approve = 'Approve';
  static const declineReason = 'Decline reason';
  static const noPendingRequests = 'No pending requests';
  static const noRequestsYet = 'No requests yet';
  static const noMembersAssigned = 'No members assigned';
  static const trainerBadge = 'Trainer • Aarav';
  static const close = 'Close';
  static const selectTimeSlot = 'Please select a time slot';

  // Call
  static const deviceCheck = 'Device Check';
  static const readyToJoin = 'Ready to join? Check mic and camera.';
  static const joinCallBtn = 'Join Call';
  static const sessionSaved = 'Session saved to your logs.';
  static const rateSession = 'Rate your session';
  static const markComplete = 'Mark as complete';
  static const roomNotReady = 'Room not ready yet';

  // Sessions
  static const noSessionsTitle = 'No sessions yet';
  static const noSessionsSubtitle = 'Schedule your first call';
  static const filterAll = 'All';
  static const filter7d = 'Last 7 days';
  static const filterMonth = 'This Month';

  // Errors
  static const couldNotSubmit = 'Could not submit request';
  static const couldNotJoin = 'Could not join call';
  static const permissionsRequired =
      'Camera and microphone permissions required';
}
