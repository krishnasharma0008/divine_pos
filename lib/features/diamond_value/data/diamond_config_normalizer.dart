import 'diamond_config.dart';
import '../domain/diamond_rule_engine.dart';

DiamondConfig normalizeConfig(
  DiamondConfig oldConfig,
  DiamondConfig newConfig,
  DiamondRuleEngine engine,
) {
  final result = engine.resolve(newConfig);

  final selectedColor =
      newConfig.colorOptions[newConfig.colorIndex.clamp(
        0,
        newConfig.colorOptions.length - 1,
      )];

  final selectedClarity =
      newConfig.clarityOptions[newConfig.clarityIndex.clamp(
        0,
        newConfig.clarityOptions.length - 1,
      )];

  final newColorIndex = result.colors.contains(selectedColor)
      ? result.colors.indexOf(selectedColor)
      : 0;

  final newClarityIndex = result.clarities.contains(selectedClarity)
      ? result.clarities.indexOf(selectedClarity)
      : 0;

  return newConfig.copyWith(
    shapeType: result.shapeType,
    colorIndex: newColorIndex,
    clarityIndex: newClarityIndex,
  );
}
