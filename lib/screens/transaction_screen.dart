import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/transaction_response.dart';
import '../helpers/direct_pin_intent_helper.dart';
import '../helpers/transaction_helper.dart';

class TransactionScreen extends StatefulWidget {
  final Function(TransactionResponse?) onFinish;

  const TransactionScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _installmentsController = TextEditingController(text: '1');
  
  String _transactionType = TransactionConstants.typeDebit;
  String _creditType = TransactionConstants.creditNoInstallment;
  bool _processing = false;
  TransactionResponse? _transactionResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _installmentsController.text = '1';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  bool get _isValidAmount => TransactionHelper.isValidAmount(
        TransactionHelper.extractDigits(_amountController.text),
      );
  bool get _isValidInstallments => TransactionHelper.isValidInstallments(
        _installmentsController.text,
      );
  bool get _isCreditTransaction => _transactionType == TransactionConstants.typeCredit;
  bool get _isInstallmentCredit => _isCreditTransaction &&
      _creditType == TransactionConstants.creditInstallment;
  bool get _canSubmit => _isValidAmount &&
      (!_isInstallmentCredit || _isValidInstallments) &&
      !_processing;

  Future<void> _sendTransaction() async {
    setState(() {
      _errorMessage = null;
      _processing = true;
      _transactionResponse = null;
    });

    try {
      final amountDigits = TransactionHelper.extractDigits(_amountController.text);
      final request = TransactionHelper.createTransactionRequest(
        amountDigits: amountDigits,
        transactionType: _transactionType,
        creditType: _creditType,
        installments: _installmentsController.text,
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
          setState(() {
            _transactionResponse = response;
          });
          widget.onFinish(response);
        } else {
          setState(() {
            _errorMessage = 'Erro ao processar resposta';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhuma resposta recebida';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar transação: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
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
    // Mostra dialog de resultado se houver resposta
    if (_transactionResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog(_transactionResponse!);
        setState(() {
          _transactionResponse = null;
        });
      });
    }

    // Mostra dialog de erro se houver
    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(_errorMessage!);
        setState(() {
          _errorMessage = null;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Valor e tipo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de valor
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        errorText: _amountController.text.isNotEmpty && !_isValidAmount
                            ? 'O valor mínimo é R\$ 0,01'
                            : null,
                      ),
                      onChanged: (value) {
                        final digits = TransactionHelper.extractDigits(value);
                        final formatted = TransactionHelper.formatAmount(
                          int.tryParse(digits) ?? 0,
                        );
                        if (formatted != value) {
                          _amountController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de tipo de transação
                    DropdownButtonFormField<String>(
                      initialValue: _transactionType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TransactionConstants.typeDebit,
                          child: Text(TransactionConstants.labelDebit),
                        ),
                        DropdownMenuItem(
                          value: TransactionConstants.typeCredit,
                          child: Text(TransactionConstants.labelCredit),
                        ),
                        DropdownMenuItem(
                          value: TransactionConstants.typeVoucher,
                          child: Text(TransactionConstants.labelVoucher),
                        ),
                        DropdownMenuItem(
                          value: TransactionConstants.typePix,
                          child: Text(TransactionConstants.labelPix),
                        ),
                        DropdownMenuItem(
                          value: TransactionConstants.typeNone,
                          child: Text(TransactionConstants.labelNone),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _transactionType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de tipo de crédito (apenas para crédito)
                    if (_isCreditTransaction) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _creditType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Crédito',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TransactionConstants.creditInstallment,
                            child: Text(TransactionConstants.labelInstallment),
                          ),
                          DropdownMenuItem(
                            value: TransactionConstants.creditNoInstallment,
                            child: Text(TransactionConstants.labelNoInstallment),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _creditType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de parcelas (apenas para crédito parcelado)
                      if (_isInstallmentCredit) ...[
                        TextField(
                          controller: _installmentsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Parcelas',
                            errorText: _installmentsController.text.isNotEmpty &&
                                    !_isValidInstallments
                                ? 'Número de parcelas deve ser entre 1 e 99'
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],

                    // Botão de envio
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _canSubmit ? _sendTransaction : null,
                        child: _processing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Enviar Transação'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
