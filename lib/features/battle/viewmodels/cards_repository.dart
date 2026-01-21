import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../models/carta.dart';

class CardsRepository {
  Map<String, Carta> _mapa = const {};
  List<String> _starterDeck = const [];
  double _regen = 1.0;
  double _max = 10.0;

  /// Carrega as cartas, priorizando o Supabase e usando JSON local como fallback.
  Future<void> carregar() async {
    try {
      // 1. Carregar Configurações e Deck Inicial do JSON (Fonte de Verdade para Regras)
      final texto = await rootBundle.loadString(AppConfig.caminhoCartasJson);
      final jsonDados = jsonDecode(texto) as Map<String, dynamic>;

      _processarConfiguracoes(jsonDados);

      // 2. Tentar carregar Cartas do Supabase
      bool carregouDoBanco = await _carregarDoSupabase();

      // 3. Fallback: Se o banco falhar ou estiver vazio, carregar do JSON
      if (!carregouDoBanco || _mapa.isEmpty) {
        debugPrint('⚠️ CardsRepository: Usando fallback local (JSON).');
        _carregarDoJson(jsonDados);
      } else {
        debugPrint('✅ CardsRepository: ${_mapa.length} cartas carregadas do Supabase.');
      }

    } catch (e, stack) {
      debugPrint('❌ Erro fatal no CardsRepository: $e');
      debugPrint(stack.toString());
      // Em último caso, tenta garantir que o mapa não fique vazio se possível
    }
  }

  void _processarConfiguracoes(Map<String, dynamic> dados) {
    if (dados['resource'] != null) {
      final resource = dados['resource'] as Map<String, dynamic>;
      _regen = (resource['regen_per_sec'] as num?)?.toDouble() ?? 1.0;
      _max = (resource['max'] as num?)?.toDouble() ?? 10.0;
    }
    
    if (dados['starter_deck'] != null) {
      _starterDeck = (dados['starter_deck'] as List).cast<String>();
    }
  }

  Future<bool> _carregarDoSupabase() async {
    try {
      // Verifica se o Supabase foi inicializado
      if (Supabase.instance.client.auth.currentSession == null && 
          Supabase.instance.client.auth.currentUser == null) {
        // Se não houver sessão, algumas políticas RLS podem bloquear, 
        // mas a tabela 'cards' deve ser pública.
        // Continuamos mesmo assim.
      }

      final response = await Supabase.instance.client
          .from('cards')
          .select();

      if (response.isNotEmpty) {
        final List<Carta> cartas = [];
        
        for (final row in response) {
          try {
            final stats = row['base_stats'] != null 
                ? (row['base_stats'] as Map<String, dynamic>) 
                : <String, dynamic>{};
            
            // Mapeamento SQL -> Modelo Carta
            final Map<String, dynamic> data = {
              ...stats, // Espalha hp, dano, etc.
              'id': row['id'],
              'nome': row['name'],
              'tipo': _mapearTipoSql(row['type']),
              'raridade': row['rarity'], // 'common', 'rare', etc.
              'custo': row['cost'],
              'image_path': row['asset_path'],
              'descricao': row['description'],
            };
            
            cartas.add(Carta.fromJson(data));
          } catch (e) {
            debugPrint('Erro ao processar carta do banco (${row['id']}): $e');
          }
        }

        if (cartas.isNotEmpty) {
          _mapa = {for (final c in cartas) c.id: c};
          return true;
        }
      }
    } catch (e) {
      debugPrint('Aviso: Falha ao conectar/ler do Supabase: $e');
    }
    return false;
  }

  void _carregarDoJson(Map<String, dynamic> dados) {
    if (dados['cards'] != null) {
      final lista = (dados['cards'] as List).cast<Map<String, dynamic>>();
      final cartas = lista.map(Carta.fromJson).toList();
      _mapa = {for (final c in cartas) c.id: c};
    }
  }

  String _mapearTipoSql(String? sqlType) {
    switch (sqlType) {
      case 'unit': return 'tropa';
      case 'spell': return 'feitico';
      case 'building': return 'construcao';
      default: return 'tropa';
    }
  }

  // Getters e Métodos Públicos
  bool get carregado => _mapa.isNotEmpty;
  double get regenPorSegundo => _regen;
  double get runaMax => _max;

  List<Carta> starterDeck() {
    // Filtra IDs que realmente existem no mapa para evitar crash
    return _starterDeck
        .where((id) => _mapa.containsKey(id))
        .map((id) => _mapa[id]!)
        .toList();
  }

  Carta porId(String id) {
    if (!_mapa.containsKey(id)) {
      // Retorna uma carta "dummy" ou lança erro controlado para não quebrar a UI
      debugPrint('⚠️ Carta não encontrada: $id');
      return Carta(
        id: id,
        nome: 'Desconhecida',
        tipo: TipoCarta.tropa,
        raridade: 'comum',
        custo: 0,
        poder: 0,
        imagePath: null,
      );
    }
    return _mapa[id]!;
  }

  List<Carta> get todasCartas => _mapa.values.toList();
}
