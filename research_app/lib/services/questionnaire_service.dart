import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/questionnaire.dart';

class QuestionnaireService {
  static List<String> _availableQuestionnaires = [];
  static bool _isInitialized = false;

  static Future<List<String>> get availableQuestionnaires async {
    if (!_isInitialized) {
      await _initializeQuestionnaires();
    }
    return _availableQuestionnaires;
  }

  static Future<void> _initializeQuestionnaires() async {
    try {
      // Get the manifest to find all assets in the source folder
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Filter for JSON files in the source folder
      _availableQuestionnaires = manifestMap.keys
          .where((String key) => key.startsWith('assets/source/') && key.endsWith('.json'))
          .map((String key) => key.replaceFirst('assets/source/', ''))
          .toList();
      
      _isInitialized = true;
    } catch (e) {
      // Fallback to hardcoded list if manifest reading fails
      _availableQuestionnaires = [
        'ui_satisfaction.json',
        'app_functionality.json',
      ];
      _isInitialized = true;
    }
  }

  static Future<Questionnaire> loadQuestionnaire(String fileName) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/source/$fileName');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return Questionnaire.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load questionnaire: $e');
    }
  }

  static String getDisplayName(String fileName) {
    // Remove .json extension and replace underscores with spaces
    String displayName = fileName.replaceAll('.json', '').replaceAll('_', ' ');
    
    // Capitalize first letter of each word
    displayName = displayName.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return displayName;
  }
}
