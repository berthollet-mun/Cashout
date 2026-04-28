// ================================
// 📁 lib/core/utils/constants.dart
// Constantes globales de l'application
// ================================

abstract class AppConstants {
  // --- SUPABASE ─────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gwowptjimzxyhmynhabv.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_zsqvRNUFchpMmNXIPsX_SQ_2Xxyc5IV',
  );

  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project.supabase.co') &&
        !supabaseAnonKey.contains('your-anon-key');
  }

  // --- APP INFO ─────────────────────────────────────
  static const String appName = 'CashOut';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Gestionnaire professionnel de sorties de caisse';

  // --- TIMEOUTS ─────────────────────────────────────
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // --- LIMITES ──────────────────────────────────────
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;
  static const int maxReasonLength = 500;
  static const double minAmount = 0.01;
  static const double maxAmount = 999999999.99;

  // --- REGEX & PATTERNS ─────────────────────────────
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[0-9]{9,13}$';
  static const String amountPattern = r'^\d+(\.\d{1,2})?$';

  // --- STATUTS DE SORTIE ────────────────────────────
  static const String statusPending = 'pending';
  static const String statusValidated = 'validated';
  static const String statusRejected = 'rejected';
  static const String statusCancelled = 'cancelled';

  static const List<String> allStatus = [
    statusPending,
    statusValidated,
    statusRejected,
    statusCancelled,
  ];

  static const Map<String, String> statusLabels = {
    statusPending: 'En attente',
    statusValidated: 'Validée',
    statusRejected: 'Rejetée',
    statusCancelled: 'Annulée',
  };

  // --- MÉTHODES DE PAIEMENT ─────────────────────────
  static const String paymentCash = 'cash';
  static const String paymentBank = 'bank';
  static const String paymentMobileMoney = 'mobile_money';
  static const String paymentCheque = 'cheque';

  static const List<String> allPaymentMethods = [
    paymentCash,
    paymentBank,
    paymentMobileMoney,
    paymentCheque,
  ];

  static const Map<String, String> paymentLabels = {
    paymentCash: 'Espèces',
    paymentBank: 'Virement bancaire',
    paymentMobileMoney: 'Argent mobile',
    paymentCheque: 'Chèque',
  };

  // --- RÔLES UTILISATEUR ────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleUser = 'user';

  static const Map<String, String> roleLabels = {
    roleAdmin: 'Administrateur',
    roleManager: 'Gestionnaire',
    roleUser: 'Utilisateur',
  };

  // --- MONNAIE & LOCALISATION ───────────────────────
  static const String currency = 'FCFA';
  static const String currencyCode = 'XOF';
  static const String locale = 'fr_FR';
  static const String languageCode = 'fr';
  static const String countryCode = 'FR';

  // --- TABLE NAMES (Supabase) ───────────────────────
  static const String tableProfiles = 'profiles';
  static const String tableCategories = 'categories';
  static const String tableOutflows = 'outflows';
  static const String tableOutflowLogs = 'outflow_logs';

  // --- BUDGETS PAR DÉFAUT ───────────────────────────
  static const double defaultMonthlyBudget = 5000000.0; // 5M FCFA
  static const double defaultBudgetThreshold = 0.8; // Alerte à 80%

  // --- FORMATS ──────────────────────────────────────
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatAPI = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // --- PAGES SPACING ────────────────────────────────
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // --- BORDER RADIUS ────────────────────────────────
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // --- ICON SIZES ───────────────────────────────────
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // --- MESSAGES ─────────────────────────────────────
  static const String msgErrorDefault = 'Une erreur est survenue. Veuillez réessayer.';
  static const String msgErrorNetwork = 'Erreur de connexion. Vérifiez votre réseau.';
  static const String msgErrorAuth = 'Authentification requise.';
  static const String msgSuccessOperation = 'Opération réussie';
  static const String msgLoadingData = 'Chargement en cours...';
  static const String msgNoData = 'Aucune donnée disponible';
  static const String msgEmptyList = 'Liste vide';

  // --- DURATIONS ANIMATIONS ─────────────────────────
  static const Duration animationDurationShort = Duration(milliseconds: 300);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 800);

  // --- VALIDATIONS ──────────────────────────────────
  static const int minPasswordLength = 6;
  static const int minFullNameLength = 2;
  static const int maxFullNameLength = 100;
  static const int minPhoneLength = 9;
}

// ── ÉNUMÉRATIONS ──────────────────────────────────────
enum OutflowStatus { pending, validated, rejected, cancelled }

enum PaymentMethod { cash, bank, mobileMoney, cheque }

enum UserRole { admin, manager, user }
