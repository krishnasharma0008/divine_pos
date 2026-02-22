class JewelleryUtils {
  static String mapShapeCodeToName(String code) {
    const shapeMap = {
      'RND': 'Round',
      'PRN': 'Princess',
      'OVL': 'Oval',
      'PER': 'Pear',
      'RADQ': 'Radiant',
      'CUSQ': 'Cushion',
      'HRT': 'Heart',
      'MAQ': 'Marquise',
    };
    return shapeMap[code] ?? 'Round';
  }
}
