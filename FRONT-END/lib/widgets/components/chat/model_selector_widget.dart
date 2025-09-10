import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/chat_controller.dart';
import '../../../utils/enum/model_enum.dart';

class ModelSelectorWidget extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const ModelSelectorWidget({
    Key? key,
    this.showLabel = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        if (compact) {
          return _buildCompactSelector(context, chatController);
        } else {
          return _buildFullSelector(context, chatController);
        }
      },
    );
  }

  Widget _buildFullSelector(BuildContext context, ChatController chatController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 20,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Modelo de IA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _buildModelCard(
                  context: context,
                  model: Model.OPENAI,
                  title: Model.OPENAI.displayName,
                  subtitle: Model.OPENAI.description,
                  icon: Icons.auto_awesome,
                  color: Colors.green,
                  isSelected: chatController.selectedModel == Model.OPENAI,
                  onTap: () => chatController.setSelectedModel(Model.OPENAI),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModelCard(
                  context: context,
                  model: Model.DEEPSEEK,
                  title: Model.DEEPSEEK.displayName,
                  subtitle: Model.DEEPSEEK.description,
                  icon: Icons.analytics,
                  color: Colors.purple,
                  isSelected: chatController.selectedModel == Model.DEEPSEEK,
                  onTap: () => chatController.setSelectedModel(Model.DEEPSEEK),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSelector(BuildContext context, ChatController chatController) {
    // Construir lista de modelos disponibles dinámicamente
    final availableModels = _getAvailableModels(chatController);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Model>(
                value: chatController.selectedModel,
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (Model? newValue) {
                  if (newValue != null) {
                    chatController.setSelectedModel(newValue);
                  }
                },
                items: availableModels.map((model) => _buildDropdownItem(model)).toList(),
              ),
            ),
          ),
          // Indicador de conexión con servidor
          if (chatController.availableModels.isNotEmpty)
            Icon(Icons.wifi, size: 12, color: Colors.green[600])
          else
            Icon(Icons.wifi_off, size: 12, color: Colors.red[600]),
        ],
      ),
    );
  }

  DropdownMenuItem<Model> _buildDropdownItem(Model model) {
    IconData icon;
    Color color;
    
    switch (model) {
      case Model.OPENAI:
        icon = Icons.auto_awesome;
        color = Colors.green;
        break;
      case Model.DEEPSEEK:
        icon = Icons.analytics;
        color = Colors.purple;
        break;
    }
    
    return DropdownMenuItem(
      value: model,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(model.displayName),
        ],
      ),
    );
  }

  List<Model> _getAvailableModels(ChatController chatController) {
    if (chatController.availableModels.isEmpty) {
      // Si no hay modelos del servidor, usar los por defecto
      return Model.values;
    }
    
    // Filtrar solo los modelos que están disponibles en el servidor
    return Model.values.where((model) {
      return chatController.availableModels.contains(model.name);
    }).toList();
  }

  Widget _buildModelCard({
    required BuildContext context,
    required Model model,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}