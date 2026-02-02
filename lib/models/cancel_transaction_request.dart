/// Modelo de requisição de cancelamento de transação
class CancelTransactionRequest {
  final String type;
  final String nsu;
  final String? entityIdentifier;

  CancelTransactionRequest({
    required this.type,
    required this.nsu,
    this.entityIdentifier,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'nsu': nsu,
      if (entityIdentifier != null) 'entityIdentifier': entityIdentifier,
    };
  }

  factory CancelTransactionRequest.fromJson(Map<String, dynamic> json) {
    return CancelTransactionRequest(
      type: json['type'] as String,
      nsu: json['nsu'] as String,
      entityIdentifier: json['entityIdentifier'] as String?,
    );
  }
}
