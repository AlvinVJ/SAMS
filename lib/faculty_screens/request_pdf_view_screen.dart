import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_request_service.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../widgets/app_sidebar.dart';
import '../services/auth_service.dart';
import '../styles/app_theme.dart';
import '../services/url_launcher_helper.dart';

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
  bool _isLoadingDetails = false;
  late PendingApproval _fullRequest;

  @override
  void initState() {
    super.initState();
    _fullRequest = widget.request;
    // If it's a 'lite' request from a fast list, enrichment is needed
    if (_fullRequest.formData.isEmpty) {
      _loadFullDetails();
    }
  }

  Future<void> _loadFullDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final fullData = await UserRequestService().fetchRequestDetails(widget.requestId);
      setState(() {
        _fullRequest = fullData.toPendingApproval();
        _isLoadingDetails = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load full details: $e')),
        );
      }
      setState(() => _isLoadingDetails = false);
    }
  }

  Widget _buildSidebar() {
    final profile = AuthService().userProfile;
    if (profile?.role == 'student') {
      return const AppSidebar(activeRoute: '/requests');
    }
    return const FacultySidebar(activeRoute: '/faculty/requests');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                AppHeader(),
                if (_isLoadingDetails)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else
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
                            if (_fullRequest.formData['attachmentUrl'] != null) ...[
                              ElevatedButton.icon(
                                icon: const Icon(Icons.attachment),
                                label: const Text('View Attachment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () async {
                                  try {
                                    final rawUrl = _fullRequest.formData['attachmentUrl'];
                                    final attachmentUrl = rawUrl?.toString();
                                    
                                    debugPrint('[DEBUG] View Attachment Clicked. URL: $attachmentUrl');
                                    
                                    if (attachmentUrl == null || attachmentUrl.isEmpty) {
                                      throw 'No attachment URL found';
                                    }

                                    // Use the new helper that handles Web specifically
                                    await UrlLauncherHelper.launch(attachmentUrl);
                                    
                                  } catch (e) {
                                    debugPrint('[DEBUG] Error launching attachment: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not open attachment: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                            ],
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
    final request = _fullRequest;

    // Use formData for body if available, otherwise fallback to description
    final Map<String, dynamic> combinedData = Map.from(request.formData);

    // If it's a bulk request, pull in the specialized fields if they aren't already in formData
    if (request.isBulk) {
      if (request.eventName != null)
        combinedData['EVENT_NAME'] = request.eventName;
      if (request.eventDate != null)
        combinedData['EVENT_DATE'] = request.eventDate;
      if (request.className != null) combinedData['CLASS'] = request.className;
      if (request.students != null) {
        combinedData['STUDENT_COUNT'] = request.students!.length;
      }
    }

    final List<pw.Widget> formFields = [];
    if (combinedData.isNotEmpty) {
      combinedData.forEach((key, value) {
        if (value == null) return;

        // Skip internal attachment metadata keys
        if (key == 'attachmentUrl' ||
            key == 'attachmentPath' ||
            key == 'attachmentName' ||
            key == 'attachmentType') {
          return;
        }

        // Case 1: Student List (List of Maps)
        if (value is List) {
          formFields.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    '${key.replaceAll('_', ' ').toUpperCase()}:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                pw.Table.fromTextArray(
                  context: null,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: ['UID', 'Name', 'Gender'],
                  data: value.map((s) {
                    if (s is Map) {
                      return [
                        s['mits_uid']?.toString() ?? '',
                        s['name']?.toString() ?? '',
                        s['gender']?.toString() ?? '',
                      ];
                    }
                    return [s.toString(), '', ''];
                  }).toList(),
                ),
                pw.SizedBox(height: 12),
              ],
            ),
          );
          return;
        }

        // Case 2: Supabase / Remote Attachment
        if (value is Map && value.containsKey('attachmentUrl')) {
          final url = value['attachmentUrl'].toString();
          final name = value['attachmentName'] ?? 'Attachment';
          final type = value['attachmentType'] ?? '';

          if (type.startsWith('image/')) {
            formFields.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfField(key, name),
                  pw.SizedBox(height: 5),
                  // Note: pw.Image(pw.MemoryImage(...)) needs actual bytes.
                  // Since _generatePdf is often called synchronously or semi-sync in PDF preview,
                  // we might need a placeholder or a way to pre-fetch.
                  // For now, we'll indicate it's an image.
                  pw.Text("[Image Attachment - See download for full view]",
                      style: pw.TextStyle(color: PdfColors.blue, fontSize: 10)),
                  pw.SizedBox(height: 10),
                ],
              ),
            );
          } else {
            formFields.add(_buildPdfField(key, "$name (File)"));
          }
          return;
        }

        // Case 3: Legacy base64 Image/File Object
        if (value is Map &&
            value.containsKey('url') &&
            value['url'].toString().startsWith('data:image')) {
          try {
            final dataUrl = value['url'].toString();
            final base64Data = dataUrl.split(',')[1];
            final bytes = base64Decode(base64Data);
            formFields.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfField(key, value['name'] ?? 'Image Attachment'),
                  pw.SizedBox(height: 5),
                  pw.Image(pw.MemoryImage(bytes), width: 150),
                  pw.SizedBox(height: 10),
                ],
              ),
            );
          } catch (e) {
            formFields.add(_buildPdfField(key, 'Error rendering image'));
          }
          return;
        }

        // Default Case
        if (value is Map && value.containsKey('name')) {
          formFields.add(_buildPdfField(key, value['name'].toString()));
        } else {
          formFields.add(_buildPdfField(key, value.toString()));
        }
      });
    } else {
      formFields.add(
        pw.Text(request.description, style: const pw.TextStyle(fontSize: 11)),
      );
    }

    // Final data verification log before generation
    debugPrint('[PDF-GEN-VERIFY] Generating PDF for ${widget.requestId}');
    debugPrint(
      '[PDF-GEN-VERIFY]   Total History Items: ${request.approvalHistory.length}',
    );
    for (var i = 0; i < request.approvalHistory.length; i++) {
      final h = request.approvalHistory[i];
      debugPrint(
        '[PDF-GEN-VERIFY]   Item $i: Level ${h.level} | ${h.approverName} | ${h.role} | ${h.status}',
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return [
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
              'The ${request.lastLevelRoleTag.replaceAll('_', ' ').toUpperCase()},',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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
              pw.Column(
                children: request.approvalHistory.map((history) {
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
                                  history.comments!.trim().isNotEmpty)
                                pw.Text(
                                  'Feedback: "${history.comments!.trim()}"',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontStyle: pw.FontStyle.italic,
                                    color: PdfColors.grey700,
                                  ),
                                )
                              else
                                pw.Text(
                                  'Feedback: "No specific feedback provided."',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontStyle: pw.FontStyle.italic,
                                    color: PdfColors.grey400,
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
                }).toList(),
              ),
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
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
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
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
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
            pw.SizedBox(height: 50),
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
                  'SAMS - Student Approval Management System',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              '${label.replaceAll('_', ' ').toUpperCase()}:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
