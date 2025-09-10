enum Model { OPENAI, DEEPSEEK }

extension ModelExtension on Model {
  String get displayName {
    switch (this) {
      case Model.OPENAI:
        return 'OpenAI';
      case Model.DEEPSEEK:
        return 'DeepSeek';
    }
  }

  String get description {
    switch (this) {
      case Model.OPENAI:
        return 'GPT-4 • Versátil y confiable';
      case Model.DEEPSEEK:
        return 'Optimizado para análisis financiero';
    }
  }
}