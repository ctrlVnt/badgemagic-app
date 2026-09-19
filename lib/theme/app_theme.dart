import 'package:badgemagic/theme/color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const double borderRadiusValue = 12.0;
  static final BorderRadius borderRadius = BorderRadius.circular(borderRadiusValue);
  static final OutlinedBorder roundedShape = RoundedRectangleBorder(borderRadius: borderRadius);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: colorPrimary,
        onPrimary: colorOnPrimary,
        secondary: colorAccent,
        onSecondary: colorOnPrimary,
        error: colorError,
        onError: colorOnPrimary,
        surface: colorSurface,
        onSurface: colorOnSurface,
        surfaceContainer: colorSurfaceSubtle,
        outline: colorBorder,
      ),
      scaffoldBackgroundColor: colorSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: colorPrimary,
        foregroundColor: colorOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: colorOnPrimary,
        ),
        iconTheme: IconThemeData(color: colorOnPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorSurface,
        surfaceTintColor: colorTransparent,
        elevation: 4,
        shape: roundedShape,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorOnSurface,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: colorOnSurface,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStatePropertyAll(roundedShape),
          elevation: const WidgetStatePropertyAll(4),
          backgroundColor: const WidgetStatePropertyAll(colorSurface),
          surfaceTintColor: const WidgetStatePropertyAll(colorSurface),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: MenuItemButton.styleFrom(
          shape: roundedShape,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: roundedShape,
        elevation: 4,
        color: colorSurface,
        surfaceTintColor: colorSurface,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(roundedShape),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorSurface,
        surfaceTintColor: colorTransparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadiusValue)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorPrimary,
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: colorOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorSurfaceMuted,
          foregroundColor: colorTextStrong,
          elevation: 0,
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorPrimary,
          side: const BorderSide(color: colorPrimary),
          shape: roundedShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: colorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: colorError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: colorError, width: 2),
        ),
        hintStyle: const TextStyle(color: colorTextMuted),
        labelStyle: const TextStyle(color: colorTextStrong),
      ),
      cardTheme: CardThemeData(
        color: colorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: colorBorder),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorPrimary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorPrimary;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(colorOnPrimary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorPrimary;
          }
          return colorSurfaceMuted;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: colorBorder,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: colorPrimary,
        unselectedLabelColor: mdGrey400,
        indicatorColor: colorPrimary,
      ),
    );
  }
}
