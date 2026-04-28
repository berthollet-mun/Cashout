import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/outflow_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/etat_sortie_controller.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SupabaseService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(PdfService(), permanent: true);

    // Controllers permanents (accessibles partout, jamais supprimés)
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    
    // Lazy put pour les autres (chargés au besoin et supprimés après)
    Get.lazyPut(() => OutflowController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => ReportController());
    Get.lazyPut(() => EtatSortieController());
  }
}
