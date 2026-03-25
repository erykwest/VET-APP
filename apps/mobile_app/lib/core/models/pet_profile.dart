class PetProfile {
  const PetProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.sex,
    this.weight,
    this.notes,
  });

  final String id;
  final String userId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final String? sex;
  final double? weight;
  final String? notes;
}
