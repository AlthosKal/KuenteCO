class NotificationPreferencesDTO {
  final String? userId;
  final int? profileId;

  // Preferencias de notificaciones de presupuesto
  final bool budgetExceededEnabled;
  final bool budgetNearLimitEnabled;

  // Preferencias de notificaciones de deudas
  final bool debtReminderEnabled;
  final bool debtOverdueEnabled;
  final int debtReminderDaysBefore;

  // Preferencias de notificaciones de transacciones
  final bool transactionAlertEnabled;
  final bool unusualActivityEnabled;

  // Canales de notificaciÃ³n
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;

  final String? notificationEmail;
  final String? phoneNumber;

  NotificationPreferencesDTO({
    this.userId,
    this.profileId,
    this.budgetExceededEnabled = true,
    this.budgetNearLimitEnabled = true,
    this.debtReminderEnabled = true,
    this.debtOverdueEnabled = true,
    this.debtReminderDaysBefore = 3,
    this.transactionAlertEnabled = false,
    this.unusualActivityEnabled = true,
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.notificationEmail,
    this.phoneNumber,
  });

  factory NotificationPreferencesDTO.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDTO(
      userId: json['userId'],
      profileId: json['profileId'],
      budgetExceededEnabled: json['budgetExceededEnabled'] ?? true,
      budgetNearLimitEnabled: json['budgetNearLimitEnabled'] ?? true,
      debtReminderEnabled: json['debtReminderEnabled'] ?? true,
      debtOverdueEnabled: json['debtOverdueEnabled'] ?? true,
      debtReminderDaysBefore: json['debtReminderDaysBefore'] ?? 3,
      transactionAlertEnabled: json['transactionAlertEnabled'] ?? false,
      unusualActivityEnabled: json['unusualActivityEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      pushEnabled: json['pushEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? false,
      notificationEmail: json['notificationEmail'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileId': profileId,
      'budgetExceededEnabled': budgetExceededEnabled,
      'budgetNearLimitEnabled': budgetNearLimitEnabled,
      'debtReminderEnabled': debtReminderEnabled,
      'debtOverdueEnabled': debtOverdueEnabled,
      'debtReminderDaysBefore': debtReminderDaysBefore,
      'transactionAlertEnabled': transactionAlertEnabled,
      'unusualActivityEnabled': unusualActivityEnabled,
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'notificationEmail': notificationEmail,
      'phoneNumber': phoneNumber,
    };
  }
}
