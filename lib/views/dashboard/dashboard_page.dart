import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../core/utils/helpers.dart';
import '../shared/widgets/stat_card.dart';
import '../shared/widgets/status_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CashOut Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.PROFIL),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardController.rafraichir(),
        child: Obx(() {
          if (dashboardController.isLoading && dashboardController.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardController.errorMessage.isNotEmpty) {
            return Center(child: Text(dashboardController.errorMessage));
          }

          final profile = authController.profile.value;
          final dash = dashboardController.dashboard;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        profile?.fullName[0] ?? 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${profile?.fullName ?? 'Utilisateur'}',
                          style: AppTextStyles.h3,
                        ),
                        Text(
                          profile?.role.toUpperCase() ?? 'CHARGÉ DE CAISSE',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Validées',
                      value: '${dash?.totalValidated.toInt() ?? 0} F',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    StatCard(
                      title: 'En Attente',
                      value: '${dash?.totalPending.toInt() ?? 0} F',
                      icon: Icons.timer_outlined,
                      color: AppColors.pending,
                    ),
                    StatCard(
                      title: 'Ce mois',
                      value: '${dash?.totalThisMonth.toInt() ?? 0} F',
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),
                    StatCard(
                  title: 'Rejetées',
                  value: '${dash?.totalRejected.toInt() ?? 0} F',
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Actions Rapides', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  icon: Icons.receipt_long,
                  label: 'Reçus',
                  onTap: () => Get.toNamed(AppRoutes.RECEIPTS),
                ),
                const SizedBox(width: 16),
                _buildQuickAction(
                  icon: Icons.bar_chart,
                  label: 'Rapports',
                  onTap: () => Get.toNamed(AppRoutes.REPORTS),
                ),
                const SizedBox(width: 16),
                _buildQuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Nouvelle',
                  onTap: () => Get.toNamed(AppRoutes.OUTFLOW_FORM),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Outflows Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sorties Récentes',
                      style: AppTextStyles.h3,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.OUTFLOW_LIST),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (dashboardController.recentOutflows.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Aucune sortie récente'),
                  ))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardController.recentOutflows.length,
                    itemBuilder: (context, index) {
                      final item = dashboardController.recentOutflows[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: (item.category?.flutterColor ?? AppColors.primary).withOpacity(0.1),
                            child: Icon(
                              Helpers.getIconData(item.category?.icon),
                              color: item.category?.flutterColor ?? AppColors.primary,
                            ),
                          ),
                          title: Text(
                            item.description,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.category?.name ?? 'Sans catégorie', style: AppTextStyles.bodySmall),
                              const SizedBox(height: 4),
                              StatusBadge(status: item.status),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Helpers.formatCurrency(item.amount),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                Helpers.formatDateShort(item.outflowDate),
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          onTap: () => Get.toNamed(AppRoutes.OUTFLOW_DETAIL, arguments: item),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.OUTFLOW_FORM),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
