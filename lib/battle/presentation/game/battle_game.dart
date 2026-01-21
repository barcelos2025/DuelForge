
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../../domain/config/battle_field_config.dart';
import '../../domain/entities/match_state.dart';
import '../../domain/entities/battle_objects.dart';
import '../../domain/logic/match_loop.dart';
import 'components/unit_component.dart';
import 'components/unit_3d_fake_component.dart'; // Changed
import 'components/tower_3d_fake_component.dart'; // Changed
import 'components/spell_area_component.dart';
import 'components/building_3d_fake_component.dart'; // Changed
import 'components/ghost_component.dart';
import '../../../features/battle/models/carta.dart'; // For UI Model
import '../../domain/config/battle_tuning.dart';
import 'components/damage_number_component.dart';
import 'components/damage_number_component.dart';

class BattleGame extends FlameGame with TapDetector, PanDetector {
  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent to show Flutter background

  final MatchState matchState;
  final MatchLoop matchLoop;
  final Function(Carta, Vector2) onDeploy;
  final VoidCallback onCancel;
  
  final String arenaAssetPath; // Added
  
  // Layers
  late final World world;
  late final CameraComponent cameraComponent;
  
  // Component Maps for Sync
  final Map<String, Unit3DFakeComponent> _unitComponents = {}; 
  final Map<String, Building3DFakeComponent> _buildingComponents = {};
  final Map<String, Tower3DFakeComponent> _towerComponents = {};
  final Map<String, SpellAreaComponent> _spellComponents = {};
  
  // Pooling
  final List<DamageNumberComponent> _damageNumberPool = [];

  // Interaction
  GhostComponent? _ghost;
  Carta? _selectedCard;

  BattleGame({
    required this.matchState, 
    required this.matchLoop,
    required this.onDeploy,
    required this.onCancel,
    required this.arenaAssetPath, // Added
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 0. Background is now handled by Flutter Layer in BattleScreen for robustness
    // add(ArenaBackgroundComponent(assetPath: arenaAssetPath));

    // 1. Setup World & Camera
    world = World();
    cameraComponent = CameraComponent(world: world);
    
    // Fit 18x30 world into view
    cameraComponent.viewfinder.anchor = Anchor.center;
    cameraComponent.viewfinder.zoom = 20.0; // Approx zoom for 400px width / 18 units
    
    add(world);
    add(cameraComponent);



    // 2. Initial Sync
    _syncState();
    
    // Debug: List all components to find the "Pink Screen" culprit
    debugPrint('BattleGame: Components in world: ${world.children.length}');
    for (final c in world.children) {
      debugPrint(' - World Child: ${c.runtimeType} pos=${(c as PositionComponent).position} size=${c.size}');
    }
    debugPrint('BattleGame: Components in game: ${children.length}');
    for (final c in children) {
       if (c is PositionComponent) {
         debugPrint(' - Game Child: ${c.runtimeType} pos=${c.position} size=${c.size}');
       } else {
         debugPrint(' - Game Child: ${c.runtimeType}');
       }
    }
    resumeEngine();
  }

  DamageNumberComponent getDamageNumber(int value, Vector2 position) {
    DamageNumberComponent? comp;
    if (_damageNumberPool.isNotEmpty) {
      comp = _damageNumberPool.removeLast();
      comp.reset(value, position);
    } else {
      comp = DamageNumberComponent(value: value, position: position);
    }
    return comp;
  }
  
  void returnDamageNumber(DamageNumberComponent comp) {
    comp.removeFromParent();
    _damageNumberPool.add(comp);
  }

  void selectCard(Carta carta) {
    if (_ghost != null) {
      _ghost!.removeFromParent();
    }
    _selectedCard = carta;
    
    // Create Ghost
    _ghost = GhostComponent(
      cardId: carta.id,
      isSpell: carta.tipo == TipoCarta.feitico,
      range: carta.alcance ?? 0,
      radius: carta.raio ?? 0,
    );
    // Initial pos off-screen or center?
    _ghost!.position = Vector2(0, 0); 
    world.add(_ghost!);
  }

  void deselectCard() {
    if (_ghost != null) {
      _ghost!.removeFromParent();
      _ghost = null;
    }
    _selectedCard = null;
  }

  void updateGhost(Vector2 screenPosition) {
    if (_ghost == null || _selectedCard == null) return;

    // Screen -> World
    final worldPos = cameraComponent.viewfinder.globalToLocal(screenPosition);
    
    // Clamp to Field Bounds & Player Side (Bottom Half: Y > 0)
    worldPos.x = worldPos.x.clamp(-BattleFieldConfig.width / 2, BattleFieldConfig.width / 2);
    worldPos.y = worldPos.y.clamp(0.0, BattleFieldConfig.height / 2);

    // Snap logic
    if (_selectedCard!.tipo != TipoCarta.feitico) {
      worldPos.x = BattleFieldConfig.snapToLane(worldPos.x);
    }
    
    _ghost!.position = worldPos;
    
    // Validate
    final isValid = BattleFieldConfig.isValidDeploy(worldPos, true);
    _ghost!.isValid = isValid;
  }

  void attemptDeploy() {
    if (_ghost == null || _selectedCard == null) return;
    
    if (_ghost!.isValid) {
      onDeploy(_selectedCard!, _ghost!.position);
      // deselectCard(); // Handled by VM sync
    } else {
      // Cancel if dropped in invalid area
      onCancel();
      // deselectCard(); // Handled by VM sync
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    updateGhost(info.eventPosition.widget);
  }

  @override
  void onTapUp(TapUpInfo info) {
    attemptDeploy();
  }

  @override
  void onPanStart(DragStartInfo info) {
    updateGhost(info.eventPosition.widget);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    updateGhost(info.eventPosition.widget);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    attemptDeploy();
  }

  @override
  void update(double dt) {
    // Debug Toggles
    debugMode = BattleTuning.debugShowHitboxes;

    // Drive Logic
    try {
      matchLoop.update(dt);
    } catch (e) {
      debugPrint('❌ Error in matchLoop.update: $e');
    }
    
    super.update(dt);
    _syncState();
  }

  void _syncState() {
    // 1. Sync Towers
    for (final tower in matchState.towers) {
      if (!_towerComponents.containsKey(tower.id)) {
        try {
          final comp = Tower3DFakeComponent(tower: tower);
          _towerComponents[tower.id] = comp;
          world.add(comp);
        } catch (e) {
          debugPrint('❌ Error creating Tower component: $e');
        }
      }
    }
    // Cleanup Towers
    _towerComponents.removeWhere((id, comp) {
      if (!comp.isMounted) return true;
      if (!matchState.towers.contains(comp.tower)) {
        if (comp.isDying) return false;
        comp.removeFromParent();
        return true;
      }
      return false;
    });

    // 2. Sync Units & Buildings
    for (final unit in matchState.units) {
      if (unit.isBuilding) {
        // Sync Building
        if (!_buildingComponents.containsKey(unit.id)) {
          try {
            final comp = Building3DFakeComponent(building: unit);
            _buildingComponents[unit.id] = comp;
            world.add(comp);
          } catch (e) {
            debugPrint('❌ Error creating Building component for ${unit.cardId}: $e');
          }
        }
      } else {
        // Sync Unit
        if (!_unitComponents.containsKey(unit.id)) {
          try {
            final comp = Unit3DFakeComponent(unit: unit);
            _unitComponents[unit.id] = comp;
            world.add(comp);
          } catch (e) {
            debugPrint('❌ Error creating Unit component for ${unit.cardId}: $e');
          }
        }
      }
    }
    
    // Cleanup Buildings
    _buildingComponents.removeWhere((id, comp) {
      if (!comp.isMounted) return true;
      if (!matchState.units.contains(comp.building)) {
        if (comp.isDying) return false;
        comp.removeFromParent();
        return true;
      }
      return false;
    });

    // Cleanup Units
    _unitComponents.removeWhere((id, comp) {
      if (!comp.isMounted) return true;
      if (!matchState.units.contains(comp.unit)) {
        if (comp.isDying) return false;
        comp.removeFromParent();
        return true;
      }
      return false;
    });

    // 3. Sync Spells
    for (final spell in matchState.spells) {
      if (!_spellComponents.containsKey(spell.id)) {
        try {
          final comp = SpellAreaComponent(spell: spell);
          _spellComponents[spell.id] = comp;
          world.add(comp);
        } catch (e) {
          debugPrint('❌ Error creating Spell component for ${spell.cardId}: $e');
        }
      }
    }
    _spellComponents.removeWhere((id, comp) {
      if (!matchState.spells.contains(comp.spell) || comp.spell.finished) {
        comp.removeFromParent();
        return true;
      }
      return false;
    });
  }
}
