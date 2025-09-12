import '../../../dto/chat/response/chat_history_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  /// Obtener historial por conversationId específico
  Future<List<ChatHistoryDTO>> getHistoryByConversationId(
      String conversationId,
      ) async {
    print('📚 ChatHistoryService: Obteniendo historial para conversación: $conversationId');
    try {
      final response = await _api.getChat('/chat/history/$conversationId');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // El servidor podría devolver: {success: true, data: [...]}
        if (data['success'] == true && data['data'] is List) {
          final history = (data['data'] as List)
              .map((json) => ChatHistoryDTO.fromJson(json))
              .toList();
          print('✅ ChatHistoryService: ${history.length} mensajes obtenidos para conversación');
          return history;
        } else {
          throw Exception('Error del servidor: ${data['message'] ?? 'Sin mensaje'}');
        }
      } else if (data is List) {
        final history = data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
        print('✅ ChatHistoryService: ${history.length} mensajes obtenidos');
        return history;
      }
      throw Exception('Respuesta inesperada del servidor. Tipo: ${data.runtimeType}, Contenido: $data');
    } catch (e) {
      print('❌ ChatHistoryService: Error obteniendo historial: $e');
      rethrow;
    }
  }

  /// Obtener todas las conversaciones (lista de conversaciones únicas)
  Future<List<ChatHistoryDTO>> getAllConversations({String? userType}) async {
    print('📚 ChatHistoryService: Obteniendo todas las conversaciones${userType != null ? ' para tipo de usuario: $userType' : ''}');
    try {
      String endpoint = '/chat/history/user';
      if (userType != null) {
        endpoint += '?userType=$userType';
      }
      final response = await _api.getChat(endpoint);
      final data = response.data;

      print('📊 ChatHistoryService: Tipo de respuesta: ${data.runtimeType}');
      print('📊 ChatHistoryService: Contenido de respuesta: $data');

      if (data is Map<String, dynamic>) {
        // El servidor devuelve: {success: true, data: [...]}
        if (data['success'] == true && data['data'] is List) {
          final conversations = (data['data'] as List)
              .map((json) => ChatHistoryDTO.fromJson(json))
              .toList();
          print('✅ ChatHistoryService: ${conversations.length} conversaciones obtenidas');
          return conversations;
        } else {
          throw Exception('Error del servidor: ${data['message'] ?? 'Sin mensaje'}');
        }
      } else if (data is List) {
        // Soporte para respuesta directa como lista (por compatibilidad)
        final conversations = data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
        print('✅ ChatHistoryService: ${conversations.length} conversaciones obtenidas');
        return conversations;
      } else if (data == null) {
        print('ℹ️ ChatHistoryService: Sin conversaciones (respuesta nula)');
        return [];
      }
      throw Exception('Respuesta inesperada del servidor. Tipo: ${data.runtimeType}, Contenido: $data');
    } catch (e) {
      print('❌ ChatHistoryService: Error obteniendo conversaciones: $e');
      rethrow;
    }
  }

  /// NOTA: El historial se guarda automáticamente en el backend cuando se envían mensajes al /chat
  /// Este método no es necesario ya que no existe un endpoint POST para historial
  Future<void> saveChatHistory(ChatHistoryDTO historyItem) async {
    print('ℹ️ ChatHistoryService: El historial se guarda automáticamente en el servidor');
    print('💾 ChatHistoryService: No se requiere acción manual para guardar el historial');
    // El backend guarda automáticamente cuando envías mensajes a /chat
    // No hay endpoint POST /chat/history
  }

  /// Eliminar conversación específica por ID
  Future<void> deleteConversation(String conversationId) async {
    print('🗑️ ChatHistoryService: Eliminando conversación: $conversationId');
    try {
      await _api.deleteChat('/chat/history/delete/$conversationId');
      print('✅ ChatHistoryService: Conversación eliminada');
    } catch (e) {
      print('❌ ChatHistoryService: Error eliminando conversación: $e');
      rethrow;
    }
  }

  /// Eliminar todo el historial de chat
  Future<void> clearAllHistory() async {
    print('🗑️ ChatHistoryService: Eliminando todo el historial');
    try {
      await _api.deleteChat('/chat/history');
      print('✅ ChatHistoryService: Todo el historial eliminado');
    } catch (e) {
      print('❌ ChatHistoryService: Error eliminando historial: $e');
      rethrow;
    }
  }

  /// Obtener estadísticas del chat (opcional)
  Future<Map<String, dynamic>> getChatStats() async {
    print('📊 ChatHistoryService: Obteniendo estadísticas de chat');
    try {
      final response = await _api.getChat('/chat/stats');
      print('✅ ChatHistoryService: Estadísticas obtenidas');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ ChatHistoryService: Error obteniendo estadísticas: $e');
      rethrow;
    }
  }

  /// Obtener resumen de conversaciones recientes
  Future<List<Map<String, dynamic>>> getRecentConversations({int limit = 10}) async {
    print('📚 ChatHistoryService: Obteniendo conversaciones recientes (límite: $limit)');
    try {
      final response = await _api.getChat('/chat/history/recent?limit=$limit');
      final data = response.data;

      if (data is List) {
        final conversations = data.cast<Map<String, dynamic>>();
        print('✅ ChatHistoryService: ${conversations.length} conversaciones recientes obtenidas');
        return conversations;
      }
      throw Exception('Respuesta inesperada del servidor.');
    } catch (e) {
      print('❌ ChatHistoryService: Error obteniendo conversaciones recientes: $e');
      rethrow;
    }
  }
}