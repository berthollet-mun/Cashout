class ProfilModel {
  final String id;
  final String email;
  final String nomComplet;
  final String role;
  final String? telephone;
  final String? adresse;
  final String? departement;
  final String? poste;
  final DateTime? dateNaissance;
  final DateTime? dateEntree;
  final String? avatarUrl;
  final bool notificationsActives;
  final String langue;
  final double taillePolice;
  final DateTime? derniereConnexion;
  final DateTime createdAt;

  const ProfilModel({
    required this.id,
    required this.email,
    required this.nomComplet,
    required this.role,
    this.telephone,
    this.adresse,
    this.departement,
    this.poste,
    this.dateNaissance,
    this.dateEntree,
    this.avatarUrl,
    this.notificationsActives = true,
    this.langue = 'fr',
    this.taillePolice = 1.0,
    this.derniereConnexion,
    required this.createdAt,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    return ProfilModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      nomComplet: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      telephone: json['phone']?.toString(),
      adresse: json['address']?.toString(),
      departement: json['department']?.toString(),
      poste: json['job_title']?.toString(),
      dateNaissance: parse(json['birth_date']),
      dateEntree: parse(json['hire_date']),
      avatarUrl: json['avatar_url']?.toString(),
      notificationsActives: (json['notifications_enabled'] ?? true) as bool,
      langue: (json['language'] ?? 'fr').toString(),
      taillePolice: (json['font_scale'] as num?)?.toDouble() ?? 1.0,
      derniereConnexion: parse(json['last_login_at']),
      createdAt: parse(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': nomComplet,
      'role': role,
      'phone': telephone,
      'address': adresse,
      'department': departement,
      'job_title': poste,
      'birth_date': dateNaissance?.toIso8601String(),
      'hire_date': dateEntree?.toIso8601String(),
      'avatar_url': avatarUrl,
      'notifications_enabled': notificationsActives,
      'language': langue,
      'font_scale': taillePolice,
      'last_login_at': derniereConnexion?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfilModel copyWith({
    String? nomComplet,
    String? telephone,
    String? adresse,
    String? departement,
    String? poste,
    DateTime? dateNaissance,
    DateTime? dateEntree,
    String? avatarUrl,
    bool? notificationsActives,
    String? langue,
    double? taillePolice,
    DateTime? derniereConnexion,
  }) {
    return ProfilModel(
      id: id,
      email: email,
      nomComplet: nomComplet ?? this.nomComplet,
      role: role,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      departement: departement ?? this.departement,
      poste: poste ?? this.poste,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      dateEntree: dateEntree ?? this.dateEntree,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsActives: notificationsActives ?? this.notificationsActives,
      langue: langue ?? this.langue,
      taillePolice: taillePolice ?? this.taillePolice,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      createdAt: createdAt,
    );
  }
}
