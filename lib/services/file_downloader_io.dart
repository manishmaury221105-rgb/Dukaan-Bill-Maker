import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

Future<bool> savePdfFile(Uint8List bytes, String filename) async {
  try {
    final shared = await Printing.sharePdf(bytes: bytes, filename: filename);
    if (shared) return true;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return true;
  } catch (e) {
    return false;
  }
}
