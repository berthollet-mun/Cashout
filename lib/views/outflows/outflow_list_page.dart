import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/outflow_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';

class OutflowListPage extends GetView<OutflowController> {
  const OutflowListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les Sorties'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une sortie...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => controller.searchOutflows(value),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.outflows.isEmpty) {
          return const Center(
            child: Text('Aucune sortie trouvée'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchOutflows(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.outflows.length,
            itemBuilder: (context, index) {
              final item = controller.outflows[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
                    child: Icon(Icons.money_off, color: _getStatusColor(item.status)),
                  ),
                  title: Text(item.description),
                  subtitle: Text('${item.category?.name ?? 'Sans catégorie'} • ${item.createdAt.toString().substring(0, 16)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.amount.toStringAsFixed(0)} F',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        item.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: _getStatusColor(item.status), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () => Get.toNamed(AppRoutes.OUTFLOW_DETAIL, arguments: item),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.OUTFLOW_FORM),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'validated': return AppColors.success;
      case 'pending': return AppColors.pending;
      case 'rejected': return AppColors.error;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }
}
