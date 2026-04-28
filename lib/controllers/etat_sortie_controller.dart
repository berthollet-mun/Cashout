// ================================
// 📁 lib/controllers/etat_sortie_controller.dart
// Contrôleur pour l'État de Sortie (Document professionnel)
// ================================

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/services/pdf_service.dart';
import '../core/services/supabase_service.dart';
import '../data/models/outflow_model.dart';

class EtatSortieController extends GetxController {
  final _pdfService = PdfService.to;
  final _supabase = SupabaseService.to;

  // ── Variables observables ─────────────────────────
  final _outflow = Rxn<OutflowModel>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // ── Getters ───────────────────────────────────────
  OutflowModel? get outflow => _outflow.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Charger une sortie pour afficher son État
  Future<void> chargerOutflow(String outflowId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final data = await _supabase.getOutflows();
      final found = data.firstWhereOpt((e) => e['id'] == outflowId);

      if (found != null) {
        _outflow.value = OutflowModel.fromJson(found);
      } else {
        _errorMessage.value = 'Sortie non trouvée';
        Get.snackbar('Erreur', 'Sortie non trouvée');
      }
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement';
      Get.snackbar('Erreur', 'Impossible de charger la sortie');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Générer le PDF de l'État de Sortie
  Future<pw.Document> genererPDF() async {
    if (_outflow.value == null) {
      throw Exception('Aucune sortie sélectionnée');
    }

    final pdf = pw.Document();
    final outflow = _outflow.value!;

    // Couleurs
    final headerColor = PdfColor.fromInt(0xFF2980B9); // Bleu
    final accentColor = PdfColor.fromInt(0xFF34495E);   // Gris fonce
    final rejectColor = PdfColor.fromInt(0xFFE74C3C);   // Rouge

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── EN-TÊTE PROFESSIONNELLE ──────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CASHOUT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      pw.Text(
                        'Gestionnaire de Sorties de Caisse',
                        style: pw.TextStyle(fontSize: 10, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'ÉTAT DE SORTIE',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      pw.Text(
                        'Reçu N° ${outflow.receiptNo?.toUpperCase() ?? outflow.id.substring(0, 8).toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ─── SÉPARATEUR ───────────────────
              pw.Divider(color: headerColor),
              pw.SizedBox(height: 20),

              // ─── SECTION INFORMATIONS ─────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date', pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                      pw.Text(
                        _formatDate(outflow.outflowDate),
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 10),
                      _buildLabel('Émetteur', pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                      pw.Text(
                        outflow.user?.fullName ?? 'N/A',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.Text(
                        outflow.user?.email ?? '',
                        style: pw.TextStyle(fontSize: 9, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildLabel('Destinataire', pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                      pw.Text(
                        outflow.recipient,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      if (outflow.recipientEmail != null)
                        pw.Text(
                          outflow.recipientEmail!,
                          style: pw.TextStyle(fontSize: 9, color: accentColor),
                        ),
                      if (outflow.recipientPhone != null)
                        pw.Text(
                          outflow.recipientPhone!,
                          style: pw.TextStyle(fontSize: 9, color: accentColor),
                        ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ─── TABLEAU DÉTAILS ──────────────
              pw.Table(
                border: pw.TableBorder.all(color: headerColor, width: 1),
                children: [
                  // En-tête
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFE6F0FF)),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: headerColor)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Montant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: headerColor)),
                      ),
                    ],
                  ),
                  // Données
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(outflow.description, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Catégorie: ${outflow.category?.name ?? 'N/A'}', style: pw.TextStyle(fontSize: 9, color: accentColor)),
                            pw.Text('Méthode: ${_formatPaymentMethod(outflow.paymentMethod)}', style: const pw.TextStyle(fontSize: 9)),
                            if (outflow.notes != null && outflow.notes!.isNotEmpty)
                              pw.Text('Notes: ${outflow.notes}', style: pw.TextStyle(fontSize: 8, color: accentColor)),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _formatAmount(outflow.amount),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: headerColor,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ─── TOTAL ────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.SizedBox(width: 40),
                          pw.Text(
                            _formatAmount(outflow.amount),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: headerColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // ─── STATUT ───────────────────────
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _getStatusColor(outflow.status)),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Statut:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          _formatStatus(outflow.status),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: _getStatusColor(outflow.status),
                          ),
                        ),
                      ],
                    ),
                    if (outflow.validatedBy != null)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Validé par:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(outflow.validator?.fullName ?? 'N/A', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                  ],
                ),
              ),
              
              if (outflow.status == 'rejected' && outflow.rejectedReason != null) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: rejectColor),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Raison du rejet:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: rejectColor)),
                      pw.Text(outflow.rejectedReason!, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // ─── SIGNATURES & FOOTER ──────────
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Signature Émetteur', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Container(height: 1, width: 80),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Signature Récepteur', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Container(height: 1, width: 80),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Cachet/Tampon', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Container(width: 80, height: 40, decoration: pw.BoxDecoration(border: pw.Border.all())),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),
              pw.Divider(color: accentColor),
              pw.Text(
                'Document généré par CashOut - ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 8, color: accentColor),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ─── HELPERS ───────────────────────────────────────
  pw.Widget _buildLabel(String text, pw.TextStyle style) {
    return pw.Text(text, style: style);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  String _formatPaymentMethod(String method) {
    final labels = {
      'cash': 'Espèces',
      'bank': 'Virement bancaire',
      'mobile_money': 'Argent mobile',
      'cheque': 'Chèque',
    };
    return labels[method] ?? method;
  }

  String _formatStatus(String status) {
    final labels = {
      'pending': 'En attente',
      'validated': 'Validée',
      'rejected': 'Rejetée',
      'cancelled': 'Annulée',
    };
    return labels[status] ?? status;
  }

  PdfColor _getStatusColor(String status) {
    switch (status) {
      case 'validated':
        return PdfColor.fromInt(0xFF27AE60); // Vert
      case 'pending':
        return PdfColor.fromInt(0xFFE67E22); // Orange
      case 'rejected':
      case 'cancelled':
        return PdfColor.fromInt(0xFFE74C3C); // Rouge
      default:
        return PdfColor.fromInt(0xFF34495E); // Gris
    }
  }

  /// Imprimer l'État de Sortie
  Future<void> imprimer() async {
    try {
      _isLoading.value = true;
      final pdf = await genererPDF();
      await _pdfService.printPDF(await pdf.save());
      Get.snackbar('Succès', 'État de sortie imprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'impression: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Partager l'État de Sortie
  Future<void> partager() async {
    try {
      _isLoading.value = true;
      final pdf = await genererPDF();
      await _pdfService.sharePDF(
        await pdf.save(),
        filename: 'EtatSortie_${_outflow.value?.receiptNo ?? 'document'}.pdf',
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du partage: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Télécharger l'État de Sortie
  Future<void> telecharger() async {
    try {
      _isLoading.value = true;
      final pdf = await genererPDF();
      await _pdfService.savePDFToFile(
        await pdf.save(),
        filename: 'EtatSortie_${_outflow.value?.receiptNo ?? 'document'}.pdf',
      );
      Get.snackbar('Succès', 'État de sortie téléchargé');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du téléchargement: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOpt(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
