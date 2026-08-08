class DietitianProfile {
  final String id;
  final String? name;
  final String? logoUrl;

  const DietitianProfile({required this.id, this.name, this.logoUrl});

  factory DietitianProfile.fromMap(Map<String, dynamic> map) =>
      DietitianProfile(
        id: map['id'] as String,
        name: map['name'] as String?,
        logoUrl: map['logo_url'] as String?,
      );

  Map<String, dynamic> toInsertMap() => {'name': name, 'logo_url': logoUrl};
}
