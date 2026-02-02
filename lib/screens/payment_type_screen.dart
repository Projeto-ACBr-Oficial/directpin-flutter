import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/transaction_response.dart';
import '../helpers/direct_pin_intent_helper.dart';
import '../helpers/transaction_helper.dart';

/// Opções de pagamento: débito, PIX, crédito à vista, parcelado estabelecimento, parcelado emissor.
enum PaymentOption {
  debito,
  pix,
  avista,
  parceladoEstabelecimento,
  parceladoEmissor,
}

/// Tela para escolher tipo de pagamento (à vista, parcelado est./emissor) e parcelas.
class PaymentTypeScreen extends StatefulWidget {
  /// Valor em centavos já informado na tela anterior.
  final int amountCents;
  final void Function(TransactionResponse?) onFinish;
  final VoidCallback? onBack;

  const PaymentTypeScreen({
    super.key,
    required this.amountCents,
    required this.onFinish,
    this.onBack,
  });

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  PaymentOption _option = PaymentOption.debito;
  final TextEditingController _installmentsController = TextEditingController(text: '2');
  bool _processing = false;
  TransactionResponse? _transactionResponse;
  String? _errorMessage;

  @override
  void dispose() {
    _installmentsController.dispose();
    super.dispose();
  }

  bool get _isParcelado =>
      _option == PaymentOption.parceladoEstabelecimento ||
      _option == PaymentOption.parceladoEmissor;

  bool get _isValidInstallments {
    if (!_isParcelado) return true;
    final n = int.tryParse(_installmentsController.text);
    return n != null && n >= 1 && n <= 99;
  }

  bool get _canConfirm => !_processing && (!_isParcelado || _isValidInstallments);

  Future<void> _confirmAndSend() async {
    if (!_canConfirm) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
      _transactionResponse = null;
    });

    try {
      final transactionType = _option == PaymentOption.debito
          ? TransactionConstants.typeDebit
          : _option == PaymentOption.pix
              ? TransactionConstants.typePix
              : TransactionConstants.typeCredit;
      final creditType = _isParcelado
          ? TransactionConstants.creditInstallment
          : TransactionConstants.creditNoInstallment;
      final installments = _isParcelado
          ? (int.tryParse(_installmentsController.text) ?? 2).toString()
          : '1';
      final interestType = _option == PaymentOption.parceladoEstabelecimento
          ? TransactionConstants.interestTypeMerchant
          : _option == PaymentOption.parceladoEmissor
              ? TransactionConstants.interestTypeIssuer
              : TransactionConstants.defaultInterestType;

      final request = TransactionHelper.createTransactionRequest(
        amountDigits: widget.amountCents.toString(),
        transactionType: transactionType,
        creditType: creditType,
        installments: installments,
        interestType: interestType,
      );

      final result = await DirectPinIntentHelper.sendRequestAndWaitForResult(
        request.toJson(),
      );

      if (result != null) {
        final response = DirectPinIntentHelper.processResponse<TransactionResponse>(
          result,
          fromJson: (json) => TransactionResponse.fromJson(json),
        );
        if (response != null) {
          setState(() => _transactionResponse = response);
          widget.onFinish(response);
        } else {
          setState(() => _errorMessage = 'Erro ao processar resposta');
        }
      } else {
        setState(() => _errorMessage = 'Nenhuma resposta recebida');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  void _showResultDialog(TransactionResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('Resultado'),
        content: Text(response.message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Erro'),
        content: Text(error),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_transactionResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog(_transactionResponse!);
        setState(() => _transactionResponse = null);
      });
    }
    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(_errorMessage!);
        setState(() => _errorMessage = null);
      });
    }

    final amountFormatted = TransactionHelper.formatAmount(widget.amountCents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de pagamento'),
        centerTitle: true,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amountFormatted,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Como deseja pagar?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _optionTile(
              option: PaymentOption.debito,
              title: 'Débito',
              subtitle: 'Pagamento à vista no débito',
              icon: Icons.credit_card,
            ),
            _optionTile(
              option: PaymentOption.pix,
              title: 'PIX',
              subtitle: 'Pagamento instantâneo via PIX',
              icon: Icons.qr_code_2,
            ),
            _optionTile(
              option: PaymentOption.avista,
              title: 'Crédito à vista',
              subtitle: 'Crédito em uma única parcela',
              icon: Icons.payment,
            ),
            _optionTile(
              option: PaymentOption.parceladoEstabelecimento,
              title: 'Parcelado estabelecimento',
              subtitle: 'Parcelas com juros do estabelecimento',
              icon: Icons.store,
            ),
            _optionTile(
              option: PaymentOption.parceladoEmissor,
              title: 'Parcelado emissor',
              subtitle: 'Parcelas com juros do emissor',
              icon: Icons.account_balance_wallet_outlined,
            ),
            if (_isParcelado) ...[
              const SizedBox(height: 24),
              Text(
                'Número de parcelas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _installmentsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  labelText: 'Parcelas (1 a 99)',
                  hintText: 'Ex: 3',
                  errorText: _installmentsController.text.isNotEmpty && !_isValidInstallments
                      ? 'Informe entre 1 e 99 parcelas'
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _canConfirm ? _confirmAndSend : null,
                child: _processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar e pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required PaymentOption option,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _option == option;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _option = option),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
