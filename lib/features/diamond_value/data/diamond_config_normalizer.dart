import 'package:flutter/material.dart';

import 'diamond_config.dart';
import '../domain/diamond_rule_engine.dart';

// ---------------------------------------------------------------------------
// What triggered the normalizer — drives reset / preserve logic per the table:
//
//  shapeChange   → reset carat, color, clarity  |  keep shape
//  caratChange   → reset color/clarity if invalid | keep shape
//  colorChange   → shapeType → yellow/regular   |  keep entered carat
//  clarityChange → nothing else resets           |  keep everything
// ---------------------------------------------------------------------------
enum NormalizeTrigger { shapeChange, caratChange, colorChange, clarityChange }

DiamondConfig normalizeConfig(
  DiamondConfig oldConfig,
  DiamondConfig newConfig,
  DiamondRuleEngine engine, {
  required NormalizeTrigger trigger,

  /// Used only for shapeChange — carat to reset to.
  double defaultCarat = 0.30,
}) {
  switch (trigger) {
    // -----------------------------------------------------------------------
    // SHAPE CHANGE  →  reset carat + color + clarity
    // -----------------------------------------------------------------------
    case NormalizeTrigger.shapeChange:
      final resetConfig = newConfig.copyWith(enteredCarat: defaultCarat);
      final result = engine.resolve(resetConfig);

      debugPrint(
        '[normalizeConfig] shapeChange — reset to carat=$defaultCarat '
        'color[0]=${result.colors.first} clarity[0]=${result.clarities.first}',
      );

      return resetConfig.copyWith(
        shapeType: result.shapeType,
        colorIndex: 0,
        clarityIndex: 0,
      );

    // -----------------------------------------------------------------------
    // CARAT CHANGE  →  keep color/clarity only if still valid
    // -----------------------------------------------------------------------
    case NormalizeTrigger.caratChange:
      // Resolve the user's current color/clarity by VALUE, not by index.
      // This is critical: changing carat can shrink/grow the colorOptions
      // list (e.g. round crosses the 0.18 threshold), so a stale colorIndex
      // may point to a completely different color in the new list — which
      // would cause the engine to resolve the wrong shapeType (e.g. treating
      // a regular color as "Yellow Vivid" because indices shifted).
      final oldColor = _safeGet(oldConfig.colorOptions, oldConfig.colorIndex);
      final oldClarity = _safeGet(
        oldConfig.clarityOptions,
        oldConfig.clarityIndex,
      );

      // Re-anchor the colorIndex in the NEW options list BEFORE the engine
      // sees it, so shapeType is derived from the actual color value.
      final anchoredColorIdx = _findColorIdx(newConfig.colorOptions, oldColor);
      final configForResolve = newConfig.copyWith(colorIndex: anchoredColorIdx);

      final result = engine.resolve(configForResolve);

      final colorIdx = _findColorIdx(result.colors, oldColor);
      final clarityIdx = _findClarityIdx(result.clarities, oldClarity);

      debugPrint(
        '[normalizeConfig] caratChange — '
        'color "$oldColor" → idx $colorIdx | '
        'clarity "$oldClarity" → idx $clarityIdx',
      );

      return newConfig.copyWith(
        shapeType: result.shapeType,
        colorIndex: colorIdx,
        clarityIndex: clarityIdx,
      );

    // -----------------------------------------------------------------------
    // COLOR CHANGE  →  shapeType transitions (yellow ↔ regular); keep carat
    //   • user just picked a color → colorIndex in newConfig is already set
    //   • try to keep previous clarity; fall back to first if out of range
    // -----------------------------------------------------------------------
    case NormalizeTrigger.colorChange:
      // The user picked a color by index in the OLD options list.
      // Changing shapeType causes colorOptions to be recomputed, so the same
      // index may point to a completely different color in the new list
      // (e.g. index 3 = "Yellow Vivid" in a short list but "G" in a full list).
      // Re-anchor by VALUE before the engine resolves shapeType.
      final selectedColor = _safeGet(
        oldConfig.colorOptions,
        newConfig.colorIndex,
      );
      final anchoredColorIdx = _findColorIdx(
        newConfig.colorOptions,
        selectedColor,
      );
      final configForResolve = newConfig.copyWith(colorIndex: anchoredColorIdx);

      final result = engine.resolve(configForResolve);

      final oldClarity = _safeGet(
        oldConfig.clarityOptions,
        oldConfig.clarityIndex,
      );
      final clarityIdx = _findClarityIdx(result.clarities, oldClarity);

      debugPrint(
        '[normalizeConfig] colorChange — '
        'picked "$selectedColor" anchored to idx $anchoredColorIdx | '
        'shapeType ${oldConfig.shapeType} → ${result.shapeType} | '
        'clarity "$oldClarity" → idx $clarityIdx',
      );

      return newConfig.copyWith(
        shapeType: result.shapeType,
        colorIndex: anchoredColorIdx,
        clarityIndex: clarityIdx,
      );

    // -----------------------------------------------------------------------
    // CLARITY CHANGE  →  nothing else changes; return as-is
    // -----------------------------------------------------------------------
    case NormalizeTrigger.clarityChange:
      debugPrint('[normalizeConfig] clarityChange — no side-effects');
      return newConfig;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _safeGet(List<String> list, int index) =>
    list[index.clamp(0, list.length - 1)];

/// Returns the index of [value] in [list].
/// Falls back to first non-yellow entry, then 0.
int _findColorIdx(List<String> list, String value) {
  final idx = list.indexOf(value);
  if (idx >= 0) return idx;

  // value no longer in list — fall back to first non-yellow color
  final fallback = list.indexWhere(
    (c) => c != 'Yellow Vivid' && c != 'Yellow Intense',
  );
  return fallback >= 0 ? fallback : 0;
}

/// Returns the index of [value] in [list], or 0 if not found.
int _findClarityIdx(List<String> list, String value) {
  final idx = list.indexOf(value);
  return idx >= 0 ? idx : 0;
}
