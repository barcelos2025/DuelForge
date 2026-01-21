import 'package:shared_preferences/shared_preferences.dart';

class ContentCache {
  static const String _keyVersionId = 'content_version_id';
  static const String _keyPrefixBlob = 'content_blob_';
  static const String _keyPrefixChecksum = 'content_checksum_';

  /// Salva a versão e todos os blobs atomicamente (ou o mais próximo possível com SharedPreferences)
  static Future<bool> save(String versionId, Map<String, String> blobs, Map<String, String> checksums) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Idealmente faríamos um batch, mas SharedPreferences é assíncrono por chave.
    // Vamos salvar blobs primeiro, depois a versão para "commitar".
    
    for (var entry in blobs.entries) {
      await prefs.setString('$_keyPrefixBlob${entry.key}', entry.value);
    }
    
    for (var entry in checksums.entries) {
      await prefs.setString('$_keyPrefixChecksum${entry.key}', entry.value);
    }

    return await prefs.setString(_keyVersionId, versionId);
  }

  static Future<String?> getVersionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVersionId);
  }

  static Future<String?> getBlob(String blobType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefixBlob$blobType');
  }

  static Future<String?> getChecksum(String blobType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefixChecksum$blobType');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith('content_')) {
        await prefs.remove(key);
      }
    }
  }
}
