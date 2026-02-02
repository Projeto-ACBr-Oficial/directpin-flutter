/// Modelo de resposta de cancelamento de transação
class CancelTransactionResponse {
  final String type;
  final bool result;
  final String message;
  final String receiptContent;

  CancelTransactionResponse({
    required this.type,
    required this.result,
    required this.message,
    this.receiptContent = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'result': result,
      'message': message,
      'receiptContent': receiptContent,
    };
  }

  factory CancelTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CancelTransactionResponse(
      type: json['type'] as String,
      result: json['result'] as bool,
      message: json['message'] as String,
      receiptContent: json['receiptContent'] as String? ?? "",
    );
  }
}
