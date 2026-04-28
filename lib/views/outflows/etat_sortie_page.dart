// ================================
// 📁 lib/views/outflows/etat_sortie_page.dart
// Affichage professionnel de l'État de Sortie
// ================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/etat_sortie_controller.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/constants.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/status_badge.dart';

class EtatSortiePage extends GetView<EtatSortieController> {
  final String outflowId = Get.arguments ?? '';

  EtatSortiePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (outflowId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('État de Sortie')),
        body: const Center(child: Text('Erreur: Pas de sortie spécifiée')),
      );
    }

    // Charger la sortie au démarrage
    controller.chargerOutflow(outflowId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('État de Sortie'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }

        if (controller.outflow == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(controller.errorMessage.isEmpty
                    ? 'Sortie non trouvée'
                    : controller.errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          );
        }

        final outflow = controller.outflow!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête document
              Center(
                child: Column(
                  children: [
                    Text(
                      'CASHOUT',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Text(
                      'État de Sortie de Caisse',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 24),

              // Section infos émetteur/récepteur
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÉMETTEUR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          outflow.user?.fullName ?? 'N/A',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(outflow.user?.email ?? ''),
                        if (outflow.user?.phone != null)
                          Text(outflow.user!.phone!),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RÉCEPTEUR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          outflow.recipient,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (outflow.recipientEmail != null) Text(outflow.recipientEmail!),
                        if (outflow.recipientPhone != null) Text(outflow.recipientPhone!),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 24),

              // Détails document
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('N° de Reçu', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      Text(
                        outflow.receiptNo?.toUpperCase() ?? outflow.id.substring(0, 8).toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Date', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      Text(
                        Formatters.dateTime(outflow.outflowDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 24),

              // Détails de la sortie
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Description', outflow.description),
                      const SizedBox(height: 12),
                      _buildDetailRow('Catégorie', outflow.category?.name ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Mode de paiement', Formatters.paymentMethod(outflow.paymentMethod)),
                      const SizedBox(height: 12),
                      if (outflow.notes != null && outflow.notes!.isNotEmpty)
                        _buildDetailRow('Notes', outflow.notes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Montant
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MONTANT TOTAL',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        Formatters.currency(outflow.amount),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statut
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getStatusColor(outflow.status),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statut',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        StatusBadge(status: outflow.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (outflow.validatedBy != null) ...[
                      Text('Validé par: ${outflow.validator?.fullName ?? 'N/A'}'),
                      if (outflow.validatedAt != null)
                        Text('Le ${Formatters.dateTime(outflow.validatedAt!)}'),
                    ],
                    if (outflow.status == 'rejected' && outflow.rejectedReason != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raison du rejet',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              outflow.rejectedReason!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Imprimer',
                      icon: Icons.print,
                      isLoading: controller.isLoading,
                      onPressed: controller.imprimer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Partager',
                      icon: Icons.share,
                      isLoading: controller.isLoading,
                      onPressed: controller.partager,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Télécharger',
                      icon: Icons.download,
                      isLoading: controller.isLoading,
                      onPressed: controller.telecharger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'validated':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
