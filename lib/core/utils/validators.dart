// ================================
// 📁 lib/core/utils/validators.dart
// Validateurs pour formulaires
// ================================

import 'constants.dart';

abstract class Validators {
  /// Valider un email
  /// Retourne null si valide, sinon un message d'erreur
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est obligatoire';
    }
    
    if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    
    return null;
  }

  /// Valider un mot de passe
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }
    
    return null;
  }

  /// Valider la confirmation du mot de passe
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  /// Valider un nom complet
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom complet est obligatoire';
    }
    
    if (value.trim().length < AppConstants.minFullNameLength) {
      return 'Le nom doit contenir au moins ${AppConstants.minFullNameLength} caractères';
    }
    
    if (value.trim().length > AppConstants.maxFullNameLength) {
      return 'Le nom ne peut pas dépasser ${AppConstants.maxFullNameLength} caractères';
    }
    
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$").hasMatch(value)) {
      return 'Le nom ne peut contenir que des lettres et tirets';
    }
    
    return null;
  }

  /// Valider un numéro de téléphone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    if (value.length < AppConstants.minPhoneLength) {
      return 'Le numéro doit contenir au moins ${AppConstants.minPhoneLength} chiffres';
    }
    
    if (!RegExp(r'^\+?[0-9]{9,13}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Veuillez entrer un numéro valide';
    }
    
    return null;
  }

  /// Valider un montant
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le montant est obligatoire';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Veuillez entrer un montant valide';
    }
    
    if (amount < AppConstants.minAmount) {
      return 'Le montant doit être supérieur à ${AppConstants.minAmount}';
    }
    
    if (amount > AppConstants.maxAmount) {
      return 'Le montant dépasse la limite autorisée';
    }
    
    return null;
  }

  /// Valider une description
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description est obligatoire';
    }
    
    if (value.trim().length < 3) {
      return 'La description doit contenir au moins 3 caractères';
    }
    
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'La description ne peut pas dépasser ${AppConstants.maxDescriptionLength} caractères';
    }
    
    return null;
  }

  /// Valider un destinataire
  static String? recipient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le destinataire est obligatoire';
    }
    
    if (value.trim().length < 2) {
      return 'Le destinataire doit contenir au moins 2 caractères';
    }
    
    if (value.length > 100) {
      return 'Le destinataire ne peut pas dépasser 100 caractères';
    }
    
    return null;
  }

  /// Valider une catégorie
  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une catégorie';
    }
    
    return null;
  }

  /// Valider un mode de paiement
  static String? paymentMethod(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner un mode de paiement';
    }
    
    if (!AppConstants.allPaymentMethods.contains(value)) {
      return 'Mode de paiement invalide';
    }
    
    return null;
  }

  /// Valider des notes/commentaires
  static String? notes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    if (value.length > AppConstants.maxNotesLength) {
      return 'Les notes ne peuvent pas dépasser ${AppConstants.maxNotesLength} caractères';
    }
    
    return null;
  }

  /// Valider une raison de rejet
  static String? rejectReason(String? value) {
    if (value == null || value.isEmpty) {
      return 'La raison du rejet est obligatoire';
    }
    
    if (value.trim().length < 3) {
      return 'La raison doit contenir au moins 3 caractères';
    }
    
    if (value.length > AppConstants.maxReasonLength) {
      return 'La raison ne peut pas dépasser ${AppConstants.maxReasonLength} caractères';
    }
    
    return null;
  }

  /// Valider une date
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'La date est obligatoire';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  /// Valider un champ obligatoire générique
  static String? required(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }

  /// Valider une URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    try {
      Uri.parse(value);
      return null;
    } catch (e) {
      return 'URL invalide';
    }
  }

  /// Valider un code IBAN
  static String? iban(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    value = value.toUpperCase().replaceAll(' ', '');
    if (value.length < 15 || value.length > 34) {
      return 'IBAN invalide';
    }
    
    return null;
  }
}
