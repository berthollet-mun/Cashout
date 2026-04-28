import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profil_controller.dart';
import 'widgets/avatar_widget.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = controller.profil.value;
        if (p == null) {
          return const Center(child: Text('Profil introuvable'));
        }

        final createdAt = DateFormat('dd/MM/yyyy').format(p.createdAt);
        final lastLogin = p.derniereConnexion == null
            ? '-'
            : DateFormat('dd/MM/yyyy HH:mm').format(p.derniereConnexion!);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AvatarWidget(
                      avatarUrl: p.avatarUrl,
                      name: p.nomComplet,
                      onEdit: () => Get.toNamed(AppRoutes.EDIT_PROFIL),
                      radius: 42,
                    ),
                    const SizedBox(height: 10),
                    Text(p.nomComplet, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${p.poste ?? 'Poste non défini'} • ${p.departement ?? 'Département non défini'}'),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(p.role.toUpperCase()),
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFIL),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier profil'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Informations personnelles',
              children: [
                _kv('Email', p.email),
                _kv('Téléphone', p.telephone ?? '-'),
                _kv('Date de naissance', p.dateNaissance == null ? '-' : DateFormat('dd/MM/yyyy').format(p.dateNaissance!)),
                _kv('Adresse', p.adresse ?? '-'),
              ],
            ),
            _sectionCard(
              title: 'Informations professionnelles',
              children: [
                _kv('Poste', p.poste ?? '-'),
                _kv('Département', p.departement ?? '-'),
                _kv('Date d\'entrée', p.dateEntree == null ? '-' : DateFormat('dd/MM/yyyy').format(p.dateEntree!)),
                _kv('Permissions', p.role == 'admin' ? 'Toutes' : 'Standard'),
              ],
            ),
            _sectionCard(
              title: 'Statistiques',
              children: [
                _kv('Sorties créées', controller.totalSortiesCreees.toString()),
                _kv('Montants gérés', '${controller.totalMontantsGeres.toStringAsFixed(0)} FCFA'),
                _kv('Dernière connexion', lastLogin),
                _kv('Compte créé le', createdAt),
              ],
            ),
            _sectionCard(
              title: 'Paramètres',
              children: [
                SwitchListTile(
                  value: Get.isDarkMode,
                  onChanged: controller.setDarkMode,
                  title: const Text('Mode sombre'),
                ),
                ListTile(
                  title: const Text('Langue'),
                  trailing: DropdownButton<String>(
                    value: controller.selectedLanguage.value,
                    onChanged: (v) {
                      if (v != null) controller.setLanguage(v);
                    },
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                  ),
                ),
                SwitchListTile(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.setNotifications,
                  title: const Text('Notifications'),
                ),
                ListTile(
                  title: const Text('Taille police'),
                  subtitle: Slider(
                    value: controller.fontScale.value,
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    onChanged: controller.setFontScale,
                  ),
                ),
              ],
            ),
            _sectionCard(
              title: 'Actions',
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Changer mot de passe'),
                  onTap: () => Get.toNamed(AppRoutes.CHANGE_PASSWORD),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Changer avatar'),
                  onTap: () => _showAvatarPicker(),
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Exporter mes données'),
                  onTap: () => Get.snackbar('Info', 'Export lancé'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  onTap: () => AuthController.to.logout(),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(key, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
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
