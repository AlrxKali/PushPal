import 'package:flutter/material.dart';

// App Color Palette
// To use hex colors directly: Color(0xFF007BFF)

// Primary Colors
// const Color electricBlue = Color(0xFF007BFF); // Old primary
const Color primaryOrange = Color(0xFFFF7043); // New primary: Energetic, trustworthy, motivates action
const Color appWhite = Color(0xFFFFFFFF);      // Clean and spacious background
const Color charcoal = Color(0xFF2D2D2D);    // Strong for text, contrast, and modern feel

// Secondary Colors
const Color limeGreen = Color(0xFF32CD32);    // Motivation, success (e.g. goal complete, streaks)
const Color warmRedCoral = Color(0xFFFF6347); // Reminders, missed check-ins, gentle nudges
// const Color softPurple = Color(0xFF...); // Example for other accents if needed
// const Color softTeal = Color(0xFF...);   // Example for other accents if needed

final ThemeData appThemeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryOrange,
  scaffoldBackgroundColor: appWhite,
  // Define the color scheme
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primaryOrange,
    onPrimary: appWhite, // Text/icons on primary color
    secondary: limeGreen, // Can be used for floating action buttons, active states etc.
    onSecondary: appWhite, // Text/icons on secondary color
    error: warmRedCoral,
    onError: appWhite,
    surface: appWhite, // Background for cards, dialogs etc.
    onSurface: charcoal, // Text/icons on surface color
    // For surface variants (slightly different background shades)
    surfaceVariant: Color(0xFFF0F0F0),
    onSurfaceVariant: charcoal,
    // Inverse primary (for dark themes or specific highlights)
    inversePrimary: appWhite, 
    // Outline color for borders, dividers
    outline: Color(0xFFBDBDBD),
    // Shadow color
    shadow: Color(0x40000000), // Black with some transparency
    // Inverse surface (for elements on dark backgrounds)
    inverseSurface: charcoal,
    onInverseSurface: appWhite,
    // Primary container (for larger areas needing primary color emphasis)
    primaryContainer: primaryOrange,
    onPrimaryContainer: appWhite,
    // Secondary container
    secondaryContainer: limeGreen,
    onSecondaryContainer: appWhite,
    // Tertiary color if needed, can be another accent or neutral
    tertiary: primaryOrange, // Can be same as primary or another accent
    onTertiary: appWhite,
    tertiaryContainer: primaryOrange,
    onTertiaryContainer: appWhite,
    // Surface tint (used for elevation overlays)
    surfaceTint: primaryOrange,
  ),
  // Define the Text Theme
  textTheme: const TextTheme(
    // Headlines
    displayLarge: TextStyle(color: charcoal, fontSize: 57.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: charcoal, fontSize: 45.0, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: charcoal, fontSize: 36.0, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: charcoal, fontSize: 32.0, fontWeight: FontWeight.normal),
    headlineMedium: TextStyle(color: charcoal, fontSize: 28.0, fontWeight: FontWeight.normal),
    headlineSmall: TextStyle(color: charcoal, fontSize: 24.0, fontWeight: FontWeight.normal),
    // Titles
    titleLarge: TextStyle(color: charcoal, fontSize: 22.0, fontWeight: FontWeight.w500), // Often used for AppBar titles
    titleMedium: TextStyle(color: charcoal, fontSize: 16.0, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: charcoal, fontSize: 14.0, fontWeight: FontWeight.w500),
    // Body text
    bodyLarge: TextStyle(color: charcoal, fontSize: 16.0, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(color: charcoal, fontSize: 14.0, fontWeight: FontWeight.normal), // Default text style
    bodySmall: TextStyle(color: charcoal, fontSize: 12.0, fontWeight: FontWeight.normal),
    // Labels (for buttons, captions etc.)
    labelLarge: TextStyle(color: primaryOrange, fontSize: 14.0, fontWeight: FontWeight.w500), // Updated
    labelMedium: TextStyle(color: charcoal, fontSize: 12.0, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: charcoal, fontSize: 11.0, fontWeight: FontWeight.w500),
  ).apply(
    bodyColor: charcoal,      // Default color for body text
    displayColor: charcoal,   // Default color for display text (headlines)
  ),
  // Define AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryOrange, // Updated
    foregroundColor: appWhite,    // Text and icon color on AppBar
    elevation: 4.0,
    titleTextStyle: TextStyle(color: appWhite, fontSize: 20.0, fontWeight: FontWeight.w500), // Consistent with titleLarge
  ),
  // Define Button Themes (Example for ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryOrange, // Updated
      foregroundColor: appWhite,     // Button text/icon color
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      minimumSize: const Size(64, 48), // Large tappable buttons
    ),
  ),
  // Define Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: limeGreen, // Using secondary color for FAB
    foregroundColor: appWhite,
  ),
  // Define Card Theme
  cardTheme: CardTheme(
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    color: appWhite, // Card background
    surfaceTintColor: Colors.transparent, // To avoid default tint on elevation
  ),
  // Define Input Decoration Theme (for TextFields)
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)), // outline color
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: primaryOrange, width: 2.0), // Updated
    ),
    labelStyle: const TextStyle(color: charcoal),
    hintStyle: TextStyle(color: charcoal.withOpacity(0.6)),
  ),
  // You can add more specific theme properties here as needed (e.g., bottomNavigationBarTheme)
); 