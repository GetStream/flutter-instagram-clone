import 'package:flutter/material.dart';

/// Global reference to application colors.
abstract class AppColors {
  /// Dark color.
  static const dark = Colors.black;

  static const light = Color(0xFFFAFAFA);

  /// Grey background accent.
  static const grey = Color(0xFF262626);

  /// Primary text color
  static const primaryText = Colors.white;

  /// Secondary color.
  static const secondary = Color(0xFF0095F6);

  /// Color to use for favorite icons (indicating a like).
  static const like = Colors.red;

  /// Grey faded color.
  static const faded = Colors.grey;

  /// Light grey color
  static const ligthGrey = Color(0xFFEEEEEE);

  /// Top gradient color used in various UI components.
  static const topGradient = Color(0xFFE60064);

  /// Bottom gradient color used in various UI components.
  static const bottomGradient = Color(0xFFFFB344);
}

/// Global reference to application [TextStyle]s.
abstract class AppTextStyle {
  /// A medium bold text style.
  static const textStyleBoldMedium = TextStyle(
    fontWeight: FontWeight.w600,
  );

  /// A bold text style.
  static const textStyleBold = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const textStyleSmallBold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  /// A faded text style. Uses [AppColors.faded].
  static const textStyleFaded =
      TextStyle(color: AppColors.faded, fontWeight: FontWeight.w400);

  /// A faded text style. Uses [AppColors.faded].
  static const textStyleFadedSmall = TextStyle(
      color: AppColors.faded, fontWeight: FontWeight.w400, fontSize: 11);

  /// A faded text style. Uses [AppColors.faded].
  static const textStyleFadedSmallBold = TextStyle(
      color: AppColors.faded, fontWeight: FontWeight.w500, fontSize: 11);

  /// Light text style.
  static const textStyleLight = TextStyle(fontWeight: FontWeight.w300);

  /// Action text
  static const textStyleAction = TextStyle(
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );
}

/// Global reference to the application theme.
class AppTheme {
  final _darkBase = ThemeData.dark();
  final _lightBase = ThemeData.light();

  /// Dark theme and its settings.
  ThemeData get darkTheme => _darkBase.copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: AppColors.dark,
        scaffoldBackgroundColor: AppColors.dark,
        appBarTheme: _darkBase.appBarTheme.copyWith(
          backgroundColor: AppColors.dark,
          foregroundColor: AppColors.light,
          iconTheme: const IconThemeData(color: AppColors.light),
          elevation: 0,
        ),
        bottomNavigationBarTheme: _darkBase.bottomNavigationBarTheme.copyWith(
          backgroundColor: AppColors.dark,
          selectedItemColor: AppColors.light,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStateProperty.all(
              const BorderSide(
                color: AppColors.grey,
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.light,
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColors.dark,
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.grey,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColors.secondary,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.primaryText,
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.grey,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.secondary,
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.grey,
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        brightness: Brightness.dark,
        colorScheme:
            _darkBase.colorScheme.copyWith(secondary: AppColors.secondary),
      );

  ThemeData get lightTheme => _lightBase.copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: AppColors.light,
        scaffoldBackgroundColor: AppColors.light,
        appBarTheme: _lightBase.appBarTheme.copyWith(
          backgroundColor: AppColors.light,
          foregroundColor: AppColors.dark,
          iconTheme: const IconThemeData(color: AppColors.dark),
          elevation: 0,
        ),
        bottomNavigationBarTheme: _lightBase.bottomNavigationBarTheme.copyWith(
          backgroundColor: AppColors.light,
          selectedItemColor: AppColors.dark,
        ),
        snackBarTheme:
            _lightBase.snackBarTheme.copyWith(backgroundColor: AppColors.dark),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStateProperty.all(
              const BorderSide(
                color: AppColors.ligthGrey,
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.dark,
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColors.light,
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.ligthGrey,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColors.secondary,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.primaryText,
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.ligthGrey,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              AppColors.secondary,
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              AppColors.ligthGrey,
            ),
          ),
        ),
        brightness: Brightness.light,
        colorScheme:
            _lightBase.colorScheme.copyWith(secondary: AppColors.secondary),
      );
}
