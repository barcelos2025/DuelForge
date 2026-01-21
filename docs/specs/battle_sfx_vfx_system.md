# Sistema de SFX e VFX de Batalha

**Contexto:** DuelForge (Flutter + Flame)  
**Objetivo:** Integrar feedback audiovisual (Juiciness) de forma desacoplada da lógica de simulação.

---

## 1. Arquitetura de Eventos (The Hook)

A simulação (`BattleEngine`) não deve saber tocar sons ou criar partículas. Ela apenas emite eventos puros.

### `BattleEventBus`
Um barramento de eventos simples que conecta a Simulação aos Gerenciadores de Feedback.

```dart
enum BattleEventType {
  CARD_DEPLOY,
  MANA_TICK,
  TOWER_SHOT,
  TOWER_HIT,
  TOWER_DESTROY,
  UNIT_SPAWN,
  UNIT_ATTACK,
  SPELL_CAST,
  STATUS_APPLY, // Freeze, Poison
  UNIT_DEATH
}

class BattleEvent {
  final BattleEventType type;
  final String? entityId; // Quem causou
  final String? targetId; // Quem sofreu
  final Vector2? position; // Onde ocorreu
  final String? metadata; // ID da carta, tipo de status, etc.
  final double value; // Dano, cura, etc.

  BattleEvent({required this.type, this.position, this.metadata, ...});
}
```

---

## 2. Gerenciador de Áudio (`BattleAudioManager`)

Responsável por tocar SFX usando `flame_audio`.

### Configuração Data-Driven (Mapeamento)
```dart
const Map<String, String> sfxMap = {
  'deploy_archer': 'sfx/deploy_troop.mp3',
  'deploy_fireball': 'sfx/spell_cast_fire.mp3',
  'attack_arrow': 'sfx/arrow_release.mp3',
  'hit_flesh': 'sfx/hit_flesh_01.mp3',
  'tower_shot': 'sfx/tower_shot_heavy.mp3',
  'tower_collapse': 'sfx/structure_collapse.mp3',
  'status_freeze': 'sfx/ice_crack.mp3',
};
```

### Rate Limiting (Anti-Spam)
Para evitar que 20 esqueletos atacando ao mesmo tempo estour os ouvidos do jogador.

```dart
class BattleAudioManager {
  final Map<String, int> _lastPlayTime = {};
  final int _minIntervalMs = 50; // Mínimo 50ms entre sons iguais

  void onEvent(BattleEvent event) {
    String? sfxKey = _resolveSfxKey(event);
    if (sfxKey == null) return;

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - (_lastPlayTime[sfxKey] ?? 0) < _minIntervalMs) {
      return; // Skip (Rate Limit)
    }

    _lastPlayTime[sfxKey] = now;
    
    try {
      FlameAudio.play(sfxKey);
    } catch (e) {
      print('Erro ao tocar SFX: $sfxKey'); // Fallback silencioso
    }
  }

  String? _resolveSfxKey(BattleEvent event) {
    // Lógica para mapear Evento -> Arquivo
    // Ex: UNIT_ATTACK + metadata="archer" -> "attack_arrow"
  }
}
```

---

## 3. Gerenciador de Efeitos Visuais (`BattleVFXManager`)

Responsável por instanciar componentes visuais no Flame (`SpriteAnimationComponent`, `ParticleSystemComponent`).

### Catálogo de VFX
1.  **Selection Glow:** Shader ou Sprite ciano atrás da unidade.
2.  **Impact Dust:** Animação rápida (spritesheet) de poeira ao spawnar ou levar dano físico.
3.  **Ice Crystals:** Partículas estáticas que somem (fade out) ou spritesheet de gelo quebrando.
4.  **Poison Smoke:** Partículas verdes escuras subindo (estilo fumaça mágica, não tóxica sci-fi).
5.  **Lightning Arc:** Sprite animado conectando A e B (Runic Style).

### Implementação do Handler
```dart
class BattleVFXManager {
  final FlameGame game;

  void onEvent(BattleEvent event) {
    switch (event.type) {
      case BattleEventType.CARD_DEPLOY:
        _spawnDeployDust(event.position!);
        break;
      case BattleEventType.TOWER_DESTROY:
        _spawnRubbleCollapse(event.position!);
        _shakeCamera();
        break;
      case BattleEventType.STATUS_APPLY:
        if (event.metadata == 'FREEZE') {
          _spawnIceEffect(event.targetId!);
        }
        break;
      // ...
    }
  }

  void _spawnDeployDust(Vector2 pos) {
    final dust = OneShotAnimation(
      'vfx/dust_poof.png', 
      position: pos, 
      stepTime: 0.05
    );
    game.add(dust);
  }
}
```

---

## 4. Integração com o Loop Principal

No `BattleVisuals` (a camada de View), registramos os listeners.

```dart
void init() {
  // Conecta o bus
  battleEventBus.listen((event) {
    audioManager.onEvent(event);
    vfxManager.onEvent(event);
  });
}
```

---

## 5. Estratégia de Fallback e Assets

1.  **Missing Assets:**
    *   Se um arquivo de áudio não existir, o `BattleAudioManager` captura a exceção e loga um aviso, mas **não crasha** o jogo.
    *   Se uma animação de VFX falhar, desenhar um círculo de cor sólida temporário (Debug Placeholder) ou simplesmente não mostrar nada.

2.  **Performance:**
    *   **Pool de Partículas:** Para efeitos muito frequentes (tiros, hit sparks), usar Object Pooling para não alocar memória a cada frame.
    *   **Culling:** Não tocar sons nem renderizar partículas se o evento ocorrer muito fora da tela (embora em DuelForge a arena caiba inteira na tela).

---

## 6. Lista de Assets Necessários (Mapeamento Inicial)

| Evento | Condição | SFX Sugerido | VFX Sugerido |
| :--- | :--- | :--- | :--- |
| **Deploy** | Genérico | `sfx_deploy_thud.mp3` | `vfx_dust_cloud` |
| **Attack** | Arqueira | `sfx_bow_loose.mp3` | - |
| **Attack** | Mago | `sfx_magic_cast.mp3` | `vfx_hand_glow` |
| **Hit** | Físico | `sfx_impact_flesh.mp3` | `vfx_blood_spark` (leve) |
| **Hit** | Escudo | `sfx_impact_metal.mp3` | `vfx_spark_yellow` |
| **Tower** | Tiro | `sfx_tower_fire.mp3` | `vfx_muzzle_flash` |
| **Spell** | Raio | `sfx_thunder_crack.mp3` | `vfx_lightning_bolt` |
| **Death** | Unidade | `sfx_unit_die.mp3` | `vfx_ghost_soul` (subindo) |

Esta estrutura garante que o jogo fique "suculento" (Juicy) sem misturar código de renderização/áudio com a lógica matemática da batalha.
