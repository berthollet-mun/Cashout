import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../controllers/outflow_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../core/utils/helpers.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_text_field.dart';

class OutflowFormPage extends StatefulWidget {
  const OutflowFormPage({super.key});

  @override
  State<OutflowFormPage> createState() => _OutflowFormPageState();
}

class _OutflowFormPageState extends State<OutflowFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  String? _selectedCategoryId;
  String _paymentMethod = 'cash';
  
  final controller = Get.find<OutflowController>();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _recipientCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle Sortie'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations de la transaction',
                style: AppTextStyles.h3,
              ),
              Gap(20.h),
              
              // Bénéficiaire
              CustomTextField(
                controller: _recipientCtrl,
                label: 'Bénéficiaire',
                hint: 'Nom de la personne ou entreprise',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              Gap(16.h),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneCtrl,
                      label: 'Téléphone',
                      hint: '07 00 00 00 00',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomTextField(
                      controller: _emailCtrl,
                      label: 'Email (Optionnel)',
                      hint: 'email@exemple.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              
              // Montant
              CustomTextField(
                controller: _amountCtrl,
                label: 'Montant (FCFA)',
                hint: '0',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ requis';
                  if (double.tryParse(val) == null) return 'Montant invalide';
                  return null;
                },
              ),
              Gap(16.h),
              
              // Catégorie
              Obx(() => DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                items: controller.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id, 
                    child: Row(
                      children: [
                        Icon(Helpers.getIconData(cat.icon), color: cat.flutterColor, size: 20),
                        Gap(10.w),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (value) => value == null ? 'Sélectionnez une catégorie' : null,
              )),
              Gap(16.h),

              // Moyen de Paiement
              Text('Moyen de Paiement', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              Gap(8.h),
              _buildPaymentMethods(),
              Gap(16.h),
              
              // Description
              CustomTextField(
                controller: _descriptionCtrl,
                label: 'Description / Motif',
                hint: 'Expliquez l\'objet de la dépense...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              Gap(16.h),

              // Notes
              CustomTextField(
                controller: _notesCtrl,
                label: 'Notes internes (Optionnel)',
                hint: 'Observations particulières...',
                prefixIcon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
              Gap(32.h),
              
              // Submit
              Obx(() => CustomButton(
                text: 'Enregistrer la sortie',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.createOutflow(
                      amount: double.parse(_amountCtrl.text),
                      description: _descriptionCtrl.text,
                      categoryId: _selectedCategoryId!,
                      recipient: _recipientCtrl.text,
                      recipientPhone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
                      recipientEmail: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
                      paymentMethod: _paymentMethod,
                      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                    );
                  }
                },
              )),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'cash', 'label': 'Espèces', 'icon': Icons.money},
      {'id': 'bank', 'label': 'Virement', 'icon': Icons.account_balance},
      {'id': 'mobile_money', 'label': 'Mobile Money', 'icon': Icons.phone_android},
      {'id': 'cheque', 'label': 'Chèque', 'icon': Icons.edit_document},
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: methods.map((m) {
        final isSelected = _paymentMethod == m['id'];
        return GestureDetector(
          onTap: () => setState(() => _paymentMethod = m['id'] as String),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                Gap(6.w),
                Text(
                  m['label'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

