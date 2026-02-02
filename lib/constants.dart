/// Constantes do DirectPin
class Constants {
  // Intent Actions
  static const String directPinAction = "br.com.inovare.directpin_intent.action.PROCESS";
  static const String directPinAbortAction = "br.com.inovare.directpin_intent.action.ABORT";

  // Request Types
  static const String requestTypeInit = "init";
  static const String requestTypeTransaction = "TRANSACTION";
  static const String requestTypeCancelTransaction = "cancelTransaction";
  static const String requestTypeAbort = "abort";
}

/// Constantes de transação
class TransactionConstants {
  // Tipos de transação
  static const String typeDebit = "DEBIT";
  static const String typeCredit = "CREDIT";
  static const String typeVoucher = "VOUCHER";
  static const String typePix = "PIX";
  static const String typeNone = "NONE";

  // Labels dos tipos de transação
  static const String labelDebit = "débito";
  static const String labelCredit = "crédito";
  static const String labelVoucher = "voucher";
  static const String labelPix = "pix";
  static const String labelNone = "nenhum";

  // Tipos de crédito
  static const String creditInstallment = "INSTALLMENT";
  static const String creditNoInstallment = "NO_INSTALLMENT";

  // Labels dos tipos de crédito
  static const String labelInstallment = "Com parcelas";
  static const String labelNoInstallment = "Sem parcelas";

  // Tipo de parcelamento (juros)
  static const String interestTypeMerchant = "MERCHANT"; // Parcelado estabelecimento
  static const String interestTypeIssuer = "ISSUER";     // Parcelado emissor

  // Configurações padrão
  static const int defaultInstallments = 1;
  static const String defaultInterestType = "MERCHANT";
  static const String requestType = "TRANSACTION";

  // Validação
  static const int minAmount = 1; // Mínimo de 1 centavo
}
