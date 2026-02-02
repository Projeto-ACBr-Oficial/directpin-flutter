import 'package:flutter/material.dart';
import '../constants.dart';
import '../helpers/transaction_helper.dart';

/// Tela de entrada de valor com teclado numérico (estilo PDV).
/// Exibe R$ 0,00 no topo, teclado 1-9, 0, X (limpar), backspace, e botão Pagar.
class AmountEntryScreen extends StatefulWidget {
  final void Function(int amountCents) onPay;

  const AmountEntryScreen({
    super.key,
    required this.onPay,
  });

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  /// Valor em centavos (apenas dígitos; a formatação é feita na exibição)
  int _amountCents = 0;

  static const int _maxCents = 99999999; // R$ 999.999,99

  void _onDigit(int digit) {
    setState(() {
      final newAmount = _amountCents * 10 + digit;
      if (newAmount <= _maxCents) {
        _amountCents = newAmount;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _amountCents = _amountCents ~/ 10;
    });
  }

  void _onClear() {
    setState(() {
      _amountCents = 0;
    });
  }

  void _onPagar() {
    if (_amountCents < TransactionConstants.minAmount) return;
    widget.onPay(_amountCents);
  }

  bool get _canPay => _amountCents >= TransactionConstants.minAmount;

  @override
  Widget build(BuildContext context) {
    final displayText = TransactionHelper.formatAmount(_amountCents);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transação'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Campo de exibição do valor
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Teclado numérico
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    final keySize = (constraints.maxWidth - spacing * 2) / 3;
                    final keyHeight = (constraints.maxHeight - spacing * 3 - 56) / 4; // 4 linhas, botão Pagar abaixo
                    final keyH = keyHeight.clamp(48.0, 72.0);

                    return Column(
                      children: [
                        // Linhas 1, 2, 3 (1-9)
                        Expanded(
                          child: Column(
                            children: [
                              _keypadRow(context, primaryColor, [1, 2, 3], keySize, keyH, _onDigit),
                              SizedBox(height: spacing),
                              _keypadRow(context, primaryColor, [4, 5, 6], keySize, keyH, _onDigit),
                              SizedBox(height: spacing),
                              _keypadRow(context, primaryColor, [7, 8, 9], keySize, keyH, _onDigit),
                              SizedBox(height: spacing),
                              // Linha 4: X, 0, backspace
                              Row(
                                children: [
                                  _keypadKey(
                                    context,
                                    label: 'X',
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    width: keySize,
                                    height: keyH,
                                    onTap: _onClear,
                                  ),
                                  SizedBox(width: spacing),
                                  _keypadKey(
                                    context,
                                    label: '0',
                                    backgroundColor: primaryColor.withOpacity(0.15),
                                    foregroundColor: primaryColor,
                                    width: keySize,
                                    height: keyH,
                                    onTap: () => _onDigit(0),
                                  ),
                                  SizedBox(width: spacing),
                                  _keypadKey(
                                    context,
                                    icon: Icons.backspace_outlined,
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    width: keySize,
                                    height: keyH,
                                    onTap: _onBackspace,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botão Pagar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _canPay ? _onPagar : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Pagar'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keypadRow(
    BuildContext context,
    Color primaryColor,
    List<int> digits,
    double keyWidth,
    double keyHeight,
    void Function(int) onDigit,
  ) {
    return Row(
      children: digits
          .map((d) => Padding(
                padding: EdgeInsets.only(right: d == digits.last ? 0 : 12),
                child: _keypadKey(
                  context,
                  label: '$d',
                  backgroundColor: primaryColor.withOpacity(0.15),
                  foregroundColor: primaryColor,
                  width: keyWidth,
                  height: keyHeight,
                  onTap: () => onDigit(d),
                ),
              ))
          .toList(),
    );
  }

  Widget _keypadKey(
    BuildContext context, {
    String? label,
    IconData? icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: label != null
                ? Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  )
                : Icon(icon, color: foregroundColor, size: 28),
          ),
        ),
      ),
    );
  }
}
