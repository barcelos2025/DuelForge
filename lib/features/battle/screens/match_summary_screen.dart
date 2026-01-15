import 'package:flutter/material.dart';
import '../../../battle/domain/services/telemetry_service.dart';

class MatchSummaryScreen extends StatelessWidget {
  final MatchTelemetry telemetry;
  final bool victory;

  const MatchSummaryScreen({
    super.key,
    required this.telemetry,
    required this.victory,
  });

  @override
  Widget build(BuildContext context) {
    final mvpCard = telemetry.getMvp();
    final mostPlayed = _getMostPlayed();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text(victory ? 'VITÓRIA!' : 'DERROTA'),
        backgroundColor: victory ? Colors.green.shade700 : Colors.red.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MVP Card
            _buildMvpCard(mvpCard),
            const SizedBox(height: 16),

            // Match Stats
            _buildStatCard(
              'Estatísticas da Partida',
              [
                _StatRow(label: 'Duração', value: '${telemetry.matchDuration.toStringAsFixed(0)}s'),
                _StatRow(label: 'Torres Destruídas', value: '${telemetry.towersDestroyed}'),
                _StatRow(label: 'Cartas Jogadas', value: '${telemetry.cardsPlayed.values.fold(0, (a, b) => a + b)}'),
              ],
            ),
            const SizedBox(height: 16),

            // Most Played Card
            if (mostPlayed != null)
              _buildStatCard(
                'Carta Mais Jogada',
                [
                  _StatRow(
                    label: _formatCardName(mostPlayed.$1),
                    value: '${mostPlayed.$2}x',
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Damage Breakdown
            _buildDamageBreakdown(),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMvpCard(String mvpCard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          const Text(
            'MVP DA PARTIDA',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCardName(mvpCard),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${telemetry.damageDealt[mvpCard]?.toStringAsFixed(0) ?? '0'} de dano',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...stats,
        ],
      ),
    );
  }

  Widget _buildDamageBreakdown() {
    final sortedDamage = telemetry.damageDealt.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dano por Carta',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sortedDamage.take(5).map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatCardName(entry.key),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  entry.value.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  (String, int)? _getMostPlayed() {
    if (telemetry.cardsPlayed.isEmpty) return null;
    var maxCard = '';
    var maxCount = 0;
    telemetry.cardsPlayed.forEach((card, count) {
      if (count > maxCount) {
        maxCount = count;
        maxCard = card;
      }
    });
    return (maxCard, maxCount);
  }

  String _formatCardName(String cardId) {
    return cardId
        .split('_')
        .skip(2)
        .join(' ')
        .replaceAll('.jpg', '')
        .replaceAll('.png', '')
        .toUpperCase();
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
