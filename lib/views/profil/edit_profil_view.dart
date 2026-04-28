import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controllers/profil_controller.dart';
import 'widgets/avatar_widget.dart';

class EditProfilView extends StatefulWidget {
  const EditProfilView({super.key});

  @override
  State<EditProfilView> createState() => _EditProfilViewState();
}

class _EditProfilViewState extends State<EditProfilView> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _posteCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _dirty = false;

  ProfilController get controller => Get.find<ProfilController>();

  @override
  void initState() {
    super.initState();
    final p = controller.profil.value;
    if (p != null) {
      _nomCtrl.text = p.nomComplet;
      _phoneCtrl.text = p.telephone ?? '';
      _addressCtrl.text = p.adresse ?? '';
      _deptCtrl.text = p.departement ?? '';
      _posteCtrl.text = p.poste ?? '';
      _birthDate = p.dateNaissance;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _deptCtrl.dispose();
    _posteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = controller.profil.value;
    if (p == null) {
      return const Scaffold(body: Center(child: Text('Profil indisponible')));
    }
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_dirty) return;
        final confirm = await _confirmExit();
        if (confirm) Get.back();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier profil')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: AvatarWidget(
                  avatarUrl: p.avatarUrl,
                  name: p.nomComplet,
                  onEdit: () => _showAvatarPicker(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Nom invalide' : null,
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Adresse'),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deptCtrl,
                decoration: const InputDecoration(labelText: 'Département'),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _posteCtrl,
                decoration: const InputDecoration(labelText: 'Poste'),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date de naissance'),
                subtitle: Text(_birthDate == null ? 'Non renseignée' : DateFormat('dd/MM/yyyy').format(_birthDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    initialDate: _birthDate ?? DateTime(1995),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthDate = picked;
                      _dirty = true;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : _save,
                  child: controller.isSaving.value
                      ? const CircularProgressIndicator()
                      : const Text('Sauvegarder'),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final current = controller.profil.value!;
    final updated = current.copyWith(
      nomComplet: _nomCtrl.text.trim(),
      telephone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      adresse: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      departement: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      poste: _posteCtrl.text.trim().isEmpty ? null : _posteCtrl.text.trim(),
      dateNaissance: _birthDate,
    );
    await controller.saveProfil(updated);
    _dirty = false;
  }

  Future<bool> _confirmExit() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Quitter sans sauvegarder ?'),
        content: const Text('Vos modifications non sauvegardées seront perdues.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Rester')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Quitter')),
        ],
      ),
    );
    return result ?? false;
  }

  void _showAvatarPicker() {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Get.back();
                controller.pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis galerie'),
              onTap: () {
                Get.back();
                controller.pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
