// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../controllers/transaction_controller.dart';
// import '../../../dto/app/transaction/bancolombia/bancolombia_transaction_request_dto.dart';
// import '../../../utils/formatters.dart';
//
// class BancolombiaSyncWidget extends StatefulWidget {
//   const BancolombiaSyncWidget({Key? key}) : super(key: key);
//
//   @override
//   State<BancolombiaSyncWidget> createState() => _BancolombiaSyncWidgetState();
// }
//
// class _BancolombiaSyncWidgetState extends State<BancolombiaSyncWidget> {
//   final _formKey = GlobalKey<FormState>();
//   final _accountNumberController = TextEditingController();
//   final _userIdController = TextEditingController();
//
//   DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime _toDate = DateTime.now();
//   bool _isLoading = false;
//   String? _lastSyncDate;
//
//   @override
//   void dispose() {
//     _accountNumberController.dispose();
//     _userIdController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Header
//           _buildHeader(),
//           const SizedBox(height: 20),
//
//           // Estado de sincronizaciÃ³n
//           _buildSyncStatus(),
//           const SizedBox(height: 20),
//
//           // Formulario de configuraciÃ³n
//           _buildSyncForm(),
//           const SizedBox(height: 20),
//
//           // BotÃ³n de sincronizaciÃ³n
//           _buildSyncButton(),
//           const SizedBox(height: 20),
//
//           // InformaciÃ³n sobre la sincronizaciÃ³n
//           _buildSyncInfo(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade600, Colors.blue.shade800],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Image.asset(
//                   'assets/images/bancolombia_logo.png',
//                   width: 32,
//                   height: 32,
//                   errorBuilder: (context, error, stackTrace) => const Icon(
//                     Icons.account_balance,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'SincronizaciÃ³n Bancolombia',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Importa tus transacciones automÃ¡ticamente',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_lastSyncDate != null) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.white, size: 16),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Ãltima sincronizaciÃ³n: $_lastSyncDate',
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSyncStatus() {
//     return Consumer<TransactionController>(
//       builder: (context, controller, child) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.sync,
//                 color: controller.isLoading ? Colors.orange : Colors.green,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       controller.isLoading ? 'Sincronizando...' : 'Listo para sincronizar',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       controller.isLoading
//                         ? 'Por favor espera mientras importamos tus transacciones'
//                         : 'Configura los parÃ¡metros y presiona sincronizar',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (controller.isLoading)
//                 const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSyncForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'ConfiguraciÃ³n de SincronizaciÃ³n',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Campo nÃºmero de cuenta
//           TextFormField(
//             controller: _accountNumberController,
//             decoration: const InputDecoration(
//               labelText: 'NÃºmero de Cuenta',
//               hintText: 'Ingresa tu nÃºmero de cuenta de Bancolombia',
//               prefixIcon: Icon(Icons.account_balance),
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'El nÃºmero de cuenta es requerido';
//               }
//               if (value.trim().length < 8) {
//                 return 'NÃºmero de cuenta invÃ¡lido';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//
//           // Campo ID de usuario
//           TextFormField(
//             controller: _userIdController,
//             decoration: const InputDecoration(
//               labelText: 'ID de Usuario',
//               hintText: 'Tu identificaciÃ³n en Bancolombia',
//               prefixIcon: Icon(Icons.person),
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'El ID de usuario es requerido';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//
//           // Selector de rango de fechas
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDateField(
//                   'Fecha Desde',
//                   _fromDate,
//                   (date) => setState(() => _fromDate = date),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildDateField(
//                   'Fecha Hasta',
//                   _toDate,
//                   (date) => setState(() => _toDate = date),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
//     return InkWell(
//       onTap: () => _selectDate(date, onChanged),
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           prefixIcon: const Icon(Icons.calendar_today),
//         ),
//         child: Text(Formatters.formatDate(date.toIso8601String())),
//       ),
//     );
//   }
//
//   Widget _buildSyncButton() {
//     return Consumer<TransactionController>(
//       builder: (context, controller, child) {
//         return SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: controller.isLoading ? null : _performSync,
//             icon: controller.isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//               : const Icon(Icons.sync),
//             label: Text(controller.isLoading ? 'Sincronizando...' : 'Sincronizar Transacciones'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade600,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSyncInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue.shade600),
//               const SizedBox(width: 8),
//               Text(
//                 'InformaciÃ³n Importante',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue.shade600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           _buildInfoItem(
//             'ð',
//             'Seguridad',
//             'Tu informaciÃ³n bancaria se maneja de forma segura y encriptada.',
//           ),
//           const SizedBox(height: 8),
//
//           _buildInfoItem(
//             'ð',
//             'Datos Importados',
//             'Se importarÃ¡n movimientos de dÃ©bitos, crÃ©ditos y transferencias.',
//           ),
//           const SizedBox(height: 8),
//
//           _buildInfoItem(
//             'â±ï¸',
//             'Frecuencia',
//             'Recomendamos sincronizar semanalmente para mantener actualizada la informaciÃ³n.',
//           ),
//           const SizedBox(height: 8),
//
//           _buildInfoItem(
//             'ð',
//             'Duplicados',
//             'El sistema detecta automÃ¡ticamente transacciones duplicadas.',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(String emoji, String title, String description) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(emoji, style: const TextStyle(fontSize: 16)),
//         const SizedBox(width: 8),
//         Expanded(
//           child: RichText(
//             text: TextSpan(
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Colors.blue.shade800,
//               ),
//               children: [
//                 TextSpan(
//                   text: '$title: ',
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 TextSpan(text: description),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _selectDate(DateTime initialDate, Function(DateTime) onChanged) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       onChanged(picked);
//     }
//   }
//
//   Future<void> _performSync() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final controller = Provider.of<TransactionController>(context, listen: false);
//
//     final dto = BancolombiaTransactionRequestDTO(
//       accountNumber: _accountNumberController.text.trim(),
//       userId: _userIdController.text.trim(),
//       fromDate: _fromDate.toIso8601String(),
//       toDate: _toDate.toIso8601String(),
//     );
//
//     try {
//       setState(() => _isLoading = true);
//
//       await controller.syncBancolombiaTransactions(dto);
//
//       setState(() {
//         _lastSyncDate = Formatters.formatDateTime(DateTime.now().toIso8601String());
//         _isLoading = false;
//       });
//
//       // Mostrar dialog de Ã©xito
//       _showSyncResultDialog(true, 'SincronizaciÃ³n completada exitosamente');
//
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSyncResultDialog(false, 'Error en la sincronizaciÃ³n: $e');
//     }
//   }
//
//   void _showSyncResultDialog(bool success, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(
//               success ? Icons.check_circle : Icons.error,
//               color: success ? Colors.green : Colors.red,
//             ),
//             const SizedBox(width: 8),
//             Text(success ? 'Ãxito' : 'Error'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               if (success) {
//                 // Opcional: navegar de vuelta o recargar datos
//                 Navigator.of(context).pop();
//               }
//             },
//             child: const Text('Entendido'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Widget compacto para mostrar el estado de sincronizaciÃ³n
// class BancolombiaSyncStatusWidget extends StatelessWidget {
//   final VoidCallback onTap;
//
//   const BancolombiaSyncStatusWidget({
//     Key? key,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.blue.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.blue.shade200),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.account_balance,
//                 color: Colors.blue.shade600,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SincronizaciÃ³n Bancolombia',
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     'Importar transacciones automÃ¡ticamente',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Colors.blue.shade600.withOpacity(0.8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.blue.shade400,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Widget para mostrar el historial de sincronizaciones
// class BancolombiaSyncHistoryWidget extends StatefulWidget {
//   const BancolombiaSyncHistoryWidget({Key? key}) : super(key: key);
//
//   @override
//   State<BancolombiaSyncHistoryWidget> createState() => _BancolombiaSyncHistoryWidgetState();
// }
//
// class _BancolombiaSyncHistoryWidgetState extends State<BancolombiaSyncHistoryWidget> {
//   // Mock data - en implementaciÃ³n real vendrÃ­a del servicio
//   final List<Map<String, dynamic>> _syncHistory = [
//     {
//       'date': '2024-03-15T10:30:00Z',
//       'status': 'success',
//       'transactionsImported': 25,
//       'accountNumber': '****1234',
//     },
//     {
//       'date': '2024-03-08T14:15:00Z',
//       'status': 'success',
//       'transactionsImported': 18,
//       'accountNumber': '****1234',
//     },
//     {
//       'date': '2024-03-01T09:45:00Z',
//       'status': 'error',
//       'transactionsImported': 0,
//       'accountNumber': '****1234',
//       'error': 'Error de conexiÃ³n',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Historial de Sincronizaciones',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         if (_syncHistory.isEmpty)
//           _buildEmptyHistory()
//         else
//           ..._syncHistory.map((sync) => _buildHistoryItem(sync)),
//       ],
//     );
//   }
//
//   Widget _buildEmptyHistory() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         children: [
//           Icon(
//             Icons.history,
//             size: 48,
//             color: Theme.of(context).colorScheme.outline,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Sin historial de sincronizaciones',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Las sincronizaciones aparecerÃ¡n aquÃ­',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHistoryItem(Map<String, dynamic> sync) {
//     final isSuccess = sync['status'] == 'success';
//     final color = isSuccess ? Colors.green : Colors.red;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               isSuccess ? Icons.check_circle : Icons.error,
//               color: color,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       isSuccess ? 'SincronizaciÃ³n exitosa' : 'Error en sincronizaciÃ³n',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: color,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       Formatters.formatDateTime(sync['date']),
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 if (isSuccess)
//                   Text(
//                     '${sync['transactionsImported']} transacciones importadas â¢ ${sync['accountNumber']}',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: color.withOpacity(0.8),
//                     ),
//                   )
//                 else
//                   Text(
//                     sync['error'] ?? 'Error desconocido',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: color.withOpacity(0.8),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
