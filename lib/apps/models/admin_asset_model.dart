class AssignedTo {
  final int id;
  final String name;
  final String? department;

  const AssignedTo({required this.id, required this.name, this.department});

  factory AssignedTo.fromJson(Map<String, dynamic> json) => AssignedTo(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        department: json['department'] as String?,
      );
}

class AdminAssetModel {
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
  final AssignedTo? assignedTo;

  const AdminAssetModel({
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
    this.assignedTo,
  });

  bool get isAssigned => assignedTo != null;

  factory AdminAssetModel.fromJson(Map<String, dynamic> json) => AdminAssetModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
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
        assignedTo: json['assigned_to'] != null
            ? AssignedTo.fromJson(json['assigned_to'] as Map<String, dynamic>)
            : null,
      );
}
