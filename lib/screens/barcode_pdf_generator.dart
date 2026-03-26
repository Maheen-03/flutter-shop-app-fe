import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';

Future<void> generateBarcodePdf(List products) async {
  final pdf = pw.Document();

  final barcode = Barcode.code128();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: products.map((product) {
              final String name = product["product_name"];
              final String code = product["barcode"];

              return pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      name,
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.BarcodeWidget(
                      barcode: barcode,
                      data: code,
                      width: 120,
                      height: 50,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      code,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ];
      },
    ),
  );

  // 🔥 PRINT / SHARE
  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}
