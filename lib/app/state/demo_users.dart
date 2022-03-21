import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

/// Demo application users.
enum DemoAppUser {
  sahil,
  sacha,
  reuben,
  gordon,
}

/// Convenient class Extension on [DemoAppUser] enum
extension DemoAppUserX on DemoAppUser {
  /// Convenient method Extension to generate an [id] from [DemoAppUser] enum
  String? get id => {
        DemoAppUser.sahil: 'sahil-kumar',
        DemoAppUser.sacha: 'sacha-arbonel',
        DemoAppUser.reuben: 'reuben-turner',
        DemoAppUser.gordon: 'gordon-hayes',
      }[this];

  /// Convenient method Extension to generate a [name] from [DemoAppUser] enum
  String? get name => {
        DemoAppUser.sahil: 'Sahil Kumar',
        DemoAppUser.sacha: 'Sacha Arbonel',
        DemoAppUser.reuben: 'Reuben Turner',
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
        DemoAppUser.reuben: {
          'first_name': 'Reuben',
          'last_name': 'Turner',
          'full_name': 'Reuben Turner',
        },
        DemoAppUser.gordon: {
          'first_name': 'Gordon',
          'last_name': 'Hayes',
          'full_name': 'Gordon Hayes',
        },
      }[this];

  /// Convenient method Extension to generate a [token] from [DemoAppUser] enum
  Token? get token => <DemoAppUser, Token>{
        DemoAppUser.sahil: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDg4ODk0NTUsInVzZXJfaWQiOiJzYWhpbC1rdW1hciJ9.2f9_zF2zbThGmVRPlBLPh3BiZ7dWMLELUnQBxoNLnx8'),
        DemoAppUser.sacha: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDg4ODk0NDQsInVzZXJfaWQiOiJzYWNoYS1hcmJvbmVsIn0.kxG7JQTtZDEWbtaG687FvzLRXDb5mAzbotGPGoGP_7c'),
        DemoAppUser.reuben: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDg4ODk0NTIsInVzZXJfaWQiOiJyZXViZW4tdHVybmVyIn0.ED5YxMbVj_J10niTRNKmZvnxiBjBBryDWFtWhWCPSSI'),
        DemoAppUser.gordon: const Token(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDg4ODk0MTgsInVzZXJfaWQiOiJnb3Jkb24taGF5ZXMifQ.pGk1B6CrDRB2QGr_OOLesxPTwaQ0um_9A8unQcW-Sbs'),
      }[this];
}
