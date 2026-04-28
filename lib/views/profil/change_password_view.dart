import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profil_controller.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  ProfilController get controller => Get.find<ProfilController>();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mot de passe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Obx(
              () => TextFormField(
                controller: _currentCtrl,
                obscureText: !controller.showCurrentPassword.value,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(controller.showCurrentPassword.value ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => controller.showCurrentPassword.toggle(),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => TextFormField(
                controller: _newCtrl,
                obscureText: !controller.showNewPassword.value,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(controller.showNewPassword.value ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => controller.showNewPassword.toggle(),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.length < 8) ? '8 caractères minimum' : null,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => TextFormField(
                controller: _confirmCtrl,
                obscureText: !controller.showConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: 'Confirmer nouveau mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(controller.showConfirmPassword.value ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => controller.showConfirmPassword.toggle(),
                  ),
                ),
                validator: (v) => v != _newCtrl.text ? 'La confirmation ne correspond pas' : null,
              ),
            ),
            const SizedBox(height: 16),
            _strengthIndicator(),
            const SizedBox(height: 16),
            const Text('Règles: au moins 8 caractères, avec chiffres et lettres.'),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSaving.value ? null : _submit,
                child: controller.isSaving.value
                    ? const CircularProgressIndicator()
                    : const Text('Confirmer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _strengthIndicator() {
    final pwd = _newCtrl.text;
    double strength = 0.0;
    if (pwd.length >= 8) strength += 0.4;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(pwd)) strength += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) strength += 0.2;
    final color = strength < 0.4
        ? Colors.red
        : (strength < 0.8 ? Colors.orange : Colors.green);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Force du mot de passe'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: strength, color: color),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await controller.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
  }
}
