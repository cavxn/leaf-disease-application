class FertilizationHistory {
  final String id;
  final String plantId;
  final String plantName;
  final String productName;
  final String npkRatio;
  final double amount; // in cups or ml
  final String unit; // 'cups', 'ml', 'tbsp'
  final DateTime applicationDate;
  final String notes;
  final String applicationMethod;

  FertilizationHistory({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.productName,
    required this.npkRatio,
    required this.amount,
    required this.unit,
    required this.applicationDate,
    this.notes = '',
    this.applicationMethod = 'soil',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'productName': productName,
      'npkRatio': npkRatio,
      'amount': amount,
      'unit': unit,
      'applicationDate': applicationDate.toIso8601String(),
      'notes': notes,
      'applicationMethod': applicationMethod,
    };
  }

  factory FertilizationHistory.fromJson(Map<String, dynamic> json) {
    return FertilizationHistory(
      id: json['id'],
      plantId: json['plantId'],
      plantName: json['plantName'],
      productName: json['productName'],
      npkRatio: json['npkRatio'],
      amount: json['amount'].toDouble(),
      unit: json['unit'],
      applicationDate: DateTime.parse(json['applicationDate']),
      notes: json['notes'] ?? '',
      applicationMethod: json['applicationMethod'] ?? 'soil',
    );
  }
}
