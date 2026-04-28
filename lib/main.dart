import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  if (!AppConstants.isSupabaseConfigured) {
    runApp(const _ConfigErrorApp(
      message:
          'Supabase non configuré.\n'
          'Lancez avec --dart-define SUPABASE_URL=https://gwowptjimzxyhmynhabv.supabase.co et SUPABASE_ANON_KEY=sb_publishable_zsqvRNUFchpMmNXIPsX_SQ_2Xxyc5IV',
    ));
    return;
  }

  // Initialisation de Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialisation des services GetX (Permanent)
  await Get.putAsync(() => StorageService.init(), permanent: true);
  Get.put(SupabaseService(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);

  runApp(const CashOutApp());
}

class _ConfigErrorApp extends StatelessWidget {
  final String message;

  const _ConfigErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class CashOutApp extends StatelessWidget {
  const CashOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: 'CashOut',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.SPLASH,
        getPages: AppPages.routes,
        initialBinding: InitialBinding(),
        locale: const Locale('fr', 'FR'),
        fallbackLocale: const Locale('fr', 'FR'),
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
