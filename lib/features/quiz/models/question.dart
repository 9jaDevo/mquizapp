enum DifficultyLevel {
  beginner,
  intermediate,
  advanced;

  static DifficultyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      case 'beginner':
      default:
        return DifficultyLevel.beginner;
    }
  }
}

final class Question {
  const Question({
    this.questionType,
    this.answerOptions,
    this.correctAnswer,
    this.id,
    this.languageId,
    this.level,
    this.note,
    this.question,
    this.categoryId,
    this.imageUrl,
    this.subcategoryId,
    this.audio,
    this.audioType,
    this.attempted = false,
    this.submittedAnswerId = '',
    this.marks,
    this.context,
    this.difficultyLevel = DifficultyLevel.beginner,
    this.skillTags = const [],
  });

  factory Question.fromJson(Map<String, dynamic> questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    final optionIds = <String>['a', 'b', 'c', 'd', 'e'];
    final options = <AnswerOption>[];

    //creating answerOption model
    final queType = questionJson['question_type'] ?? '';

    if (queType == '2') {
      final ops1 = questionJson['optiona'].toString();
      final ops2 = questionJson['optionb'].toString();
      if (ops1.isNotEmpty) {
        options.add(AnswerOption(id: 'a', title: ops1));
      }
      if (ops2.isNotEmpty) {
        options.add(AnswerOption(id: 'b', title: ops2));
      }
    } else {
      for (final optionId in optionIds) {
        final optionTitle = questionJson['option$optionId'] as String? ?? '';
        if (optionTitle.isNotEmpty) {
          options.add(AnswerOption(id: optionId, title: optionTitle));
        }
      }
    }

    // Parse skill tags
    List<String> skillTags = [];
    if (questionJson['skill_tags'] != null) {
      try {
        if (questionJson['skill_tags'] is String) {
          final decoded = questionJson['skill_tags'] as String;
          if (decoded.isNotEmpty && decoded != '[]') {
            skillTags = decoded
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } else if (questionJson['skill_tags'] is List) {
          skillTags =
              (questionJson['skill_tags'] as List).map((e) => e.toString()).toList();
        }
      } catch (e) {
        skillTags = [];
      }
    }

    return Question(
      id: questionJson['id'] as String?,
      categoryId: questionJson['category'] as String? ?? '',
      imageUrl: questionJson['image'] as String?,
      languageId: questionJson['language_id'] as String?,
      subcategoryId: questionJson['subcategory'] as String? ?? '',
      correctAnswer: CorrectAnswer.fromJson(
        questionJson['answer'] as Map<String, dynamic>,
      ),
      level: questionJson['level'] as String? ?? '',
      question: questionJson['question'] as String?,
      note: questionJson['note'] as String? ?? '',
      questionType: questionJson['question_type'] as String? ?? '',
      audio: questionJson['audio'] as String? ?? '',
      audioType: questionJson['audio_type'] as String? ?? '',
      marks: questionJson['marks'] as String? ?? '',
      answerOptions: options,
      context: questionJson['context'] as String?,
      difficultyLevel: DifficultyLevel.fromString(
        questionJson['difficulty_level'] as String? ?? 'beginner',
      ),
      skillTags: skillTags,
    );
  }

  factory Question.fromBookmarkJson(Map<String, dynamic> questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    final optionIds = <String>['a', 'b', 'c', 'd', 'e'];
    final options = <AnswerOption>[];

    //creating answerOption model
    for (final optionId in optionIds) {
      final optionTitle = questionJson['option$optionId'].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    }

    return Question(
      id: questionJson['question_id'] as String?,
      categoryId: questionJson['category'] as String? ?? '',
      imageUrl: questionJson['image'] as String?,
      languageId: questionJson['language_id'] as String?,
      subcategoryId: questionJson['subcategory'] as String? ?? '',
      correctAnswer: CorrectAnswer.fromJson(
        questionJson['answer'] as Map<String, dynamic>,
      ),
      level: questionJson['level'] as String? ?? '',
      question: questionJson['question'] as String?,
      note: questionJson['note'] as String? ?? '',
      questionType: questionJson['question_type'] as String? ?? '',
      audio: questionJson['audio'] as String? ?? '',
      audioType: questionJson['audio_type'] as String? ?? '',
      marks: questionJson['marks'] as String? ?? '',
      answerOptions: options,
      context: questionJson['context'] as String?,
      difficultyLevel: DifficultyLevel.fromString(
        questionJson['difficulty_level'] as String? ?? 'beginner',
      ),
    );
  }

  final String? question;
  final String? id;
  final String? categoryId;
  final String? subcategoryId;
  final String? imageUrl;
  final String? level;
  final CorrectAnswer? correctAnswer;
  final String? note;
  final String? languageId;
  final String submittedAnswerId;
  final String? questionType;
  final List<AnswerOption>? answerOptions;
  final bool attempted;
  final String? audio;
  final String? audioType;
  final String? marks;
  final String? context;
  final DifficultyLevel difficultyLevel;
  final List<String> skillTags;

  bool get isScenarioQuestion =>
      questionType == '3' || questionType == '4'; // 3=scenario, 4=case_study

  Question updateQuestionWithAnswer({required String submittedAnswerId}) {
    return Question(
      marks: marks,
      submittedAnswerId: submittedAnswerId,
      audio: audio,
      audioType: audioType,
      answerOptions: answerOptions,
      attempted: submittedAnswerId.isNotEmpty,
      categoryId: categoryId,
      correctAnswer: correctAnswer,
      id: id,
      imageUrl: imageUrl,
      languageId: languageId,
      level: level,
      note: note,
      question: question,
      questionType: questionType,
      subcategoryId: subcategoryId,
      context: context,
      difficultyLevel: difficultyLevel,
      skillTags: skillTags,
    );
  }

  Question copyWith({String? submittedAnswer, bool? attempted}) {
    return Question(
      marks: marks,
      submittedAnswerId: submittedAnswer ?? submittedAnswerId,
      answerOptions: answerOptions,
      audio: audio,
      audioType: audioType,
      attempted: attempted ?? this.attempted,
      categoryId: categoryId,
      correctAnswer: correctAnswer,
      id: id,
      imageUrl: imageUrl,
      languageId: languageId,
      level: level,
      note: note,
      question: question,
      questionType: questionType,
      subcategoryId: subcategoryId,
      context: context,
      difficultyLevel: difficultyLevel,
      skillTags: skillTags,
    );
  }
}
