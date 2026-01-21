import 'dart:async';
import 'package:flame/components.dart';
import 'duelforge_vfx_bus.dart';
import 'duelforge_vfx_factory.dart';
import 'duelforge_vfx_config.dart';

/// Sistema que escuta o EventBus e spawna os componentes visuais no jogo.
class DuelForgeVfxSystem extends Component {
  StreamSubscription? _subscription;
  
  // Rate limiting para evitar poluição visual
  final Map<String, double> _cooldowns = {};

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _subscription = DuelForgeVfxBus().stream.listen(_handleEvent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Limpa cooldowns expirados
    _cooldowns.removeWhere((key, value) {
      final novoValor = value - dt;
      if (novoValor <= 0) return true;
      _cooldowns[key] = novoValor;
      return false;
    });
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }

  void _handleEvent(VfxEvent event) {
    // Verifica tipo de evento e delega
    if (event is EventoAcerto) {
      _spawnAcerto(event);
    } else if (event is EventoTorreAtira) {
      // Implementar rastro de projétil se necessário
    } else if (event is EventoTorreDestruida) {
      add(DuelForgeVfxFactory.criarDestruicaoTorre(event.posicao));
    } else if (event is EventoFeiticoCast) {
      _spawnFeitico(event);
    } else if (event is EventoCartaDeploy) {
      add(DuelForgeVfxFactory.criarImpactoMagico(event.posicao));
    } else if (event is EventoRaioImpacto) {
      add(DuelForgeVfxFactory.criarRaioImpacto(event.pontoImpacto));
    }
  }

  void _spawnAcerto(EventoAcerto event) {
    // Rate limit por posição aproximada para evitar spam em área
    final key = 'acerto_${event.pontoImpacto.x.toInt()}_${event.pontoImpacto.y.toInt()}';
    if (_cooldowns.containsKey(key)) return;
    _cooldowns[key] = 0.05; // 50ms cooldown

    add(DuelForgeVfxFactory.criarHitFlash(event.pontoImpacto));

    switch (event.tipoDano) {
      case 'fisico':
        add(DuelForgeVfxFactory.criarImpactoFisico(event.pontoImpacto));
        break;
      case 'magico':
        add(DuelForgeVfxFactory.criarImpactoMagico(event.pontoImpacto));
        break;
      case 'fogo':
        add(DuelForgeVfxFactory.criarExplosaoFogo(event.pontoImpacto));
        break;
      case 'gelo':
        add(DuelForgeVfxFactory.criarExplosaoGelo(event.pontoImpacto));
        break;
      case 'veneno':
        // Veneno geralmente é tick, mas se tiver impacto inicial:
        add(DuelForgeVfxFactory.criarNuvemVeneno(event.pontoImpacto));
        break;
      default:
        add(DuelForgeVfxFactory.criarImpactoFisico(event.pontoImpacto));
    }
  }

  void _spawnFeitico(EventoFeiticoCast event) {
    switch (event.spellId) {
      case 'poison':
        add(DuelForgeVfxFactory.criarNuvemVeneno(event.areaCentro));
        break;
      case 'hailstorm':
        // Simular vários impactos na área
        for (int i = 0; i < 5; i++) {
          final offset = DuelForgeVfxFactory._randomVector(event.raio);
          add(DuelForgeVfxFactory.criarExplosaoGelo(event.areaCentro + offset));
        }
        break;
      case 'fireball': // Exemplo
        add(DuelForgeVfxFactory.criarExplosaoFogo(event.areaCentro));
        break;
      default:
        add(DuelForgeVfxFactory.criarImpactoMagico(event.areaCentro));
    }
  }
}
