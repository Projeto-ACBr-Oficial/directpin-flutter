/// Modelo de requisição de transação
class TransactionRequest {
  final String type;
  final int amount;
  final String typeTransaction;
  final String creditType;
  final int installment;
  final bool isTyped;
  final bool isPreAuth;
  final String interestType;
  final bool printReceipt;
  final String? entityIdentifier;

  TransactionRequest({
    required this.type,
    required this.amount,
    required this.typeTransaction,
    required this.creditType,
    required this.installment,
    required this.isTyped,
    required this.isPreAuth,
    required this.interestType,
    required this.printReceipt,
    this.entityIdentifier,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'typeTransaction': typeTransaction,
      'creditType': creditType,
      'installment': installment,
      'isTyped': isTyped,
      'isPreAuth': isPreAuth,
      'interestType': interestType,
      'printReceipt': printReceipt,
      if (entityIdentifier != null) 'entityIdentifier': entityIdentifier,
    };
  }

  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
      type: json['type'] as String,
      amount: json['amount'] as int,
      typeTransaction: json['typeTransaction'] as String,
      creditType: json['creditType'] as String,
      installment: json['installment'] as int,
      isTyped: json['isTyped'] as bool,
      isPreAuth: json['isPreAuth'] as bool,
      interestType: json['interestType'] as String,
      printReceipt: json['printReceipt'] as bool,
      entityIdentifier: json['entityIdentifier'] as String?,
    );
  }
}
