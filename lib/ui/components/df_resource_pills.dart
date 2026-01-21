import 'package:flutter/material.dart';
import '../../ui/theme/df_theme.dart';
import '../../core/utils/number_formatter.dart';

class DFResourcePills extends StatelessWidget {
  final List<ResourceItem> items;

  const DFResourcePills({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) => _ResourcePill(item: item)).toList(),
    );
  }
}

class ResourceItem {
  final String label; // e.g. "Ouro"
  final int value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  ResourceItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });
}

class _ResourcePill extends StatefulWidget {
  final ResourceItem item;

  const _ResourcePill({required this.item});

  @override
  State<_ResourcePill> createState() => _ResourcePillState();
}

class _ResourcePillState extends State<_ResourcePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  int? _oldValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.item.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _ResourcePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.value != _oldValue) {
      _oldValue = widget.item.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity( 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.item.accentColor.withOpacity( 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.item.accentColor.withOpacity( 0.1),
              blurRadius: 8,
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.item.icon, size: 16, color: widget.item.accentColor),
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: Text(
                    NumberFormatter.format(widget.item.value),
                    style: DFTheme.labelBold.copyWith(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
