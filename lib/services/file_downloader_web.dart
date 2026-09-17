import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<bool> savePdfFile(Uint8List bytes, String filename) async {
  try {
    // 1. Try Blob Object URL method
    final blobParts = [bytes.toJS].toJS;
    final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'application/pdf'));
    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();

    // Critical: Keep the Object URL alive for 45 seconds so Chrome's download manager
    // finishes reading the full byte stream from memory instead of downloading a 0-byte file.
    Future.delayed(const Duration(seconds: 45), () {
      try {
        web.URL.revokeObjectURL(url);
      } catch (_) {}
    });

    return true;
  } catch (e) {
    // Fallback: Data URI download
    try {
      final base64String = base64Encode(bytes);
      final dataUri = 'data:application/pdf;base64,$base64String';
      final anchor = web.HTMLAnchorElement()
        ..href = dataUri
        ..download = filename
        ..style.display = 'none';
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      return true;
    } catch (_) {
      return false;
    }
  }
}
