import 'dart:convert';
import 'package:flutter/foundation.dart';

class ContentValidator {
  /// Valida se o JSON do blob é válido e possui campos mínimos esperados.
  static bool validate(String blobType, String jsonString) {
    try {
      final json = jsonDecode(jsonString);

      switch (blobType) {
        case 'card_catalog':
          if (json is! List) return false;
          if (json.isNotEmpty && (json.first['id'] == null)) return false;
          return true;
        
        case 'balance':
          if (json is! Map) return false;
          return true; // Campos opcionais, basta ser map válido
        
        case 'shop':
          if (json is! Map) return false;
          return json.containsKey('slots');
        
        case 'drop_tables':
          if (json is! Map) return false;
          return json.containsKey('chests');
          
        default:
          return true; // Tipos desconhecidos passam se for JSON válido
      }
    } catch (e) {
      debugPrint('❌ ContentValidator: JSON inválido para $blobType: $e');
      return false;
    }
  }
}
