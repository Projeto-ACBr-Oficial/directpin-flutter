/// Modelo de resposta de transação
class TransactionResponse {
  final String type;
  final bool result;
  final String message;
  final int amount;
  final String nsu;
  final String nsuAcquirer;
  final String panMasked;
  final int date;
  final String typeCard;
  final String finalResult;
  final int codeResult;
  final String receiptContent;
  final String serialNumber;
  final String brand;
  final String authCode;

  TransactionResponse({
    required this.type,
    required this.result,
    required this.message,
    this.amount = 0,
    this.nsu = "",
    this.nsuAcquirer = "",
    this.panMasked = "",
    this.date = 0,
    this.typeCard = "",
    this.finalResult = "",
    this.codeResult = 0,
    this.receiptContent = "",
    this.serialNumber = "",
    this.brand = "",
    this.authCode = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'result': result,
      'message': message,
      'amount': amount,
      'nsu': nsu,
      'nsuAcquirer': nsuAcquirer,
      'panMasked': panMasked,
      'date': date,
      'typeCard': typeCard,
      'finalResult': finalResult,
      'codeResult': codeResult,
      'receiptContent': receiptContent,
      'serialNumber': serialNumber,
      'brand': brand,
      'authCode': authCode,
    };
  }

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      type: json['type'] as String,
      result: json['result'] as bool,
      message: json['message'] as String,
      amount: json['amount'] as int? ?? 0,
      nsu: json['nsu'] as String? ?? "",
      nsuAcquirer: json['nsuAcquirer'] as String? ?? "",
      panMasked: json['panMasked'] as String? ?? "",
      date: json['date'] as int? ?? 0,
      typeCard: json['typeCard'] as String? ?? "",
      finalResult: json['finalResult'] as String? ?? "",
      codeResult: json['codeResult'] as int? ?? 0,
      receiptContent: json['receiptContent'] as String? ?? "",
      serialNumber: json['serialNumber'] as String? ?? "",
      brand: json['brand'] as String? ?? "",
      authCode: json['authCode'] as String? ?? "",
    );
  }
}
