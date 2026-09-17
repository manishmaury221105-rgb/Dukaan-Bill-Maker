import 'dart:typed_data';
import 'file_downloader_stub.dart'
    if (dart.library.js_interop) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_io.dart' as platform;

class FileDownloader {
  static Future<bool> downloadPdf(Uint8List bytes, String filename) async {
    return await platform.savePdfFile(bytes, filename);
  }
}
