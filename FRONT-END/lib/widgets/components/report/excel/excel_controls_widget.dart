import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/excel/excel_controller.dart';

class ExcelControlsWidget extends StatelessWidget {
  final VoidCallback? onExport;
  final VoidCallback? onDownloadTemplate;
  final Function(XFile)? onImport;

  const ExcelControlsWidget({
    super.key,
    this.onExport,
    this.onDownloadTemplate,
    this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExcelController>(
      builder: (context, excelController, child) {
        final isLoading = excelController.isLoading;
        
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.purple.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y subtítulo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.table_chart,
                          color: Colors.purple[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de Archivos Excel',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Exporta e importa datos financieros en formato Excel para análisis externos o respaldo de información.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botones principales
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlButton(
                          context: context,
                          icon: Icons.download,
                          label: 'Exportar\nDatos',
                          color: Colors.purple,
                          onPressed: isLoading ? null : onExport,
                          description: 'Descarga tus datos financieros',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildControlButton(
                          context: context,
                          icon: Icons.upload,
                          label: 'Importar\nDatos',
                          color: Colors.purple.shade600,
                          onPressed: isLoading ? null : () => _handleImport(context),
                          description: 'Sube un archivo Excel con datos',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón de plantilla
                  SizedBox(
                    width: double.infinity,
                    child: _buildControlButton(
                      context: context,
                      icon: Icons.file_download,
                      label: 'Descargar Plantilla Excel',
                      color: Colors.purple.shade700,
                      onPressed: isLoading ? null : onDownloadTemplate,
                      description: 'Obtén la plantilla para importar datos',
                      isFullWidth: true,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información adicional
                  _buildInfoSection(context),
                  
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required String description,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isFullWidth 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Información sobre archivos Excel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoItem('Formatos soportados: .xlsx, .xls'),
          _buildInfoItem('Tamaño máximo: 10MB'),
          _buildInfoItem('Incluye: Transacciones, Deudas, Categorías, Presupuestos'),
          _buildInfoItem('La plantilla muestra la estructura requerida'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.purple[700],
        ),
      ),
    );
  }



  Future<void> _handleImport(BuildContext context) async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Excel files',
        extensions: <String>['xlsx', 'xls'],
      );
      
      final XFile? result = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (result != null) {
        // Mostrar diálogo de confirmación
        final confirmed = await _showImportConfirmationDialog(context, result);
        
        if (confirmed && onImport != null) {
          onImport!(result);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seleccionando archivo: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _handleImport(context),
          ),
        ),
      );
    }
  }

  Future<bool> _showImportConfirmationDialog(BuildContext context, XFile file) async {
    final fileName = file.name;
    final fileSize = await file.length();
    final fileSizeKB = (fileSize / 1024).toStringAsFixed(1);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload_file, color: Colors.purple),
            SizedBox(width: 8),
            Text('Confirmar Importación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas importar el siguiente archivo?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Archivo: $fileName', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Tamaño: ${fileSizeKB}KB'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción importará los datos del archivo a tu cuenta. Los datos existentes no se eliminarán.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Importar'),
          ),
        ],
      ),
    ) ?? false;
  }

}