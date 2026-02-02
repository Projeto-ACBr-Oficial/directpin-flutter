import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/cancel_transaction_request.dart';
import '../models/cancel_transaction_response.dart';
import '../helpers/direct_pin_intent_helper.dart';

class CancelTransactionScreen extends StatefulWidget {
  final String? initialNsu;
  final Function(CancelTransactionResponse?) onFinish;

  const CancelTransactionScreen({
    super.key,
    this.initialNsu,
    required this.onFinish,
  });

  @override
  State<CancelTransactionScreen> createState() => _CancelTransactionScreenState();
}

class _CancelTransactionScreenState extends State<CancelTransactionScreen> {
  final TextEditingController _nsuController = TextEditingController();
  bool _processing = false;
  CancelTransactionResponse? _cancelResponse;

  @override
  void initState() {
    super.initState();
    if (widget.initialNsu != null && widget.initialNsu!.isNotEmpty) {
      _nsuController.text = widget.initialNsu!;
    }
  }

  @override
  void dispose() {
    _nsuController.dispose();
    super.dispose();
  }

  bool get _isValid => _nsuController.text.trim().isNotEmpty;

  Future<void> _sendRequest() async {
    if (!_isValid) return;

    setState(() {
      _processing = true;
      _cancelResponse = null;
    });

    try {
      final request = CancelTransactionRequest(
        type: Constants.requestTypeCancelTransaction,
        nsu: _nsuController.text.trim(),
      );

      final result = await DirectPinIntentHelper.sendRequestAndWaitForResult(
        request.toJson(),
      );

      if (result != null) {
        final response = DirectPinIntentHelper.processResponse<CancelTransactionResponse>(
          result,
          fromJson: (json) => CancelTransactionResponse.fromJson(json),
        );

        if (response != null) {
          setState(() {
            _cancelResponse = response;
          });
          widget.onFinish(response);
        }
      }
    } catch (e) {
      print('Error sending cancel transaction request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  void _showResultDialog(CancelTransactionResponse response) {
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

  @override
  Widget build(BuildContext context) {
    // Mostra dialog de resultado se houver resposta
    if (_cancelResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog(_cancelResponse!);
        setState(() {
          _cancelResponse = null;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancelar Transação'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cancelar Transação',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Informe o NSU da transação que deseja cancelar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nsuController,
                    decoration: InputDecoration(
                      labelText: 'NSU da Transação',
                      hintText: 'Digite o NSU',
                      errorText: _nsuController.text.isNotEmpty && !_isValid
                          ? 'O NSU é obrigatório'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (_isValid) {
                        FocusScope.of(context).unfocus();
                        _sendRequest();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isValid && !_processing ? _sendRequest : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: _processing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cancelar Transação'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
