/// All user-facing static strings.
/// For multi-language support, migrate to l10n/ ARB files.
class AppStrings {
  AppStrings._();

  // ── App Info ───────────────────────────────────────────────────────
  static const String appName       = 'Therapy Nest';
  static const String appTagline    = 'Your daily practice companion for recovery';

  // ── Auth ───────────────────────────────────────────────────────────
  static const String signIn        = 'Sign In';
  static const String signUp        = 'Create Account';
  static const String signOut       = 'Sign Out';
  static const String email         = 'Email';
  static const String password      = 'Password';
  static const String confirmPass   = 'Confirm Password';
  static const String fullName      = 'Full Name';
  static const String forgotPass    = 'Forgot password?';
  static const String noAccount     = "Don't have an account? ";
  static const String haveAccount   = 'Already have an account? ';
  static const String register      = 'Register';
  static const String login         = 'Log in';
  static const String googleSignIn  = 'Continue with Google';
  static const String resetPassword = 'Reset Password';
  static const String resetSent     = 'Password reset email sent';
  static const String termsAgree    = 'I agree to the Terms of Service';
  static const String disclaimer    = 'Therapy Nest is a practice companion, not a replacement for professional therapy.';

  // ── Onboarding ─────────────────────────────────────────────────────
  static const String onboardingConditionTitle   = 'What best describes your situation?';
  static const String onboardingSeverityTitle     = 'How would you describe your current challenges?';
  static const String onboardingGoalsTitle        = 'What do you most want to improve?';
  static const String onboardingScheduleTitle     = 'Set your practice schedule';
  static const String onboardingWelcomeTitle      = 'Your personalized plan is ready!';
  static const String onboardingNext              = 'Next';
  static const String onboardingBack              = 'Back';
  static const String onboardingStart             = 'Start your first session';
  static const String onboardingSkip              = 'Skip for now';

  // ── Common ─────────────────────────────────────────────────────────
  static const String retry         = 'Retry';
  static const String cancel        = 'Cancel';
  static const String save          = 'Save';
  static const String done          = 'Done';
  static const String loading       = 'Loading...';
  static const String noData        = 'No data available';
  static const String error         = 'Something went wrong';
  static const String noInternet    = 'No internet connection';
  static const String sessionExpired = 'Session expired. Please sign in again.';

  // ── Validation ─────────────────────────────────────────────────────
  static const String fieldRequired       = 'This field is required';
  static const String invalidEmail        = 'Please enter a valid email';
  static const String passwordTooShort    = 'Password must be at least 8 characters';
  static const String passwordsMismatch   = 'Passwords do not match';
  static const String acceptTerms         = 'You must accept the Terms of Service';

  // ── Baseline Assessment ─────────────────────────────────────────────
  static const String assessmentTitle          = 'Baseline Assessment';
  static const String assessmentIntroTitle     = 'Let\'s Get to Know You';
  static const String assessmentIntroBody      = 'This short assessment helps us understand your current abilities so we can personalize your therapy exercises.';
  static const String assessmentIntroTime      = 'Takes about 10 minutes';
  static const String assessmentIntroStart     = 'Begin Assessment';
  static const String assessmentIntroSkip      = 'Skip for now';

  // Domain names
  static const String domainLanguage           = 'Language';
  static const String domainReadingWriting     = 'Reading & Writing';
  static const String domainMemory             = 'Memory';
  static const String domainAttention          = 'Attention';
  static const String domainSpeech             = 'Speech';
  static const String domainMath               = 'Math';

  // Domain descriptions
  static const String domainLanguageDesc       = 'Picture naming — select the correct word';
  static const String domainReadingWritingDesc = 'Read words, sentences, and real-world text';
  static const String domainMemoryDesc         = 'Remember the sequence of shapes';
  static const String domainAttentionDesc      = 'Find the target symbols in the grid';
  static const String domainSpeechDesc         = 'Repeat the word you hear';
  static const String domainMathDesc           = 'Numbers and simple calculations';

  // Exercise instructions
  static const String assessmentSelectAnswer   = 'Select your answer';
  static const String assessmentListenTap      = 'Listen, then tap the correct answer';
  static const String assessmentRememberSeq    = 'Remember this sequence';
  static const String assessmentFindTarget     = 'Tap all the targets';
  static const String assessmentRepeatWord     = 'Repeat the word';
  static const String assessmentSolve          = 'Select the correct answer';
  static const String assessmentSkipDomain     = 'Skip this section';
  static const String assessmentReplayAudio    = 'Replay audio';
  static const String assessmentNext           = 'Next';

  // Encouragement
  static const String assessmentGreatJob       = 'Great job!';
  static const String assessmentKeepGoing      = 'Keep going — you\'re doing well!';
  static const String assessmentAlmostDone     = 'Almost done!';
  static const String assessmentNiceTry        = 'Nice try!';
  static const String assessmentDomainDone     = 'Section complete!';

  // Completion
  static const String assessmentCompleteTitle  = 'Assessment Complete!';
  static const String assessmentCompleteBody   = 'Great work! Your personalized therapy plan is now ready.';
  static const String assessmentCompleteAction = 'Continue to Home';
  static const String assessmentYourResults    = 'Your Results';
  static const String assessmentSpeechSkipped  = 'Speech section skipped — you can take it later in Settings.';

  // ── Therapy Session ─────────────────────────────────────────────────
  static const String therapyDomainSelectTitle   = 'Choose Your Domains';
  static const String therapyDomainSelectBody    = 'Select one or more areas to practice today.';
  static const String therapyStartSession        = 'Start Session';
  static const String therapyNeedHint            = 'Need a hint?';
  static const String therapyAllHintsUsed        = 'All hints used';
  static const String therapySkip                = 'Skip';

  // Feedback
  static const String therapyCorrect             = 'Great job!';
  static const String therapyTryAgain            = "Let's try that again";
  static const String therapyStreakMilestone      = 'in a row!';

  // Session Results
  static const String therapyResultGreat         = 'Amazing Work! 🎉';
  static const String therapyResultGood          = 'Great Effort! ⭐';
  static const String therapyResultKeepGoing     = 'Keep Going! 💪';
  static const String therapySessionMotivational = 'Every session builds your strength. Consistency is the key to progress!';
  static const String therapyContinuePracticing  = 'Continue Practicing';
  static const String therapyGoHome              = 'Go Home';
  static const String therapyAbilityChanges      = 'Ability Changes';

  // ── Home Dashboard ──────────────────────────────────────────────────
  static const String homeGreetingMorning         = 'Good morning';
  static const String homeGreetingAfternoon       = 'Good afternoon';
  static const String homeGreetingEvening          = 'Good evening';
  static const String homeStreakPrefix             = '🔥';
  static const String homeStreakSuffix             = '-day streak!';
  static const String homeTodaysGoal               = "Today's Goal";
  static const String homeEstimatedTime            = 'Estimated time';
  static const String homeStartSession             = 'Start Today\'s Session';
  static const String homeDomainSummary            = 'Your Domains';
  static const String homeRecentActivity           = 'Recent Activity';
  static const String homeTipOfDay                 = 'Tip of the Day';
  static const String homeNoSessionsYet            = 'Complete your first session to see your progress!';

  // ── Progress Screen ──────────────────────────────────────────────────
  static const String progressTitle                = 'Your Progress';
  static const String progressAbilityOverview      = 'Ability Overview';
  static const String progressWeeklyPractice       = 'Weekly Practice';
  static const String progressAccuracyTrend        = 'Accuracy Trend';
  static const String progressMilestones           = 'Recovery Milestones';
  static const String progressSessionHistory       = 'Session History';
  static const String progressMinutes              = 'min';
  static const String progressSessions             = 'sessions';
  static const String progressAccuracy             = 'accuracy';
  static const String progressTargetLine           = 'Daily target';
  static const String progressInitialBaseline      = 'Baseline';
  static const String progressCurrentAbility       = 'Current';
  static const String progressNoData               = 'Complete your first session to see your progress!';

  // ── Domain Detail ────────────────────────────────────────────────────
  static const String domainDetailTitle             = 'Domain Detail';
  static const String domainDetailHistory           = 'Ability History';
  static const String domainDetailAccuracyBreakdown = 'Accuracy by Exercise Type';
  static const String domainDetailRecommended       = 'Recommended Focus';
  static const String domainDetailKeepGoing         = 'Still building this skill — keep going!';
  static const String domainDetailGreatProgress     = 'Great progress in this area!';

  // ── Achievements ─────────────────────────────────────────────────────
  static const String achievementsTitle             = 'Achievements';
  static const String achievementsUnlocked          = 'Unlocked!';
  static const String achievementsLocked            = 'Keep practicing to unlock';
  static const String achievementsNextMilestone     = 'Next milestone';

  // ── Milestones ───────────────────────────────────────────────────────
  static const String milestoneAchieved             = '✓';
  static const String milestoneProgress             = 'Progress to next milestone';
  static const String milestoneEstimated            = 'Estimated';

  // ── Encouragement (positive framing only) ────────────────────────────
  static const String encourageEverySession         = 'Every session counts, no matter how short';
  static const String encourageGreatPractice        = 'Great practice!';
  static const String encourageKeepBuilding         = 'Still building this skill — keep going!';
  static const String encourageHoldingSteady        = 'Holding steady';

  // ── Navigation ───────────────────────────────────────────────────────
  static const String navHome                       = 'Home';
  static const String navProgress                   = 'Progress';
  static const String navSettings                   = 'Settings';

  // ── Settings — Main ────────────────────────────────────────────────
  static const String settingsTitle                 = 'Settings';
  static const String settingsProfile               = 'Profile';
  static const String settingsAccessibility         = 'Accessibility';
  static const String settingsNotifications         = 'Notifications';
  static const String settingsAbout                 = 'About & Legal';
  static const String settingsSignOut               = 'Sign Out';
  static const String settingsSignOutConfirm        = 'Are you sure you want to sign out?';
  static const String settingsSignOutConfirmTitle    = 'Sign Out';

  // ── Settings — Accessibility ───────────────────────────────────────
  static const String a11yTitle                     = 'Accessibility';
  static const String a11yTextSize                  = 'Text Size';
  static const String a11yTextSizeDesc              = 'Adjust the size of all text in the app';
  static const String a11yHighContrast              = 'High Contrast Mode';
  static const String a11yHighContrastDesc          = 'Increases colour contrast to 7:1 ratios for improved readability';
  static const String a11yTtsSpeed                  = 'TTS Speed';
  static const String a11yTtsSpeedDesc              = 'Adjust text-to-speech playback speed';
  static const String a11yTtsTest                   = 'Test';
  static const String a11yTouchTarget               = 'Touch Target Size';
  static const String a11yTouchTargetDesc           = 'Make buttons and interactive elements larger';
  static const String a11yReduceMotion              = 'Reduce Motion';
  static const String a11yReduceMotionDesc          = 'Minimise animations for vestibular comfort';
  static const String a11yVoiceInput                = 'Voice Input Mode';
  static const String a11yVoiceInputDesc            = 'Adds a microphone button to all exercises';
  static const String a11yPreview                   = 'Preview';

  // ── Settings — Notifications ───────────────────────────────────────
  static const String notifTitle                    = 'Notifications';
  static const String notifDailyReminder            = 'Daily Reminder';
  static const String notifDailyReminderDesc        = 'Get a daily push to start your practice';
  static const String notifReminderTime             = 'Reminder Time';
  static const String notifMilestone                = 'Milestone Notifications';
  static const String notifMilestoneDesc            = 'Celebrate when you hit a new milestone';
  static const String notifWeeklySummary            = 'Weekly Summary';
  static const String notifWeeklySummaryDesc        = 'Receive a progress recap every Sunday evening';
  static const String notifInactivity               = 'Inactivity Reminder';
  static const String notifInactivityDesc           = 'Gentle nudge after 3 days without a session';

  // ── Notification Body Text (PHI-free) ────────────────────────────
  static const String notifDailyBody       = "Time for your daily therapy practice! 🧠 Just 15 minutes makes a difference.";
  static const String notifMilestoneBody   = '🎉 New milestone!';
  static const String notifWeeklyBody      = '📈 Your weekly progress summary is ready!';
  static const String notifInactivityBody  = 'Missing you! Your practice is ready when you are.';

  // ── Gamification ─────────────────────────────────────────────────
  static const String achievementUnlockedTitle = 'Achievement Unlocked! 🏆';
  static const String achievementTapToDismiss  = 'Tap to continue';

  // ── Settings — Profile ─────────────────────────────────────────────
  static const String profileTitle                  = 'Profile';
  static const String profileUpdateName             = 'Full Name';
  static const String profileGoals                  = 'Practice Goals';
  static const String profileSchedule               = 'Practice Schedule';
  static const String profileDownloadData           = 'Download My Data';
  static const String profileDownloadDataDesc       = 'Request a copy of all your data (GDPR)';
  static const String profileDeleteAccount          = 'Delete Account';
  static const String profileDeleteConfirmTitle     = 'Delete Account?';
  static const String profileDeleteConfirmBody      = 'This will permanently delete your account and all associated data. This action cannot be undone.';
  static const String profileDeleteConfirmButton    = 'Yes, Delete My Account';
  static const String profileDeleteSecondTitle      = 'Are you absolutely sure?';
  static const String profileDeleteSecondBody       = 'Type DELETE to confirm permanent deletion of your account.';
  static const String profileSaved                  = 'Profile updated';

  // ── Settings — About & Legal ───────────────────────────────────────
  static const String aboutTitle                    = 'About & Legal';
  static const String aboutAppVersion               = 'App Version';
  static const String aboutOpenSource               = 'Open Source Acknowledgments';
  static const String aboutPrivacyPolicy            = 'Privacy Policy';
  static const String aboutTermsOfService           = 'Terms of Service';
  static const String aboutResearchConsent          = 'Research Consent';
  static const String aboutResearchConsentDesc      = 'Allow anonymised usage data for research';
  static const String aboutMedicalDisclaimer        = 'Medical Disclaimer';
  static const String medicalDisclaimerText         =
      'Therapy Nest is a self-guided practice companion designed to support '
      'home practice for adults with speech, language, and cognitive challenges. '
      'It is not a medical device, does not provide diagnosis, and is not a '
      'replacement for professional speech-language or occupational therapy. '
      'Always follow the advice of your healthcare team.';
}
