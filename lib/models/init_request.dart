/// Modelo de requisição de inicialização
class InitRequest {
  final String type;
  final String token;

  InitRequest({
    required this.type,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'token': token,
    };
  }

  factory InitRequest.fromJson(Map<String, dynamic> json) {
    return InitRequest(
      type: json['type'] as String,
      token: json['token'] as String,
    );
  }
}
