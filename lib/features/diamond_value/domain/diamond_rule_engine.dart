import '../data/diamond_config.dart';

class DiamondRuleResult {
  final List<String> colors;
  final List<String> clarities;
  final ShapeType shapeType;

  DiamondRuleResult({
    required this.colors,
    required this.clarities,
    required this.shapeType,
  });
}

class DiamondRuleEngine {
  DiamondRuleResult resolve(DiamondConfig config) {
    ShapeType newShapeType = config.shapeType;

    final selectedColor =
        config.colorOptions[config.colorIndex.clamp(
          0,
          config.colorOptions.length - 1,
        )];

    if (selectedColor == 'Yellow Vivid') {
      newShapeType = ShapeType.vdf;
    } else if (selectedColor == 'Yellow Intense') {
      newShapeType = ShapeType.iny;
    } else {
      newShapeType = ShapeType.regular;
    }

    final isRound =
        config.shape == DiamondShape.round && newShapeType == ShapeType.regular;

    final colors = DiamondConfig.getColorOptions(
      caratTo: config.caratDouble,
      isRound: isRound,
      shapeType: newShapeType,
    );

    final clarities = DiamondConfig.getClarityOptions(
      caratTo: config.caratDouble,
      isRound: isRound,
      shapeType: newShapeType,
    );

    return DiamondRuleResult(
      colors: colors,
      clarities: clarities,
      shapeType: newShapeType,
    );
  }
}
