
enum TipoCarta { tropa, feitico, construcao }

class Carta {
  final String id;
  final String nome;
  final TipoCarta tipo;
  final String raridade;
  final int custo;
  final int poder;

  final int? hp;
  final int? dano;
  final double? velocidade;
  final double? alcance;

  final double? raio;
  final double? duracao;
  final double? dps;
  final double? slow;
  final int? saltos;
  final double? linkPct;
  final String? efeito;
  final String? imagePath;
  final String? descricao;

  const Carta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.raridade,
    required this.custo,
    required this.poder,
    this.hp,
    this.dano,
    this.velocidade,
    this.alcance,
    this.raio,
    this.duracao,
    this.dps,
    this.slow,
    this.saltos,
    this.linkPct,
    this.efeito,
    this.imagePath,
    this.descricao,
  });

  static TipoCarta tipoDeString(String valor) {
    switch (valor) {
      case 'tropa':
        return TipoCarta.tropa;
      case 'feitico':
        return TipoCarta.feitico;
      case 'construcao':
        return TipoCarta.construcao;
      default:
        return TipoCarta.tropa;
    }
  }

  factory Carta.fromJson(Map<String, dynamic> json) {
    return Carta(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: tipoDeString(json['tipo'] as String),
      raridade: (json['raridade'] as String?) ?? 'comum',
      custo: (json['custo'] as num).toInt(),
      poder: (json['poder'] as num).toInt(),
      hp: (json['hp'] as num?)?.toInt(),
      dano: (json['dano'] as num?)?.toInt(),
      velocidade: (json['velocidade'] as num?)?.toDouble(),
      alcance: (json['alcance'] as num?)?.toDouble(),
      raio: (json['raio'] as num?)?.toDouble(),
      duracao: (json['duracao'] as num?)?.toDouble(),
      dps: (json['dps'] as num?)?.toDouble(),
      slow: (json['slow'] as num?)?.toDouble(),
      saltos: (json['saltos'] as num?)?.toInt(),
      linkPct: (json['link_pct'] as num?)?.toDouble(),
      efeito: (json['efeito'] as String?),
      imagePath: json['image_path'] as String?,
    );
  }
}
