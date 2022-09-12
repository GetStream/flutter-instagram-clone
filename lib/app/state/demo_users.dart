import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

/// Demo application users.
enum DemoAppUser {
  sahil,
  sacha,
  salvatore,
  gordon,
}

/// Convenient class Extension on [DemoAppUser] enum
extension DemoAppUserX on DemoAppUser {
  /// Convenient method Extension to generate an [id] from [DemoAppUser] enum
  String get id => {
        DemoAppUser.sahil: 'sahil-kumar',
        DemoAppUser.sacha: 'sacha-arbonel',
        DemoAppUser.salvatore: 'salvatore-giordano',
        DemoAppUser.gordon: 'gordon-hayes',
      }[this]!;

  /// Convenient method Extension to generate a [name] from [DemoAppUser] enum
  String? get name => {
        DemoAppUser.sahil: 'Sahil Kumar',
        DemoAppUser.sacha: 'Sacha Arbonel',
        DemoAppUser.salvatore: 'Salvatore Giordano',
        DemoAppUser.gordon: 'Gordon Hayes',
      }[this];

  /// Convenient method Extension to generate [data] from [DemoAppUser] enum
  Map<String, Object>? get data => {
        DemoAppUser.sahil: {
          'first_name': 'Sahil',
          'last_name': 'Kumar',
          'full_name': 'Sahil Kumar',
        },
        DemoAppUser.sacha: {
          'first_name': 'Sacha',
          'last_name': 'Arbonel',
          'full_name': 'Sacha Arbonel',
        },
        DemoAppUser.salvatore: {
          'first_name': 'Salvatore',
          'last_name': 'Giordano',
          'full_name': 'Salvatore Giordano',
        },
        DemoAppUser.gordon: {
          'first_name': 'Gordon',
          'last_name': 'Hayes',
          'full_name': 'Gordon Hayes',
        },
      }[this];

  /// Convenient method Extension to generate a [token] from [DemoAppUser] enum
  Token? get token => <DemoAppUser, Token>{
        // TODO: Generate your own tokens if you're using your own API key.
        DemoAppUser.sahil: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoic2FoaWwta3VtYXIifQ.Ts_4yhx6P4syDdO5g0QKJXqcET-0UO3mZHY_tKbseoA'),
        DemoAppUser.sacha: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoic2FjaGEtYXJib25lbCJ9.atw_x8yl5bnhXbDKntlNtIVfLfQm9fe2xpaUuzIHHsM'),
        DemoAppUser.salvatore: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoic2FsdmF0b3JlLWdpb3JkYW5vIn0.C3sS6UM6LhZbM2evWaIDlp8N_V3g11fvah9Llk3Gs4w'),
        DemoAppUser.gordon: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZ29yZG9uLWhheWVzIn0.q0C65xjNtMdZ62pHcVodSjP6SqVh_BL9GNYavnp0l-4'),
      }[this];
}
