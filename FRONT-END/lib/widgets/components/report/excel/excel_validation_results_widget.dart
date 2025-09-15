import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/excel/excel_controller.dart';
import '../../../../dto/app/excel/debt_excel_validation_result_dto.dart';

class ExcelValidationResultsWidget extends StatelessWidget {
  final DebtExcelValidationResultDTO validationResult;
  final VoidCallback? onRetry;
  final VoidCallback? onProceed;

  const ExcelValidationResultsWidget({
    super.key,
    required this.validationResult,
    this.onRetry,
    this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = validationResult.isValid;
    final color = isValid ? Colors.green : Colors.red;
    final backgroundColor = isValid ? Colors.green[50] : Colors.red[50];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, color, isValid),
              const SizedBox(height: 16),
              _buildSummaryStats(context),
              
              if (validationResult.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildErrorsSection(context),
              ],
              
              if (validationResult.warnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildWarningsSection(context),
              ],
              
              const SizedBox(height: 20),
              _buildActionButtons(context, isValid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color, bool isValid) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isValid ? 'Validación Exitosa' : 'Errores de Validación',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                validationResult.summaryMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        if (isValid)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'VÃLIDO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Filas',
              '${validationResult.totalRows}',
              Icons.table_rows,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Filas Válidas',
              '${validationResult.validRows}',
              Icons.check,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Filas Inválidas',
              '${validationResult.invalidRows}',
              Icons.error,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Text(
              'Errores (${validationResult.errors.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: validationResult.errors
                .asMap()
                .entries
                .map((entry) => _buildIssueItem(
                      entry.key + 1,
                      entry.value,
                      Colors.red,
                      Icons.error,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              'Advertencias (${validationResult.warnings.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            children: validationResult.warnings
                .asMap()
                .entries
                .map((entry) => _buildIssueItem(
                      entry.key + 1,
                      entry.value,
                      Colors.orange,
                      Icons.warning,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueItem(int index, String message, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isValid) {
    if (isValid) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _dismissResults(context),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cerrar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onProceed,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Continuar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('Ayuda'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[300]!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _dismissResults(BuildContext context) {
    final controller = context.read<ExcelController>();
    controller.clearMessages();
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.blue),
            SizedBox(width: 8),
            Text('Ayuda con Validación'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Problemas comunes y soluciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('â¢ Formato incorrecto: Asegúrate de usar archivos .xlsx o .xls'),
              SizedBox(height: 6),
              Text('â¢ Archivo muy grande: El límite es de 10MB'),
              SizedBox(height: 6),
              Text('â¢ Columnas faltantes: Descarga la plantilla para ver la estructura correcta'),
              SizedBox(height: 6),
              Text('â¢ Fechas incorrectas: Usa el formato dd/MM/yyyy'),
              SizedBox(height: 6),
              Text('â¢ Valores vacíos: Completa todos los campos obligatorios'),
              SizedBox(height: 12),
              Text(
                'Si el problema persiste, descarga una nueva plantilla y verifica que tus datos siguen el formato requerido.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Descargar plantilla
              final controller = context.read<ExcelController>();
              controller.downloadTemplate();
            },
            child: const Text('Descargar Plantilla'),
          ),
        ],
      ),
    );
  }
}