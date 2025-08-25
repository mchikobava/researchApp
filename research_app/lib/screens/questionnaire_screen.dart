import 'package:flutter/material.dart';
import '../models/questionnaire.dart';
import '../services/storage_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Questionnaire questionnaire;

  const QuestionnaireScreen({
    super.key,
    required this.questionnaire,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int currentQuestionIndex = 0;
  Map<int, String> answers = {};

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questionnaire.questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == widget.questionnaire.questions.length - 1;
    final hasAnswer = answers.containsKey(currentQuestion.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionnaire.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            
            // Progress indicator
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questionnaire.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Question ${currentQuestionIndex + 1} of ${widget.questionnaire.questions.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Image placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: const Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Question
            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // Answer options
            ...currentQuestion.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = answers[currentQuestion.id] == option;
              
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        answers[currentQuestion.id] = option;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.blue : Colors.grey[300],
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue[800] : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 40),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Previous'),
                  ),
                
                ElevatedButton(
                  onPressed: hasAnswer
                      ? () {
                          if (isLastQuestion) {
                            _showResults();
                          } else {
                            setState(() {
                              currentQuestionIndex++;
                            });
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLastQuestion ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResults() async {
    final responses = widget.questionnaire.questions.map((question) {
      return QuestionAnswer(
        questionId: question.id,
        question: question.question,
        selectedAnswer: answers[question.id] ?? 'No answer',
      );
    }).toList();

    final questionnaireResponse = QuestionnaireResponse(
      questionnaireTitle: widget.questionnaire.title,
      answers: responses,
    );

    // Show saving dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Saving your responses...'),
            ],
          ),
        );
      },
    );

    try {
      // Save the response to device storage
      await StorageService.saveResponse(questionnaireResponse);
      
      // Close saving dialog
      Navigator.of(context).pop();
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Survey Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thank you for completing the "${widget.questionnaire.title}"'),
                const SizedBox(height: 16),
                const Text('Your responses have been saved to your device.'),
                const SizedBox(height: 8),
                const Text(
                  'You can view your saved responses from the main menu.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to main screen
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close saving dialog
      Navigator.of(context).pop();
      
      // Show error dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Failed to save your responses.'),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to main screen
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
