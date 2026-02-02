import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/init_request.dart';
import '../models/init_response.dart';
import '../helpers/direct_pin_intent_helper.dart';

class InitScreen extends StatefulWidget {
  final Function(InitResponse) onSuccess;

  const InitScreen({
    super.key,
    required this.onSuccess,
  });

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _processing = false;
  InitResponse? _initResponse;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  bool get _isValid => _tokenController.text.length == 4;

  Future<void> _sendRequest() async {
    if (!_isValid) return;

    setState(() {
      _processing = true;
      _initResponse = null;
    });

    try {
      final request = InitRequest(
        type: Constants.requestTypeInit,
        token: _tokenController.text,
      );

      final result = await DirectPinIntentHelper.sendRequestAndWaitForResult(
        request.toJson(),
      );

      if (result != null) {
        final response = DirectPinIntentHelper.processResponse<InitResponse>(
          result,
          fromJson: (json) => InitResponse.fromJson(json),
        );

        if (response != null) {
          setState(() {
            _initResponse = response;
          });
        }
      }
    } catch (e) {
      print('Error sending init request: $e');
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

  void _showResultDialog(InitResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          response.result ? Icons.check_circle : Icons.info_outline,
          color: response.result
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          size: 48,
        ),
        title: Text(response.result ? 'Sucesso' : 'Resultado'),
        content: Text(response.message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (response.result) {
                widget.onSuccess(response);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      // Limpa a resposta após fechar o dialog
      setState(() {
        _initResponse = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostra dialog de resultado se houver resposta
    if (_initResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog(_initResponse!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DirectPin'),
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
                  const Text(
                    'Inicialização',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Insira o token de 4 dígitos para conectar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: InputDecoration(
                      labelText: 'Token',
                      hintText: '••••',
                      errorText: _tokenController.text.isNotEmpty && !_isValid
                          ? 'O token deve ter 4 dígitos'
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
                      child: _processing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Iniciar'),
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
