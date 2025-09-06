import 'package:intl/intl.dart';

class Formatters {
  // Formatear moneda
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Formatear moneda con decimales
  static String formatCurrencyWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Formatear fecha
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Formatear fecha con hora
  static String formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Formatear fecha para mostrar (mÃ¡s amigable)
  static String formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} dÃ­as atrÃ¡s';
      } else {
        final formatter = DateFormat('dd/MM/yyyy');
        return formatter.format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  // Formatear nÃºmeros
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'es_CO');
    return formatter.format(number);
  }

  // Formatear porcentaje
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Formatear texto para mostrar (capitalizar primera letra)
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Formatear nombre de mes
  static String formatMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return monthNames[month - 1];
  }

  // Truncar texto
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
