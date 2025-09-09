class ReportDownloadResponseDTO {
  final String reportId;
  final String fileName;
  final String reportType;
  final String reportCategory;
  final int fileSizeBytes;
  final String expirationDate;

  ReportDownloadResponseDTO({
    required this.reportId,
    required this.fileName,
    required this.reportType,
    required this.reportCategory,
    required this.fileSizeBytes,
    required this.expirationDate,
  });

  factory ReportDownloadResponseDTO.fromJson(Map<String, dynamic> json) {
    return ReportDownloadResponseDTO(
      reportId: json['reportId'] as String,
      fileName: json['fileName'] as String,
      reportType: json['reportType'] as String,
      reportCategory: json['reportCategory'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      expirationDate: json['expirationDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'fileName': fileName,
      'reportType': reportType,
      'reportCategory': reportCategory,
      'fileSizeBytes': fileSizeBytes,
      'expirationDate': expirationDate,
    };
  }
}