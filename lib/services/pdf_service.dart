import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

/// PDFService
///
/// Service to generate PDF approval letters for approved requests.
/// Creates professional approval documents with request details,
/// approval chain, and digital signatures.
///
/// Usage:
/// ```dart
/// await PDFService().generateApprovalLetter(
///   requestId: 'REQ-001',
///   requestType: 'Club Event Approval',
///   requestData: {...},
///   approvals: [...],
/// );
/// ```
class PDFService {
  /// Generate and share/download an approval letter PDF
  ///
  /// [requestId] - Unique request identifier
  /// [requestType] - Type of request (e.g., "Club Event Approval")
  /// [requestData] - Map of form data (event name, date, etc.)
  /// [approvals] - List of approval records with approver details
  Future<void> generateApprovalLetter({
    required String requestId,
    required String requestType,
    required Map<String, dynamic> requestData,
    required List<Map<String, dynamic>> approvals,
  }) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                pw.SizedBox(height: 30),

                // Title
                pw.Center(
                  child: pw.Text(
                    'APPROVAL LETTER',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),

                // Request Information
                _buildRequestInfo(requestId, requestType),
                pw.SizedBox(height: 20),

                // Request Details
                _buildRequestDetails(requestData),
                pw.SizedBox(height: 20),

                // Approval Chain
                _buildApprovalChain(approvals),
                pw.SizedBox(height: 30),

                // Footer
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Share/Download PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'approval_letter_$requestId.pdf',
      );

      print('✓ PDF generated successfully: approval_letter_$requestId.pdf');
    } catch (e) {
      print('✗ Error generating PDF: $e');
      rethrow;
    }
  }

  /// Build the header section with institution details
  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'MARIAN ENGINEERING COLLEGE',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Trivandrum, Kerala', style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          'Smart Approval Management System (SAMS)',
          style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build request information section
  pw.Widget _buildRequestInfo(String requestId, String requestType) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Request ID:', requestId),
          pw.SizedBox(height: 5),
          _buildInfoRow('Request Type:', requestType),
          pw.SizedBox(height: 5),
          _buildInfoRow(
            'Date Issued:',
            DateTime.now().toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  /// Build request details section
  pw.Widget _buildRequestDetails(Map<String, dynamic> requestData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Request Details:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: requestData.entries.map((entry) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: _buildInfoRow(
                  '${_formatFieldName(entry.key)}:',
                  entry.value.toString(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build approval chain section
  pw.Widget _buildApprovalChain(List<Map<String, dynamic>> approvals) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Approval History:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...approvals.asMap().entries.map((entry) {
          final index = entry.key;
          final approval = entry.value;
          return _buildApprovalRecord(index + 1, approval);
        }).toList(),
      ],
    );
  }

  /// Build a single approval record
  pw.Widget _buildApprovalRecord(int level, Map<String, dynamic> approval) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Level $level: ${approval['role'] ?? 'Unknown Role'}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          _buildInfoRow('Status:', approval['status'] ?? 'Unknown'),
          if (approval['approverName'] != null)
            _buildInfoRow('Approved By:', approval['approverName']),
          if (approval['approverEmail'] != null)
            _buildInfoRow('Email:', approval['approverEmail']),
          if (approval['timestamp'] != null)
            _buildInfoRow('Date:', approval['timestamp'].toString()),
          if (approval['comments'] != null &&
              approval['comments'].toString().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text(
                'Comments: ${approval['comments']}',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ),
          // Digital signature placeholder
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Text(
                  'Digital Signature',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build footer section
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Text(
          'This is a digitally generated approval letter from SAMS.',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          'No physical signature required.',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  /// Helper to build info rows
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    );
  }

  /// Format field names for display (camelCase to Title Case)
  String _formatFieldName(String fieldName) {
    // Convert camelCase to Title Case
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
