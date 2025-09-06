import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../../../../controllers/excel_controller.dart';

class ExcelControlsWidget extends StatelessWidget {
  final VoidCallback? onExport;
  final VoidCallback? onDownloadTemplate;
  final Function(XFile)? onImport;

  const ExcelControlsWidget({
    Key? key,
    this.onExport,
    this.onDownloadTemplate,
    this.onImport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExcelController>(
      builder: (context, excelController, child) {
        final isLoading = excelController.isLoading;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                
                // Botones principales
                Row(
                  children: [
                    Expanded(
                      child: _buildControlButton(
                        context: context,
                        icon: Icons.download,
                        label: 'Exportar\nDatos',
                        color: Colors.green,
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
                        color: Colors.blue,
                        onPressed: isLoading ? null : () => _handleImport(context),
                        description: 'Sube un archivo Excel con datos',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Botón de plantilla
                SizedBox(
                  width: double.infinity,
                  child: _buildControlButton(
                    context: context,
                    icon: Icons.file_download,
                    label: 'Descargar Plantilla Excel',
                    color: Colors.orange,
                    onPressed: isLoading ? null : onDownloadTemplate,
                    description: 'Obtén la plantilla para importar datos',
                    isFullWidth: true,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Información adicional
                _buildInfoSection(context),
                
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  _buildLoadingIndicator(),
                ],
                
                if (excelController.hasRecentDownload) ...[
                  const SizedBox(height: 16),
                  _buildRecentDownloadInfo(context, excelController),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.table_chart,
            color: Colors.green[600],
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
                'Exporta e importa datos financieros en formato Excel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isFullWidth 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
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
                        fontSize: 11,
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
              Icon(icon, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Información sobre archivos Excel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoItem('â¢ Formatos soportados: .xlsx, .xls'),
          _buildInfoItem('â¢ Tamaño máximo: 10MB'),
          _buildInfoItem('â¢ Incluye: Transacciones, Deudas, Categorías, Presupuestos'),
          _buildInfoItem('â¢ La plantilla muestra la estructura requerida'),
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
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Procesando archivo Excel...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'Por favor espera mientras procesamos tu solicitud',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDownloadInfo(BuildContext context, ExcelController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ãltima descarga exitosa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontSize: 14,
                  ),
                ),
                Text(
                  controller.downloadInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDownloadDetails(context, controller),
            icon: Icon(Icons.info_outline, color: Colors.green[600], size: 18),
          ),
        ],
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
            Icon(Icons.upload_file, color: Colors.blue),
            SizedBox(width: 8),
            Text('Confirmar Importación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Â¿Deseas importar el siguiente archivo?'),
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

  void _showDownloadDetails(BuildContext context, ExcelController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Detalles de Descarga'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.downloadInfo),
            const SizedBox(height: 8),
            if (controller.lastDownloadedFile != null)
              Text(
                'Ubicación: ${controller.lastDownloadedFile}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}