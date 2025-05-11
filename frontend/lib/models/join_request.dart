class JoinRequest {
  final int? id;
  final int projectId;
  final String senderId;
  final String receiverId;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  JoinRequest({
    this.id,
    required this.projectId,
    required this.senderId,
    required this.receiverId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'],
      projectId: json['project_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'project_id': projectId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'status': status,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
