import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/transaction_request.dart';

/// Helper para operações de transação
class TransactionHelper {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  /// Formata valor em centavos para exibição em reais
  static String formatAmount(int amountInCents) {
    return _currencyFormat.format(amountInCents / 100.0);
  }

  /// Extrai apenas dígitos de uma string
  static String extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Obtém o label do tipo de transação
  static String getTransactionTypeLabel(String type) {
    switch (type) {
      case TransactionConstants.typeDebit:
        return TransactionConstants.labelDebit;
      case TransactionConstants.typeCredit:
        return TransactionConstants.labelCredit;
      case TransactionConstants.typeVoucher:
        return TransactionConstants.labelVoucher;
      case TransactionConstants.typePix:
        return TransactionConstants.labelPix;
      case TransactionConstants.typeNone:
        return TransactionConstants.labelNone;
      default:
        return TransactionConstants.labelDebit;
    }
  }

  /// Obtém o label do tipo de crédito
  static String getCreditTypeLabel(String type) {
    switch (type) {
      case TransactionConstants.creditInstallment:
        return TransactionConstants.labelInstallment;
      case TransactionConstants.creditNoInstallment:
        return TransactionConstants.labelNoInstallment;
      default:
        return TransactionConstants.labelNoInstallment;
    }
  }

  /// Valida se o valor é válido
  static bool isValidAmount(String amountDigits) {
    final amount = int.tryParse(amountDigits) ?? 0;
    return amount >= TransactionConstants.minAmount;
  }

  /// Valida se o número de parcelas é válido
  static bool isValidInstallments(String installments) {
    final value = int.tryParse(installments) ?? 0;
    return value >= 1 && value <= 99;
  }

  /// Cria a requisição de transação
  static TransactionRequest createTransactionRequest({
    required String amountDigits,
    required String transactionType,
    required String creditType,
    required String installments,
    String? interestType,
  }) {
    final amount = int.tryParse(amountDigits) ?? 0;
    final finalCreditType = transactionType == TransactionConstants.typeCredit
        ? creditType
        : TransactionConstants.creditNoInstallment;

    final finalInstallments = finalCreditType == TransactionConstants.creditInstallment
        ? (int.tryParse(installments) ?? TransactionConstants.defaultInstallments)
        : TransactionConstants.defaultInstallments;

    return TransactionRequest(
      type: TransactionConstants.requestType,
      amount: amount,
      typeTransaction: transactionType,
      creditType: finalCreditType,
      installment: finalInstallments,
      isTyped: false,
      isPreAuth: false,
      interestType: interestType ?? TransactionConstants.defaultInterestType,
      printReceipt: true,
    );
  }
}
