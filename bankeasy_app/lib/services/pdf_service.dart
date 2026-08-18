import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/form_models.dart';

/// Builds and opens the print/save-as-PDF sheet for a filled form.
/// The letterhead block only renders when a bank other than the
/// "No bank — generic template" default was chosen (audit item:
/// letterhead is always optional, never mandatory).
class PdfService {
  static Future<void> generateAndShare({
    required FormSchema schema,
    required Map<String, String> values,
    String? selectedBank,
  }) async {
    final doc = pw.Document();
    final hasLetterhead = selectedBank != null &&
        !selectedBank.startsWith('No bank');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (hasLetterhead) ...[
                pw.Text(
                  selectedBank,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Divider(thickness: 1.2),
                pw.SizedBox(height: 8),
              ],
              pw.Center(
                child: pw.Text(
                  schema.title.toUpperCase(),
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 18),
              ...schema.fields.map((f) {
                final value = values[f.id];
                final isBlank = value == null || value.trim().isEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 160,
                        child: pw.Text('${f.label}:',
                            style: const pw.TextStyle(fontSize: 11)),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          isBlank ? '' : value,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 24),
              pw.Text(
                'Generated with BankEasy — not affiliated with any bank. '
                'Verify details with your branch before submitting.',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '${schema.id}.pdf',
    );
  }
}
