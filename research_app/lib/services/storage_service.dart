import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/questionnaire.dart';

class StorageService {
  static const String _responsesFolder = 'questionnaire_responses';

  /// Save questionnaire response to device storage
  static Future<void> saveResponse(QuestionnaireResponse response) async {
    try {
      final directory = await _getResponsesDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'response_${response.questionnaireTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      final responseData = {
        'questionnaireTitle': response.questionnaireTitle,
        'timestamp': timestamp,
        'date': DateTime.now().toIso8601String(),
        'answers': response.answers.map((answer) => {
          'questionId': answer.questionId,
          'question': answer.question,
          'selectedAnswer': answer.selectedAnswer,
        }).toList(),
      };
      
      await file.writeAsString(jsonEncode(responseData));
    } catch (e) {
      throw Exception('Failed to save response: $e');
    }
  }

  /// Load all saved responses from device storage
  static Future<List<QuestionnaireResponse>> loadAllResponses() async {
    try {
      final directory = await _getResponsesDirectory();
      final files = directory.listSync().whereType<File>();
      final responses = <QuestionnaireResponse>[];
      
      for (final file in files) {
        if (file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            
            final answers = (data['answers'] as List<dynamic>).map((answerData) {
              return QuestionAnswer(
                questionId: answerData['questionId'],
                question: answerData['question'],
                selectedAnswer: answerData['selectedAnswer'],
              );
            }).toList();
            
            responses.add(QuestionnaireResponse(
              questionnaireTitle: data['questionnaireTitle'],
              answers: answers,
            ));
          } catch (e) {
            // Skip corrupted files
            continue;
          }
        }
      }
      
      return responses;
    } catch (e) {
      throw Exception('Failed to load responses: $e');
    }
  }

  /// Get the directory for storing responses
  static Future<Directory> _getResponsesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final responsesDir = Directory('${appDir.path}/$_responsesFolder');
    
    if (!await responsesDir.exists()) {
      await responsesDir.create(recursive: true);
    }
    
    return responsesDir;
  }

  /// Delete all saved responses
  static Future<void> clearAllResponses() async {
    try {
      final directory = await _getResponsesDirectory();
      final files = directory.listSync().whereType<File>();
      
      for (final file in files) {
        if (file.path.endsWith('.json')) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to clear responses: $e');
    }
  }

  /// Get the number of saved responses
  static Future<int> getResponseCount() async {
    try {
      final directory = await _getResponsesDirectory();
      final files = directory.listSync().whereType<File>();
      return files.where((file) => file.path.endsWith('.json')).length;
    } catch (e) {
      return 0;
    }
  }
}
