class ClassIconMapper {
  static String getIconPath(String classType) {
    // Normalize class name to lowercase and remove gender suffixes
    final normalized = classType.toLowerCase();
    
    if (normalized.contains('guerreir')) return 'assets/ui/icons/classes/warrior.png';
    if (normalized.contains('mago') || normalized.contains('maga')) return 'assets/ui/icons/classes/mage.png';
    if (normalized.contains('arqueir')) return 'assets/ui/icons/classes/archer.png';
    if (normalized.contains('guardi')) return 'assets/ui/icons/classes/guardian.png';
    if (normalized.contains('brux')) return 'assets/ui/icons/classes/warlock.png';
    if (normalized.contains('bárbar')) return 'assets/ui/icons/classes/berserker.png';
    if (normalized.contains('ladin')) return 'assets/ui/icons/classes/rogue.png';
    if (normalized.contains('xamã')) return 'assets/ui/icons/classes/shaman.png';
    if (normalized.contains('einherjar')) return 'assets/ui/icons/classes/einherjar.png';
    if (normalized.contains('valquíria')) return 'assets/ui/icons/classes/valkyrie.png';
    if (normalized.contains('mestre') || normalized.contains('mestra')) return 'assets/ui/icons/classes/runemaster.png';
    
    // Default to warrior if no match
    return 'assets/ui/icons/classes/warrior.png';
  }
}
