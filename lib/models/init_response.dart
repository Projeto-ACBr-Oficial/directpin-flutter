/// Modelo de resposta de inicialização
class InitResponse {
  final String type;
  final bool result;
  final String message;

  InitResponse({
    required this.type,
    required this.result,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'result': result,
      'message': message,
    };
  }

  factory InitResponse.fromJson(Map<String, dynamic> json) {
    return InitResponse(
      type: json['type'] as String,
      result: json['result'] as bool,
      message: json['message'] as String,
    );
  }
}
