class Questionnaire {
  final String title;
  final String description;
  final List<Question> questions;

  Questionnaire({
    required this.title,
    required this.description,
    required this.questions,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
    );
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;

  Question({
    required this.id,
    required this.question,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => o.toString())
          .toList() ?? [],
    );
  }
}

class QuestionnaireResponse {
  final String questionnaireTitle;
  final List<QuestionAnswer> answers;

  QuestionnaireResponse({
    required this.questionnaireTitle,
    required this.answers,
  });
}

class QuestionAnswer {
  final int questionId;
  final String question;
  final String selectedAnswer;

  QuestionAnswer({
    required this.questionId,
    required this.question,
    required this.selectedAnswer,
  });
}
