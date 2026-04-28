// ================================
// 📁 lib/core/utils/formatters.dart
// Formateurs pour l'affichage
// ================================

import 'package:intl/intl.dart';
import 'constants.dart';

abstract class Formatters {
  /// Formater un montant en devise FCFA
  /// Ex: 250000 → "250 000 FCFA"
  static String currency(double amount, {int decimalDigits = 0}) {
    final formatter = NumberFormat(
      '#,##0${decimalDigits > 0 ? '.' : ''}${'0' * decimalDigits}',
      AppConstants.locale,
    );
    return '${formatter.format(amount)} ${AppConstants.currency}';
  }

  /// Formater un montant simplifié sans devise
  /// Ex: 1500000 → "1 500 000"
  static String number(double value, {int decimalDigits = 0}) {
    final formatter = NumberFormat(
      '#,##0${decimalDigits > 0 ? '.' : ''}${'0' * decimalDigits}',
      AppConstants.locale,
    );
    return formatter.format(value);
  }

  /// Formater un montant compact
  /// Ex: 1500000 → "1,5M FCFA"
  static String amountCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${AppConstants.currency}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ${AppConstants.currency}';
    }
    return currency(amount);
  }

  /// Formater un pourcentage
  /// Ex: 0.85 → "85%"
  static String percentage(double value, {int decimalDigits = 0}) {
    final formatter = NumberFormat(
      '0${decimalDigits > 0 ? '.' : ''}${'0' * decimalDigits}',
      AppConstants.locale,
    );
    return '${formatter.format(value * 100)}%';
  }

  /// Formater une date longue
  /// Ex: 2024-11-01 → "01 novembre 2024"
  static String date(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy', AppConstants.locale).format(dateTime);
  }

  /// Formater une date courte
  /// Ex: 2024-11-01 → "01/11/2024"
  static String dateShort(DateTime dateTime) {
    return DateFormat(AppConstants.dateFormatDisplay).format(dateTime);
  }

  /// Formater une date et heure
  /// Ex: 2024-11-01 14:30 → "01/11/2024 14:30"
  static String dateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Formater une heure
  /// Ex: 14:30:45 → "14:30"
  static String time(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  /// Formater mois et année
  /// Ex: 2024-11-01 → "novembre 2024"
  static String monthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy', AppConstants.locale).format(dateTime);
  }

  /// Formater un jour et mois
  /// Ex: 2024-11-01 → "01 nov"
  static String dayMonth(DateTime dateTime) {
    return DateFormat('dd MMM', AppConstants.locale).format(dateTime);
  }

  /// Formater relative (il y a X temps)
  /// Ex: 2 heures ago → "Il y a 2 heures"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  /// Formater un téléphone
  /// Ex: "234567890" → "+229 2345 6789"
  static String phone(String number) {
    String cleaned = number.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return number;

    if (cleaned.startsWith('229')) {
      return '+229 ${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
    }
    return number;
  }

  /// Formater un numéro de reçu
  /// Ex: "12345678-abcd-1234" → "12345678"
  static String receiptNumber(String id) {
    if (id.isEmpty) return 'N/A';
    return id.substring(0, 8).toUpperCase();
  }

  /// Formater un IBAN
  /// Ex: "FR1420041010050500013M02" → "FR14 2004 1010 0505 0001 3M02"
  static String iban(String iban) {
    if (iban.isEmpty) return '';
    return iban.replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m.group(0)} ').trim();
  }

  /// Formater un email en masqué
  /// Ex: "user@example.com" → "u***@example.com"
  static String emailMasked(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    if (name.length <= 2) {
      return '${name[0]}***@${parts[1]}';
    }
    return '${name[0]}***${name[name.length - 1]}@${parts[1]}';
  }

  /// Formater un statut
  static String status(String status) {
    return AppConstants.statusLabels[status] ?? status;
  }

  /// Formater un mode de paiement
  static String paymentMethod(String method) {
    return AppConstants.paymentLabels[method] ?? method;
  }

  /// Formater un rôle utilisateur
  static String userRole(String role) {
    return AppConstants.roleLabels[role] ?? role;
  }

  /// Formater une chaîne en capitale (première lettre)
  static String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Formater une chaîne en titre (chaque mot)
  static String titleCase(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Formater une chaîne avec ellipse si trop long
  /// Ex: "Très long texte" (max: 10) → "Très lon..."
  static String ellipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formater un UUID en ID court lisible
  static String shortUuid(String uuid) {
    return uuid.substring(0, 8).toUpperCase();
  }

  /// Formater une taille de fichier
  /// Ex: 1024000 → "1,0 MB"
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Formater un nombre ordinal
  /// Ex: 1 → "1er", 2 → "2e", 21 → "21e"
  static String ordinal(int number) {
    if (number == 1) return '${number}er';
    return '${number}e';
  }

  /// Formater une chaîne en slug
  /// Ex: "Mon Texte" → "mon-texte"
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\-]'), '')
        .replaceAll(RegExp(r'\-+'), '-')
        .replaceAll(RegExp(r'(^\-|\-$)'), '');
  }

  /// Formater une durée
  /// Ex: Duration(hours: 2, minutes: 30) → "2h 30m"
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
