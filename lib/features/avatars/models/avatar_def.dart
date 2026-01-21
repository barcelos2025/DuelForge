class AvatarDef {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final String classType; // Warrior, Mage, etc.
  final String gender; // Male, Female

  const AvatarDef({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.classType,
    required this.gender,
  });
}
