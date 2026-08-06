class PlanSupplement {
  final String id;
  final String planId;
  final String? supplementId;
  final String? dose;
  final String? timing;
  final String? notes;

  const PlanSupplement({
    required this.id,
    required this.planId,
    this.supplementId,
    this.dose,
    this.timing,
    this.notes,
  });

  factory PlanSupplement.fromMap(Map<String, dynamic> map) => PlanSupplement(
        id: map['id'] as String,
        planId: map['plan_id'] as String,
        supplementId: map['supplement_id'] as String?,
        dose: map['dose'] as String?,
        timing: map['timing'] as String?,
        notes: map['notes'] as String?,
      );

  Map<String, dynamic> toInsertMap() => {
        'plan_id': planId,
        'supplement_id': supplementId,
        'dose': dose,
        'timing': timing,
        'notes': notes,
      };
}
