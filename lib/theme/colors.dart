import 'package:flutter/material.dart';

// Backgrounds (Deeper, richer darks)
const backgroundPrimary = Color(
  0xFF121212,
); // A slightly deeper, true dark background
const surfaceElevated = Color(
  0xFF1E1E1E,
); // For cards, sections, dotted border - subtle elevation
const surfaceContainer = Color(
  0xFF2A2A2A,
); // For slightly more prominent containers or elements

// Primary Accent (Main interactive color - still your vibrant purple)
const accentPrimary = Color(0xFF7C3AED); // Your core vibrant purple

// Secondary Accent (Darker, richer purple for icons, subtle actions, non-primary interactive elements)
const accentSecondary = Color(
  0xFF5D3E8E,
); // A richer, slightly deeper purple than before,
// harmonious with _accentPrimary but distinct.

// Text & Icons (Improved contrast and hierarchy)
const textPrimary = Color(
  0xFFE0E0E0,
); // Off-white for main body text and titles
const textSecondary = Color(
  0xFFAAAAAA,
); // Lighter grey for secondary text, captions, hints
const textOnAccent =
    Colors.white; // Pure white for text on primary/secondary accent colors

// Feedback & States
const errorColor = Color(
  0xFFEF5350,
); // A standard, clear red for errors (Material default if suitable)
const onErrorColor = Colors.white;
const indicatorLoading = Color(
  0xFF00C2E0,
); // A clear, subtle cyan for loading/progress indicators
