import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../data/models/outflow_model.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../controllers/outflow_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/services/pdf_service.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/status_badge.dart';

class OutflowDetailPage extends StatelessWidget {
  const OutflowDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OutflowModel outflow = Get.arguments;
    final controller = Get.find<OutflowController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails de la Sortie'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Header Info
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'N° ${outflow.receiptNo ?? "BROUILLON"}',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Helpers.formatDate(outflow.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      StatusBadge(status: outflow.status),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Bénéficiaire', outflow.recipient),
                  _buildDetailRow('Catégorie', outflow.category?.name ?? 'Non classé'),
                  _buildDetailRow('Description', outflow.description),
                  _buildDetailRow('Moyen de Paiement', Helpers.formatPaymentMethod(outflow.paymentMethod)),
                  if (outflow.notes != null)
                    _buildDetailRow('Notes', outflow.notes!),
                  
                  const Divider(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MONTANT TOTAL', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        Helpers.formatCurrency(outflow.amount),
                        style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Gap(24.h),

            // Logs / Historique (simplifié)
            if (outflow.isValidated || outflow.isRejected)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Historique de validation', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    Gap(12.h),
                    if (outflow.isValidated) ...[
                      _buildHistoryRow(
                        Icons.check_circle, 
                        AppColors.success, 
                        'Validé par ${outflow.validator?.fullName ?? "Admin"}',
                        Helpers.formatDate(outflow.validatedAt ?? DateTime.now()),
                      ),
                    ] else if (outflow.isRejected) ...[
                      _buildHistoryRow(
                        Icons.cancel, 
                        AppColors.error, 
                        'Rejeté par ${outflow.validator?.fullName ?? "Responsable"}',
                        Helpers.formatDate(outflow.updatedAt),
                      ),
                      if (outflow.rejectedReason != null)
                        Padding(
                          padding: EdgeInsets.only(left: 32.w, top: 4.h),
                          child: Text(
                            'Motif : ${outflow.rejectedReason}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

            Gap(32.h),
            
            // Actions pour les managers/admins si en attente
            if (authCtrl.isManagerOrAdmin && outflow.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Rejeter',
                      isOutlined: true,
                      color: AppColors.error,
                      onPressed: () => _showRejectDialog(controller, outflow),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: CustomButton(
                      text: 'Valider',
                      onPressed: () => _showConfirmDialog(controller, outflow),
                    ),
                  ),
                ],
              ),
            ],

            // Action voir le document officiel si validé
            if (outflow.isValidated) ...[
              CustomButton(
                text: 'Voir le Bon de Sortie Officiel',
                isOutlined: true,
                prefixIcon: Icons.description_outlined,
                onPressed: () => Get.toNamed(AppRoutes.OUTFLOW_STATUS, arguments: outflow),
              ),
              Gap(12.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Imprimer',
                      isOutlined: true,
                      prefixIcon: Icons.print,
                      onPressed: () => PdfService.to.generateAndPrintOutflow(outflow),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomButton(
                      text: 'Partager',
                      isOutlined: true,
                      prefixIcon: Icons.share,
                      onPressed: () => PdfService.to.generateAndShareOutflow(outflow),
                    ),
                  ),
                ],
              ),
            ],
            
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(IconData icon, Color color, String title, String date) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall),
              Text(date, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(OutflowController ctrl, OutflowModel outflow) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la validation'),
        content: const Text('Voulez-vous vraiment valider cette sortie de caisse ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.updateStatus(outflow.id, 'validated');
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(OutflowController ctrl, OutflowModel outflow) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Motif du rejet'),
        content: TextField(
          controller: reasonCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Expliquez pourquoi...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.isEmpty) return;
              Get.back();
              ctrl.updateStatus(outflow.id, 'rejected', reason: reasonCtrl.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}

