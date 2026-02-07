import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/user_request_service.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../styles/app_theme.dart';

/// Screen to view request details as PDF
/// Allows faculty to review the full request before approving/rejecting
class RequestPdfViewScreen extends StatefulWidget {
  final String requestId;
  final PendingApproval request;

  const RequestPdfViewScreen({
    super.key,
    required this.requestId,
    required this.request,
  });

  @override
  State<RequestPdfViewScreen> createState() => _RequestPdfViewScreenState();
}

class _RequestPdfViewScreenState extends State<RequestPdfViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/requests'),
          Expanded(
            child: Column(
              children: [
                AppHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Request Details',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.download),
                              label: const Text('Download PDF'),
                              onPressed: () async {
                                final pdf = await _generatePdf();
                                await Printing.sharePdf(
                                  bytes: await pdf.save(),
                                  filename: 'request_${widget.requestId}.pdf',
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // PDF Preview
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PdfPreview(
                                build: (format) =>
                                    _generatePdf().then((pdf) => pdf.save()),
                                canChangePageFormat: false,
                                canChangeOrientation: false,
                                canDebug: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final request = widget.request;

    // Use formData for body if available, otherwise fallback to description
    final List<pw.Widget> formFields = [];
    if (request.formData.isNotEmpty) {
      request.formData.forEach((key, value) {
        formFields.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 140,
                  child: pw.Text(
                    '${key.replaceAll('_', ' ').toUpperCase()}:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    value.toString(),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } else {
      formFields.add(
        pw.Text(request.description, style: const pw.TextStyle(fontSize: 11)),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Institutional Branding
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'MUTHOOT INSTITUTE OF TECHNOLOGY & SCIENCE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '(AUTONOMOUS INSTITUTION)',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'DEPARTMENT OF ${request.department.toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 20),

              // Date & Location
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Date: ${request.date}\nLocation: Ernakulam',
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),

              pw.SizedBox(height: 20),

              // Recipient Details
              pw.Text('To,', style: const pw.TextStyle(fontSize: 11)),
              pw.Text(
                'The ${request.roleTag.replaceAll('_', ' ').toUpperCase()},',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'MITS, Ernakulam.',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 30),

              // Sender Details (From)
              pw.Text('From,', style: const pw.TextStyle(fontSize: 11)),
              pw.Text(
                '${request.studentName},',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'ID: ${request.studentId} | Dept: ${request.department}',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 30),

              // Subject
              pw.Center(
                child: pw.Text(
                  'SUB: APPLICATION FOR ${request.type.toUpperCase()}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              // Body
              pw.Text(
                'Respected Sir/Madam,',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'I am writing this letter to formally request approval for ${request.type}. Below are the relevant details submitted for your review:',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 15),

              // Structured Data
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey200),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey50,
                ),
                child: pw.Column(children: formFields),
              ),

              pw.SizedBox(height: 30),

              // NEW: Approval History Section
              if (request.approvalHistory.isNotEmpty) ...[
                pw.Text(
                  'APPROVAL TRACKING',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...request.approvalHistory.map((history) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 10,
                          height: 10,
                          margin: const pw.EdgeInsets.only(top: 3, right: 8),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.green,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Level ${history.level}: ${history.status} by ${history.approverName} (${history.role})',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              if (history.comments != null &&
                                  history.comments!.isNotEmpty)
                                pw.Text(
                                  'Comments: "${history.comments}"',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontStyle: pw.FontStyle.italic,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              pw.Text(
                                'Timestamp: ${history.timestamp}',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 10),
              ],

              pw.SizedBox(height: 40),

              // Closing
              pw.Text('Thanking You,', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 40),

              // Signature Area
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Student Signature',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Authorized Signature',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '(${request.roleTag.toUpperCase()})',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Footer Metadata
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SAMS - Student Approval Management System',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Reference ID: ${widget.requestId}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
