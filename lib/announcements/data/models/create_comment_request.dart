class CreateCommentRequest {
  final String employeeId;
  final String content;

  const CreateCommentRequest({
    required this.employeeId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'content': content,
    };
  }
}