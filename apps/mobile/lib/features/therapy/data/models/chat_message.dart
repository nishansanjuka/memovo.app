class ChatMessage {
  final String id;
  final String content;
  final String sender; // 'user' or 'ai'
  final DateTime createdAt;
  final bool isStreaming;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.createdAt,
    this.isStreaming = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: json['sender'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    String? sender,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
