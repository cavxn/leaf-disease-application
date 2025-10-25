import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/garden_journal_entry.dart';
import '../models/garden_plant.dart';

class PDFExportService {
  static Future<void> exportJournalToPDF({
    required List<GardenJournalEntry> entries,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Add cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    title ?? 'Garden Journal',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Your Garden Journey',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  if (startDate != null && endDate != null)
                    pw.Text(
                      '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey,
                      ),
                    ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '${entries.length} entries',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Add entries
      for (final entry in entries) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Entry header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          entry.title,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          entry.entryType.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 10),
                  
                  // Date and mood
                  pw.Row(
                    children: [
                      pw.Text(
                        _formatDate(entry.date),
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Text(
                        '${entry.moodEmoji} ${entry.mood.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Weather info if available
                  if (entry.hasWeatherData) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '${entry.weatherEmoji} Weather: ',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${entry.weatherCondition ?? 'Unknown'}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          if (entry.temperature != null) ...[
                            pw.SizedBox(width: 10),
                            pw.Text(
                              '${entry.temperature}°C',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                          if (entry.humidity != null) ...[
                            pw.SizedBox(width: 10),
                            pw.Text(
                              'Humidity: ${entry.humidity}%',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                  
                  // Content
                  pw.Text(
                    entry.content,
                    style: pw.TextStyle(
                      fontSize: 14,
                      lineSpacing: 1.5,
                    ),
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Tags
                  if (entry.tags.isNotEmpty) ...[
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: entry.tags.map((tag) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(
                              color: PdfColors.blue200,
                              width: 1,
                            ),
                          ),
                          child: pw.Text(
                            tag,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.blue700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                  
                  // Photos info
                  if (entry.hasPhotos) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                          color: PdfColors.green200,
                          width: 1,
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '📷 ${entry.photoPaths.length} photo${entry.photoPaths.length == 1 ? '' : 's'} attached',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.green700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }
      
      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/garden_journal_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Garden Journal Export',
      );
      
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }
  
  static Future<void> exportPlantJournalToPDF({
    required List<GardenJournalEntry> entries,
    required GardenPlant plant,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Add cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '${plant.name} Journal',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (plant.scientificName != null)
                    pw.Text(
                      plant.scientificName!,
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  pw.SizedBox(height: 40),
                  if (startDate != null && endDate != null)
                    pw.Text(
                      '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey,
                      ),
                    ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '${entries.length} entries',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Add entries (same as regular journal)
      for (final entry in entries) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Entry header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          entry.title,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          'PLANT JOURNAL',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 10),
                  
                  // Date and mood
                  pw.Row(
                    children: [
                      pw.Text(
                        _formatDate(entry.date),
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Text(
                        '${entry.moodEmoji} ${entry.mood.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Weather info if available
                  if (entry.hasWeatherData) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '${entry.weatherEmoji} Weather: ',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${entry.weatherCondition ?? 'Unknown'}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          if (entry.temperature != null) ...[
                            pw.SizedBox(width: 10),
                            pw.Text(
                              '${entry.temperature}°C',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                          if (entry.humidity != null) ...[
                            pw.SizedBox(width: 10),
                            pw.Text(
                              'Humidity: ${entry.humidity}%',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                  
                  // Content
                  pw.Text(
                    entry.content,
                    style: pw.TextStyle(
                      fontSize: 14,
                      lineSpacing: 1.5,
                    ),
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Tags
                  if (entry.tags.isNotEmpty) ...[
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: entry.tags.map((tag) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green50,
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(
                              color: PdfColors.green200,
                              width: 1,
                            ),
                          ),
                          child: pw.Text(
                            tag,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.green700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                  
                  // Photos info
                  if (entry.hasPhotos) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                          color: PdfColors.green200,
                          width: 1,
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            '📷 ${entry.photoPaths.length} photo${entry.photoPaths.length == 1 ? '' : 's'} attached',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.green700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }
      
      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${plant.name.replaceAll(' ', '_')}_journal_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${plant.name} Garden Journal Export',
      );
      
    } catch (e) {
      throw Exception('Failed to export plant journal PDF: $e');
    }
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
