import 'package:flutter/material.dart';
import '../../../../battle/data/card_catalog.dart';
import '../../services/card_progression_service.dart';
import 'card_info_modal.dart';

class CardActionPanel extends StatefulWidget {
  final CardDefinition card;
  final bool isInDeck;
  final VoidCallback onToggleDeck;
  final VoidCallback onDismiss;

  const CardActionPanel({
    super.key,
    required this.card,
    required this.isInDeck,
    required this.onToggleDeck,
    required this.onDismiss,
  });

  @override
  State<CardActionPanel> createState() => _CardActionPanelState();
}

class _CardActionPanelState extends State<CardActionPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final progression = CardProgressionService();
    final level = progression.getLevel(widget.card.cardId);
    final shards = progression.getShards(widget.card.cardId);
    final canEvolve = progression.canEvolve(widget.card.cardId);
    final nextShards = progression.getShardsForNextLevel(level, widget.card.rarity);
    final nextCoins = progression.getCoinsForNextLevel(level);

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: _close,
          child: Container(
            color: Colors.black54,
          ),
        ),
        
        // Panel
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1320),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: Border(top: BorderSide(color: Colors.cyan.withOpacity(0.3))),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Info Summary
                    Text(
                      widget.card.displayName.isNotEmpty ? widget.card.displayName : 'Carta Selecionada',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nível $level • ${widget.card.rarity.name.toUpperCase()}',
                      style: TextStyle(color: Colors.cyanAccent.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 24),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // INFO Button
                        _PanelButton(
                          label: 'INFO',
                          icon: Icons.info_outline,
                          color: Colors.blueGrey,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => CardInfoModal(card: widget.card, level: level),
                            );
                          },
                        ),

                        // EVOLVE Button (Conditional)
                        if (canEvolve)
                          _PanelButton(
                            label: 'EVOLUIR',
                            icon: Icons.arrow_upward,
                            color: Colors.amber,
                            isPrimary: true,
                            subLabel: '$nextCoins 💰',
                            onTap: () => _confirmEvolve(context, progression, nextCoins, nextShards),
                          )
                        else
                          // Show progress if not ready
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Progresso',
                                    style: TextStyle(color: Colors.white38, fontSize: 10),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: nextShards > 0 ? shards / nextShards : 1.0,
                                    backgroundColor: Colors.white10,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$shards / $nextShards Shards',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // USE Button
                        _PanelButton(
                          label: widget.isInDeck ? 'REMOVER' : 'USAR',
                          icon: widget.isInDeck ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          color: widget.isInDeck ? Colors.redAccent : Colors.greenAccent,
                          onTap: () {
                            widget.onToggleDeck();
                            _close();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmEvolve(BuildContext context, CardProgressionService progression, int coins, int shards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Evoluir Carta?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja gastar $coins moedas e $shards shards para evoluir esta carta?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await progression.evolve(widget.card.cardId);
              if (success && mounted) {
                setState(() {}); // Refresh panel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carta Evoluída com Sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('EVOLUIR', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PanelButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  final String? subLabel;

  const _PanelButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
    this.subLabel,
  });

  @override
  State<_PanelButton> createState() => _PanelButtonState();
}

class _PanelButtonState extends State<_PanelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.isPrimary ? 120 : 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF131B26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary ? widget.color : widget.color.withOpacity(0.5),
              width: widget.isPrimary ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(widget.isPrimary ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (widget.subLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subLabel!,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
