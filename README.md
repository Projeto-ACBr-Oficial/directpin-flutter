# DirectPin Sample - Flutter

Este é um projeto Flutter que demonstra como integrar com o DirectPin Route através de Android Intents.

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── constants.dart               # Constantes do DirectPin
├── models/                      # Modelos de dados
│   ├── init_request.dart
│   ├── init_response.dart
│   ├── transaction_request.dart
│   ├── transaction_response.dart
│   ├── cancel_transaction_request.dart
│   ├── cancel_transaction_response.dart
│   └── abort_request.dart
├── helpers/                     # Classes auxiliares
│   ├── direct_pin_intent_helper.dart
│   └── transaction_helper.dart
└── screens/                     # Telas da aplicação
    ├── init_screen.dart
    ├── transaction_screen.dart
    └── cancel_transaction_screen.dart
```

## Funcionalidades

1. **Inicialização (Init)**: Inicializa a conexão com o DirectPin usando um token de 4 dígitos
2. **Transação**: Permite realizar transações de débito, crédito, voucher, PIX ou nenhum tipo
3. **Cancelamento**: Cancela uma transação usando o NSU

## Dependências

- `flutter`: SDK Flutter
- `android_intent_plus`: Para comunicação com Android Intents
- `intl`: Para formatação de valores monetários

## Configuração Android

O projeto inclui uma `MainActivity` customizada em Kotlin que gerencia a comunicação com o DirectPin através de MethodChannel.

### Intent Action

O DirectPin usa a seguinte action:
```
br.com.inovare.directpin_intent.action.PROCESS
```

## Como Usar

1. Instale as dependências:
```bash
flutter pub get
```

2. Execute o app:
```bash
flutter run
```

## Requisitos

- Flutter SDK 3.9.2 ou superior
- Android SDK (para funcionalidade de Intents)
- DirectPin Route instalado no dispositivo Android

## Notas

- A comunicação com o DirectPin é feita através de Android Intents
- O resultado das operações é retornado via MethodChannel
