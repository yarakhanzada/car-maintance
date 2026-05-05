class ChatQuestion {
  final int id;
  final String question;

  ChatQuestion({required this.id, required this.question});

  factory ChatQuestion.fromJson(Map<String, dynamic> json) {
    return ChatQuestion(id: json['id'], question: json['question']);
  }
}