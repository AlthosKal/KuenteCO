import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final double? height;
  final Color? primaryColor;
  final Color? backgroundColor;
  
  const BarChartWidget({
    super.key,
    required this.chartData,
    this.height,
    this.primaryColor,
    this.backgroundColor,
  });

  List<Map<String, dynamic>> get data => 
    (chartData['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  
  String get chartType => chartData['chartType'] ?? 'bar';
  String get xAxisLabel => chartData['xaxisLabel'] ?? 'Categorías';
  String get yAxisLabel => chartData['yaxisLabel'] ?? 'Valores';
  String get summary => chartData['summary'] ?? 'Gráfico';
  String get analysis => chartData['analysis'] ?? '';

  @override
  Widget build(BuildContext context) {
    
    if (data.isEmpty) {
      return Container(
        height: height ?? 300,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'No hay datos para mostrar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del gráfico
            Text(
              summary,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (analysis.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                analysis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 20),
            
            // Gráfico de barras
            SizedBox(
              height: height ?? 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue() * 1.2, // 20% más alto que el valor máximo
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[groupIndex];
                        return BarTooltipItem(
                          '${item['label']}\n\$${_formatValue(item['value']?.toDouble() ?? 0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: _getBottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 64,
                        interval: _getYInterval(),
                        getTitlesWidget: _getLeftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  barGroups: _createBarGroups(),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getYInterval(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = item['value']?.toDouble() ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getBarColor(index),
            width: _getBarWidth(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue() * 1.2,
              color: Colors.grey[100],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w400,
      fontSize: 11,
    );

    if (value.toInt() >= 0 && value.toInt() < data.length) {
      final label = data[value.toInt()]['label'] ?? '';
      
      // Si el label es muy largo, truncarlo
      final displayLabel = label.length > 10 ? '${label.substring(0, 8)}...' : label;
      
      return Transform.rotate(
        angle: data.length > 6 ? -0.5 : 0, // Rotar si hay muchas barras
        child: Text(displayLabel, style: style),
      );
    }
    
    return const Text('');
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w400,
      fontSize: 10,
    );

    return Text('\$${_formatValue(value)}', style: style);
  }

  double _getMaxValue() {
    if (data.isEmpty) return 0;
    return data
        .map((e) => e['value']?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  double _getYInterval() {
    final maxValue = _getMaxValue();
    if (maxValue == 0) return 1;
    
    // Calcular un intervalo apropiado basado en el valor máximo
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    if (maxValue <= 10000) return 2000;
    
    return (maxValue / 5).roundToDouble();
  }

  double _getBarWidth() {
    // Ajustar el ancho de las barras basado en la cantidad de datos
    if (data.length <= 3) return 40;
    if (data.length <= 6) return 32;
    if (data.length <= 10) return 24;
    return 16;
  }

  Color _getBarColor(int index) {
    final colors = [
      primaryColor ?? const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFFEB3B),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFF3F51B5),
    ];
    
    return colors[index % colors.length];
  }

  String _formatValue(double value) {
    if (value == 0) return '0';
    
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
}