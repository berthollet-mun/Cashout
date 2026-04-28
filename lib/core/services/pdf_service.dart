import 'dart:typed_data';
import 'dart:io';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/outflow_model.dart';

class PdfService extends GetxService {
  static PdfService get to => Get.find();

  /// Générer et imprimer un PDF de sortie
  Future<void> generateAndPrintOutflow(OutflowModel outflow) async {
    final pdf = await _buildOutflowPdf(outflow);
    await printPDF(await pdf.save());
  }

  /// Générer et partager un PDF de sortie
  Future<void> generateAndShareOutflow(OutflowModel outflow) async {
    final pdf = await _buildOutflowPdf(outflow);
    await sharePDF(await pdf.save(), filename: 'recu_${outflow.id.substring(0, 8)}.pdf');
  }

  /// Imprimer un PDF
  Future<void> printPDF(Uint8List bytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'impression: $e');
    }
  }

  /// Partager un PDF
  Future<void> sharePDF(Uint8List bytes, {required String filename}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'État de Sortie',
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du partage: $e');
    }
  }

  /// Sauvegarder un PDF dans les fichiers locaux
  Future<String?> savePDFToFile(Uint8List bytes, {required String filename}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la sauvegarde: $e');
      return null;
    }
  }

  /// Construire un PDF de sortie de caisse
  Future<pw.Document> _buildOutflowPdf(OutflowModel outflow) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(outflow.outflowDate);
    final amountStr = '${NumberFormat('#,###', 'fr_FR').format(outflow.amount)} FCFA';
    final docNumber = outflow.receiptNo ?? outflow.id.substring(0, 8).toUpperCase();
    final tax = 0.0;
    final subTotal = outflow.amount;
    final total = subTotal + tax;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CASHOUT SARL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    pw.Text('Gestion des sorties de caisse'),
                    pw.Text('Abidjan - Côte d\'Ivoire'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('ETAT DE SORTIE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Document: $docNumber'),
                    pw.Text('Date: $dateStr'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _pdfRow('Client / Bénéficiaire', outflow.recipient),
            _pdfRow('Email', outflow.recipientEmail ?? '-'),
            _pdfRow('Téléphone', outflow.recipientPhone ?? '-'),
            _pdfRow('Statut', outflow.status.toUpperCase()),
            pw.SizedBox(height: 14),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FixedColumnWidth(55),
                3: const pw.FixedColumnWidth(70),
                4: const pw.FixedColumnWidth(75),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('N°', bold: true),
                    _tableCell('Description', bold: true),
                    _tableCell('Qté', bold: true, alignRight: true),
                    _tableCell('PU', bold: true, alignRight: true),
                    _tableCell('Total', bold: true, alignRight: true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell('1'),
                    _tableCell(outflow.description),
                    _tableCell('1', alignRight: true),
                    _tableCell(amountStr, alignRight: true),
                    _tableCell(amountStr, alignRight: true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 260,
                child: pw.Column(
                  children: [
                    _totalsRow('Sous-total', subTotal),
                    _totalsRow('Taxes', tax),
                    pw.Divider(),
                    _totalsRow('Total général', total, bold: true),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _signatureBlock('Signature émetteur'),
                _signatureBlock('Signature récepteur'),
                pw.Column(
                  children: [
                    pw.Text('Cachet / Tampon'),
                    pw.SizedBox(height: 8),
                    pw.Container(width: 110, height: 55, decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.BarcodeWidget(
                data: docNumber,
                barcode: pw.Barcode.qrCode(),
                width: 70,
                height: 70,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
  
  pw.Widget _tableCell(String value, {bool bold = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        value,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10),
      ),
    );
  }

  pw.Widget _totalsRow(String label, double amount, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '${NumberFormat('#,###', 'fr_FR').format(amount)} FCFA',
            style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget _signatureBlock(String title) {
    return pw.Column(
      children: [
        pw.Text(title),
        pw.SizedBox(height: 35),
        pw.Container(width: 110, height: 1, color: PdfColors.black),
      ],
    );
  }
}
