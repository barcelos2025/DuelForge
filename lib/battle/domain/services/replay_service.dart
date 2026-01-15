
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/replay_data.dart';

class ReplayService {
  static Future<void> saveReplay(ReplayData data, String matchId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/replay_$matchId.json');
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  static Future<ReplayData?> loadReplay(String matchId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/replay_$matchId.json');
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      return ReplayData.fromJson(jsonDecode(content));
    } catch (e) {
      print('Error loading replay: $e');
      return null;
    }
  }
}
