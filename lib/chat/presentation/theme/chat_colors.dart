import 'package:flutter/material.dart';

/// Colores específicos para el módulo de chat según FLUTTER_CHAT_GUIDE.md
class ChatColors {
  // Colores principales de fondo
  static const Color background = Color(0xFF160F23);        // Fondo principal oscuro
  static const Color darkBackground = Color(0xFF160F23);    // Fondo alternativo

  // Colores de tarjetas y campos
  static const Color cardBackground = Color(0xFF221733);    // Fondo de campos y tarjetas
  static const Color fieldBackground = Color(0xFF221733);   // Fondo específico de campos

  // Colores de burbujas de mensajes
  static const Color bubbleMine = Color(0xFF8E3DF9);        // Mensajes propios (púrpura)
  static const Color bubbleOther = Color(0xFF2B1E3F);       // Mensajes de otros (púrpura oscuro)

  // Colores de texto y acentos
  static const Color textPrimary = Colors.white;            // Texto principal
  static const Color textSecondary = Color(0xFFA88ECC);     // Texto secundario/muted
  static const Color subtleText = Color(0xFFA88ECC);        // Texto sutil
  static const Color titleColor = Colors.white;             // Color de títulos
  static const Color accent = Color(0xFF8E3DF9);            // Color de acento principal

  // Estados adicionales
  static const Color unreadIndicator = Color(0xFF8E3DF9);   // Indicador de no leídos
  static const Color onlineIndicator = Color(0xFF4CAF50);   // Indicador en línea
  static const Color offlineIndicator = Color(0xFF757575);  // Indicador desconectado
}