import 'profile_model.dart';
import 'category_model.dart';

class OutflowModel {
  final String id;
  final String? receiptNo;
  final String userId;
  final String? categoryId;
  final double amount;
  final String description;
  final String recipient;
  final String? recipientPhone;
  final String? recipientEmail;
  final String paymentMethod; // 'cash','bank','mobile_money','cheque'
  final String status; // 'pending','validated','rejected','cancelled'
  final String? notes;
  final String? validatedBy;
  final DateTime? validatedAt;
  final String? rejectedReason;
  final DateTime outflowDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final CategoryModel? category;
  final ProfileModel? user;
  final ProfileModel? validator;

  OutflowModel({
    required this.id,
    this.receiptNo,
    required this.userId,
    this.categoryId,
    required this.amount,
    required this.description,
    required this.recipient,
    this.recipientPhone,
    this.recipientEmail,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.validatedBy,
    this.validatedAt,
    this.rejectedReason,
    required this.outflowDate,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.user,
    this.validator,
  });

  factory OutflowModel.fromJson(Map<String, dynamic> json) {
    return OutflowModel(
      id: json['id'],
      receiptNo: json['receipt_no'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      recipient: json['recipient'] ?? '',
      recipientPhone: json['recipient_phone'],
      recipientEmail: json['recipient_email'],
      paymentMethod: json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      validatedBy: json['validated_by'],
      validatedAt: json['validated_at'] != null ? DateTime.parse(json['validated_at']) : null,
      rejectedReason: json['rejected_reason'],
      outflowDate: DateTime.parse(json['outflow_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      category: json['categories'] != null ? CategoryModel.fromJson(json['categories']) : null,
      user: json['profiles'] != null ? ProfileModel.fromJson(json['profiles']) : null,
      validator: json['validator_profile'] != null ? ProfileModel.fromJson(json['validator_profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_no': receiptNo,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'recipient': recipient,
      'recipient_phone': recipientPhone,
      'recipient_email': recipientEmail,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'validated_by': validatedBy,
      'validated_at': validatedAt?.toIso8601String(),
      'rejected_reason': rejectedReason,
      'outflow_date': outflowDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helpers
  bool get isPending => status == 'pending';
  bool get isValidated => status == 'validated';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}
