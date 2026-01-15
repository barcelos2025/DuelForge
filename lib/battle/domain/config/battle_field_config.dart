
import 'package:flame/components.dart';

class BattleFieldConfig {
  // Dimensões do Mundo (Unidades lógicas, não pixels)
  // Largura 18 (9 para cada lado do centro 0)
  // Altura 30 (15 para cada lado do centro 0)
  static const double width = 18.0;
  static const double height = 30.0;
  
  // Lanes
  static const double laneLeftX = -5.0;
  static const double laneRightX = 5.0;
  
  // Spawn Zones (Y)
  static const double spawnPlayerY = 12.0; // Perto do fundo
  static const double spawnEnemyY = -12.0; // Perto do topo
  
  // Deploy Zones
  // Player pode jogar em Y > 0 (Metade inferior)
  // Enemy joga em Y < 0 (Metade superior)
  static bool isValidDeploy(Vector2 pos, bool isPlayer) {
    if (pos.x < -width/2 || pos.x > width/2) return false;
    if (pos.y < -height/2 || pos.y > height/2) return false;
    
    if (isPlayer) {
      return pos.y > 0;
    } else {
      return pos.y < 0;
    }
  }

  // Snap to Lane
  // Retorna a posição X da lane mais próxima
  static double snapToLane(double x) {
    final distLeft = (x - laneLeftX).abs();
    final distRight = (x - laneRightX).abs();
    
    if (distLeft < distRight) {
      return laneLeftX;
    } else {
      return laneRightX;
    }
  }

  // Conversão de Coordenadas (Screen -> World)
  // Assume que a tela mapeia width para width do mundo
  // Isso depende da câmera, mas aqui fornecemos utilitários lógicos
  static Vector2 normalizePosition(Vector2 screenPos, Vector2 screenSize) {
    // Normaliza para -1..1
    final nx = (screenPos.x / screenSize.x) * 2 - 1;
    final ny = (screenPos.y / screenSize.y) * 2 - 1;
    
    // Escala para mundo
    return Vector2(nx * (width / 2), ny * (height / 2));
  }
}
