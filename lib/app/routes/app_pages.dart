import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/report_binding.dart';
import '../bindings/outflow_binding.dart';
import '../bindings/profil_binding.dart';
import '../../controllers/dashboard_controller.dart';
import '../../views/splash/splash_page.dart';
import '../../views/auth/login/login_page.dart';
import '../../views/auth/register/register_page.dart';
import '../../views/dashboard/dashboard_page.dart';
import '../../views/outflows/outflow_list_page.dart';
import '../../views/outflows/outflow_form_page.dart';
import '../../views/outflows/outflow_detail_page.dart';
import '../../views/outflows/outflow_status_page.dart';
import '../../views/outflows/etat_sortie_page.dart';
import '../../views/reports/report_page.dart';
import '../../views/receipts/receipt_page.dart';
import '../../views/profil/profil_view.dart';
import '../../views/profil/edit_profil_view.dart';
import '../../views/profil/change_password_view.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.OUTFLOW_LIST,
      page: () => const OutflowListPage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.OUTFLOW_FORM,
      page: () => const OutflowFormPage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.OUTFLOW_DETAIL,
      page: () => const OutflowDetailPage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.OUTFLOW_STATUS,
      page: () => const OutflowStatusPage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.ETAT_SORTIE,
      page: () => EtatSortiePage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => const ReportPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.RECEIPTS,
      page: () => const ReceiptPage(),
      binding: OutflowBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFIL,
      page: () => const EditProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: AppRoutes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ProfilBinding(),
    ),
  ];
}
