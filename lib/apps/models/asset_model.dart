class AssetModel {
  final int id;
  final String? code;
  final String name;
  final String category;
  final String categoryLabel;
  final String? brand;
  final String? modelNo;
  final String? serialNo;
  final String condition;
  final String conditionLabel;
  final String? assignedOn;

  const AssetModel({
    required this.id,
    this.code,
    required this.name,
    required this.category,
    required this.categoryLabel,
    this.brand,
    this.modelNo,
    this.serialNo,
    required this.condition,
    required this.conditionLabel,
    this.assignedOn,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
        id: json['id'] as int,
        code: json['code'] as String?,
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        categoryLabel: json['category_label'] as String? ?? '',
        brand: json['brand'] as String?,
        modelNo: json['model_no'] as String?,
        serialNo: json['serial_no'] as String?,
        condition: json['condition'] as String? ?? '',
        conditionLabel: json['condition_label'] as String? ?? '',
        assignedOn: json['assigned_on'] as String?,
      );
}
