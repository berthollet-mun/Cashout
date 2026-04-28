import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/report_controller.dart';
import '../../../app/themes/app_colors.dart';

class ReportPage extends GetView<ReportController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.chargerRapports(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 32),
              const Text(
                'Répartition par catégorie',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCategoryList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _periodChip('Jour', 'day'),
          _periodChip('Semaine', 'week'),
          _periodChip('Mois', 'month'),
          _periodChip('Année', 'year'),
        ],
      ),
    );
  }

  Widget _periodChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: controller.selectedPeriod == value,
        onSelected: (selected) {
          if (selected) controller.changerPeriode(value);
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: controller.selectedPeriod == value ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final stats = controller.periodStats;
    final total = stats?['total_amount'] ?? 0.0;
    final count = stats?['total_count'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'Total ${_getPeriodLabel()}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${total.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Transactions', count.toString()),
                _buildMiniStat('Période', _getPeriodLabel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (controller.selectedPeriod) {
      case 'day': return 'du Jour';
      case 'week': return 'de la Semaine';
      case 'month': return 'du Mois';
      case 'year': return 'de l\'Année';
      default: return '';
    }
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryList() {
    if (controller.categoryData.isEmpty) {
      return const Center(child: Text('Aucune donnée par catégorie'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.categoryData.length,
      itemBuilder: (context, index) {
        final data = controller.categoryData[index];
        final name = data['name'] ?? 'Inconnu';
        final amount = data['total_amount'] ?? 0.0;
        final percentage = data['percentage'] ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${amount.toStringAsFixed(0)} F', style: const TextStyle(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (percentage as num) / 100,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primary,
                ),
                const SizedBox(height: 4),
                Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }
}
