// ================================
// 📁 lib/core/utils/helpers.dart
// ================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Helpers {
  /// Formater un montant en FCFA
  /// Ex: 250000 → "250 000 FCFA"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} FCFA';
  }

  /// Formater un montant compact
  /// Ex: 1500000 → "1,5M FCFA"
  static String formatAmountCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K FCFA';
    }
    return formatCurrency(amount);
  }

  /// Formater une date longue
  /// Ex: 2024-11-01 → "01 novembre 2024"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formater une date courte
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formater date et heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formater mois et année
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Convertir String date en DateTime
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Libellé lisible du statut
  static String statusLabel(String status) {
    switch (status) {
      case 'pending':   return 'En Attente';
      case 'validated': return 'Validé';
      case 'rejected':  return 'Rejeté';
      case 'cancelled': return 'Annulé';
      default:          return status;
    }
  }

  /// Emoji du statut
  static String statusEmoji(String status) {
    switch (status) {
      case 'pending':   return '⏳';
      case 'validated': return '✅';
      case 'rejected':  return '❌';
      case 'cancelled': return '🚫';
      default:          return '•';
    }
  }

  /// Libellé méthode de paiement
  static String formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':         return 'Espèces';
      case 'bank':         return 'Virement Bancaire';
      case 'mobile_money': return 'Mobile Money';
      case 'cheque':       return 'Chèque';
      default:             return method;
    }
  }

  /// Obtenir l'IconData à partir du nom de l'icône
  static IconData getIconData(String? iconName) {
    switch (iconName) {
      case 'home':           return Icons.home;
      case 'inventory':      return Icons.inventory;
      case 'directions_car': return Icons.directions_car;
      case 'people':         return Icons.people;
      case 'campaign':       return Icons.campaign;
      case 'build':          return Icons.build;
      case 'more_horiz':     return Icons.more_horiz;
      case 'category':       return Icons.category;
      case 'money':          return Icons.money;
      case 'account_balance':return Icons.account_balance;
      case 'smartphone':     return Icons.smartphone;
      case 'payments':       return Icons.payments;
      default:               return Icons.category;
    }
  }

  /// Convertir un nombre en lettres (simplifié)
  static String numberToWords(double amount) {
    // Implémentation basique pour les reçus
    final intAmount = amount.toInt();
    if (intAmount == 0) return 'Zéro franc CFA';
    return '$intAmount francs CFA';
  }

  /// Générer un numéro de référence local
  static String generateLocalRef() {
    return 'TMP-${DateTime.now().millisecondsSinceEpoch}';
  }
}