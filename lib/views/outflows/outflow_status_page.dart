// ================================
// 📁 lib/views/outflows/outflow_status_page.dart
// ================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/outflow_controller.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/outflow_model.dart';
import '../../core/services/pdf_service.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/status_badge.dart';

/// Page dédiée à l'état de sortie — Document officiel
class OutflowStatusPage extends StatelessWidget {
  const OutflowStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OutflowController ctrl    = Get.find<OutflowController>();
    final AuthController    authCtrl = Get.find<AuthController>();
    final OutflowModel      outflow  = Get.arguments as OutflowModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('État de Sortie'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _generatePdf(outflow),
          ),
          IconButton(
            icon:      const Icon(Icons.share_outlined),
            onPressed: () => _sharePdf(outflow),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ── Document officiel ─────────────────
            Container(
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.shadowDark,
                    blurRadius: 12,
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── En-tête document ──────────
                  _buildDocHeader(outflow),

                  // ── Corps document ────────────
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        // Tableau
                        _buildTable(outflow),

                        SizedBox(height: 20.h),

                        // Totaux
                        _buildTotals(outflow),

                        SizedBox(height: 24.h),

                        // Notes
                        if (outflow.notes != null)
                          _buildNotes(outflow),

                        SizedBox(height: 24.h),

                        // Signatures
                        _buildSignatures(outflow, authCtrl),
                      ],
                    ),
                  ),

                  // ── Pied de page ─────────────
                  _buildDocFooter(),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Actions ───────────────────────────
            if (authCtrl.isManagerOrAdmin && outflow.isPending) ...[
              _buildActionButtons(ctrl, outflow),
            ],

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ── En-tête officiel ─────────────────────────────
  Widget _buildDocHeader(OutflowModel outflow) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo société
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CASHOUT SARL',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Système de Gestion de Caisse',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              // Badge statut
              StatusBadge(status: outflow.status),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BON DE SORTIE',
                    style: AppTextStyles.h2.copyWith(color: Colors.white, letterSpacing: 2),
                  ),
                  Text(
                    'N° ${outflow.receiptNo ?? "BROUILLON"}',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                Helpers.formatDate(outflow.outflowDate),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tableau des détails ──────────────────────────
  Widget _buildTable(OutflowModel outflow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableRow('Bénéficiaire', outflow.recipient),
        if (outflow.recipientPhone != null)
          _buildTableRow('Téléphone', outflow.recipientPhone!),
        _buildTableRow('Catégorie', outflow.category?.name ?? 'Non classé'),
        _buildTableRow('Description', outflow.description),
        _buildTableRow('Moyen de Paiement', Helpers.formatPaymentMethod(outflow.paymentMethod)),
      ],
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Totaux ───────────────────────────────────────
  Widget _buildTotals(OutflowModel outflow) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MONTANT TOTAL',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            Helpers.formatCurrency(outflow.amount),
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Notes & Justificatifs ────────────────────────
  Widget _buildNotes(OutflowModel outflow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes / Observations',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          outflow.notes!,
          style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ── Signatures ───────────────────────────────────
  Widget _buildSignatures(OutflowModel outflow, AuthController authCtrl) {
    return Row(
      children: [
        // Émetteur
        Expanded(
          child: Column(
            children: [
              Text('L\'Émetteur', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 40.h),
              Text(outflow.user?.fullName ?? 'Utilisateur', style: AppTextStyles.bodySmall),
              Container(width: 80.w, height: 1, color: Colors.grey[300]),
            ],
          ),
        ),
        // Validateur
        Expanded(
          child: Column(
            children: [
              Text('Le Responsable', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 40.h),
              if (outflow.isValidated)
                Text(outflow.validator?.fullName ?? 'Validé', style: AppTextStyles.bodySmall)
              else if (outflow.isRejected)
                Text('REJETÉ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))
              else
                Text('En attente', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
              Container(width: 80.w, height: 1, color: Colors.grey[300]),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pied de page ─────────────────────────────────
  Widget _buildDocFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Text(
        'Document généré par CashOut App — Fait à Abidjan, le ${Helpers.formatDate(DateTime.now())}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
      ),
    );
  }

  // ── Boutons d'action ─────────────────────────────
  Widget _buildActionButtons(OutflowController ctrl, OutflowModel outflow) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Rejeter',
            isOutlined: true,
            color: AppColors.error,
            onPressed: () => _showRejectDialog(ctrl, outflow),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomButton(
            text: 'Valider',
            onPressed: () => _showConfirmDialog(ctrl, outflow),
          ),
        ),
      ],
    );
  }

  // ── Logique ──────────────────────────────────────
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
          decoration: const InputDecoration(hintText: 'Expliquez pourquoi...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.isEmpty) return;
              Get.back();
              ctrl.updateStatus(outflow.id, 'rejected', reason: reasonCtrl.text);
            },
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _generatePdf(OutflowModel outflow) {
    PdfService.to.generateAndPrintOutflow(outflow);
  }

  void _sharePdf(OutflowModel outflow) {
    PdfService.to.generateAndShareOutflow(outflow);
  }
}
                  