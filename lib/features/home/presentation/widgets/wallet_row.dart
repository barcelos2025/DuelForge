import 'package:flutter/material.dart';
import '../../../../ui/theme/df_theme.dart';

class WalletRow extends StatelessWidget {
  const WalletRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildResourcePill(
            icon: Icons.monetization_on,
            value: '12,450',
            color: DFTheme.gold,
            label: 'Ouro',
          ),
          const SizedBox(width: 8),
          _buildResourcePill(
            icon: Icons.diamond,
            value: '350',
            color: DFTheme.cyan,
            label: 'Gemas',
          ),
          const SizedBox(width: 8),
          _buildResourcePill(
            icon: Icons.flash_on,
            value: '10/10',
            color: DFTheme.purple,
            label: 'Energia',
          ),
        ],
      ),
    );
  }

  Widget _buildResourcePill({
    required IconData icon,
    required String value,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: color, size: 10),
          ),
        ],
      ),
    );
  }
}
