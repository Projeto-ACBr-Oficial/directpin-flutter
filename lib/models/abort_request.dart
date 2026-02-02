/// Modelo de requisição de abort
class AbortRequest {
  final String type;
  final String? entityIdentifier;

  AbortRequest({
    required this.type,
    this.entityIdentifier,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (entityIdentifier != null) 'entityIdentifier': entityIdentifier,
    };
  }

  factory AbortRequest.fromJson(Map<String, dynamic> json) {
    return AbortRequest(
      type: json['type'] as String,
      entityIdentifier: json['entityIdentifier'] as String?,
    );
  }
}
