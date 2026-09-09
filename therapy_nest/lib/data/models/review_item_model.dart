/// Model representing an exercise item where the user required 2+ hints
/// for "Items to Review" section on the Domain Detail Screen.
class ReviewItemModel {
  const ReviewItemModel({
    required this.id,
    required this.exerciseItemId,
    required this.domain,
    required this.exerciseTypeCode,
    required this.prompt,
    required this.hintCount,
    required this.isCorrect,
    required this.createdAt,
    this.targetWord = '',
  });

  final String id;
  final String exerciseItemId;
  final String domain;
  final String exerciseTypeCode;
  final String prompt;
  final int hintCount;
  final bool isCorrect;
  final DateTime createdAt;
  final String targetWord;

  /// Human-friendly display label for task subtype (e.g. "Confrontation Naming").
  String get subtypeLabel {
    return exerciseTypeCode
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Positive, clear hint badge text.
  String get hintBadgeText => '$hintCount hints used';
}
