import 'package:flutter/material.dart';
import 'screens/init_screen.dart';
import 'screens/amount_entry_screen.dart';
import 'screens/payment_type_screen.dart';
import 'screens/cancel_transaction_screen.dart';
import 'models/transaction_response.dart';

enum Screen { init, transaction, cancelTransaction }

/// Sub-telas do fluxo de transação: valor → tipo de pagamento
enum TransactionFlow { amountEntry, paymentType }

void main() {
  runApp(const DirectPinApp());
}

class DirectPinApp extends StatelessWidget {
  const DirectPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DirectPin',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2E7D32),
          onPrimary: const Color(0xFFFFFFFF),
          primaryContainer: const Color(0xFFC8E6C9),
          onPrimaryContainer: const Color(0xFF1B5E20),
          secondary: const Color(0xFF556B2F),
          onSecondary: const Color(0xFFFFFFFF),
          secondaryContainer: const Color(0xFFDCE5C4),
          onSecondaryContainer: const Color(0xFF1A2E05),
          tertiary: const Color(0xFF386A20),
          onTertiary: const Color(0xFFFFFFFF),
          tertiaryContainer: const Color(0xFFB8F397),
          onTertiaryContainer: const Color(0xFF022100),
          error: const Color(0xFFB3261E),
          onError: const Color(0xFFFFFFFF),
          errorContainer: const Color(0xFFF9DEDC),
          onErrorContainer: const Color(0xFF410E0B),
          surface: const Color(0xFFF8FBF8),
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFE8F5E9),
          onSurfaceVariant: const Color(0xFF424942),
          outline: const Color(0xFF727971),
          outlineVariant: const Color(0xFFC8E6C9),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFA5D6A7),
          onPrimary: const Color(0xFF003910),
          primaryContainer: const Color(0xFF1B5E20),
          onPrimaryContainer: const Color(0xFFC8E6C9),
          secondary: const Color(0xFF556B2F),
          onSecondary: const Color(0xFFFFFFFF),
          secondaryContainer: const Color(0xFFDCE5C4),
          onSecondaryContainer: const Color(0xFF1A2E05),
          tertiary: const Color(0xFF386A20),
          onTertiary: const Color(0xFFFFFFFF),
          tertiaryContainer: const Color(0xFFB8F397),
          onTertiaryContainer: const Color(0xFF022100),
          error: const Color(0xFFB3261E),
          onError: const Color(0xFFFFFFFF),
          errorContainer: const Color(0xFFF9DEDC),
          onErrorContainer: const Color(0xFF410E0B),
          surface: const Color(0xFF1C1B1F),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF2D3B2D),
          onSurfaceVariant: const Color(0xFFC8E6C9),
          outline: const Color(0xFF8B9389),
          outlineVariant: const Color(0xFF424942),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DirectPinHome(),
    );
  }
}

class DirectPinHome extends StatefulWidget {
  const DirectPinHome({super.key});

  @override
  State<DirectPinHome> createState() => _DirectPinHomeState();
}

class _DirectPinHomeState extends State<DirectPinHome> {
  Screen _currentScreen = Screen.init;
  TransactionFlow _transactionFlow = TransactionFlow.amountEntry;
  int? _pendingAmountCents;
  TransactionResponse? _transactionResponse;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Se não inicializou, mostra apenas a InitScreen sem menu
    if (!_isInitialized) {
      return InitScreen(
        onSuccess: (response) {
          setState(() {
            _isInitialized = true;
            _currentScreen = Screen.transaction;
          });
        },
      );
    }

    // Após inicialização, mostra o menu com Transação e Cancelar
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentScreen == Screen.transaction ? 0 : 1,
        onDestinationSelected: (index) {
          setState(() {
            _currentScreen = index == 0 ? Screen.transaction : Screen.cancelTransaction;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.payment_outlined),
            selectedIcon: Icon(Icons.payment),
            label: 'Transação',
          ),
          NavigationDestination(
            icon: Icon(Icons.cancel_outlined),
            selectedIcon: Icon(Icons.cancel),
            label: 'Cancelar',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case Screen.init:
        return InitScreen(
          onSuccess: (response) {
            setState(() {
              _isInitialized = true;
              _currentScreen = Screen.transaction;
            });
          },
        );
      case Screen.transaction:
        if (_transactionFlow == TransactionFlow.amountEntry) {
          return AmountEntryScreen(
            onPay: (amountCents) {
              setState(() {
                _pendingAmountCents = amountCents;
                _transactionFlow = TransactionFlow.paymentType;
              });
            },
          );
        }
        return PaymentTypeScreen(
          amountCents: _pendingAmountCents!,
          onFinish: (response) {
            setState(() {
              _transactionResponse = response;
              _transactionFlow = TransactionFlow.amountEntry;
              _pendingAmountCents = null;
            });
          },
          onBack: () {
            setState(() {
              _transactionFlow = TransactionFlow.amountEntry;
              _pendingAmountCents = null;
            });
          },
        );
      case Screen.cancelTransaction:
        return CancelTransactionScreen(
          initialNsu: _transactionResponse?.nsu,
          onFinish: (response) {
            // Resposta tratada, mas não muda a tela automaticamente
          },
        );
    }
  }
}
