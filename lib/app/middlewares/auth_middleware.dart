// ================================
// 📁 lib/app/middlewares/auth_middleware.dart
// ================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/app_routes.dart';

/// Middleware d'authentification
/// Redirige vers /login si l'utilisateur n'est pas connecté
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;

    // Si pas de session → redirection vers login
    if (session == null) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null; // OK, continuer
  }
}