import 'package:flutter/material.dart';
import '../../ui/theme/duel_colors.dart';
import '../../ui/theme/duel_typography.dart';
import '../../ui/widgets/df_button.dart';
import '../../ui/widgets/df_card.dart';

/// Tela de teste para visualizar as mudanças do UI Kit
class UIKitTestScreen extends StatelessWidget {
  const UIKitTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuelColors.background,
      appBar: AppBar(
        title: const Text('UI Kit Test'),
        backgroundColor: DuelColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Text(
              'DUEL FORGE UI KIT',
              style: DuelTypography.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Teste Visual das Mudanças',
              style: DuelTypography.bodyMedium,
            ),
            
            const SizedBox(height: 32),
            
            // Seção de Cores
            _buildSection(
              'Cores',
              Column(
                children: [
                  _buildColorSwatch('Background', DuelColors.background),
                  _buildColorSwatch('Surface', DuelColors.surface),
                  _buildColorSwatch('Primary (Cyan)', DuelColors.primary),
                  _buildColorSwatch('Secondary (Purple)', DuelColors.secondary),
                  _buildColorSwatch('Gold', DuelColors.accentGold),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Seção de Tipografia
            _buildSection(
              'Tipografia',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large (Cinzel)', style: DuelTypography.displayLarge),
                  const SizedBox(height: 8),
                  Text('Display Medium (Cinzel)', style: DuelTypography.displayMedium),
                  const SizedBox(height: 8),
                  Text('Display Small (Cinzel)', style: DuelTypography.displaySmall),
                  const SizedBox(height: 16),
                  Text('Body Large (Inter)', style: DuelTypography.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Body Medium (Inter)', style: DuelTypography.bodyMedium),
                  const SizedBox(height: 8),
                  Text('LABEL CAPS (INTER)', style: DuelTypography.labelCaps),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Seção de Botões
            _buildSection(
              'Botões',
              Column(
                children: [
                  DFButton(
                    label: 'Primary Button',
                    onPressed: () {},
                    type: DFButtonType.primary,
                  ),
                  const SizedBox(height: 12),
                  DFButton(
                    label: 'Secondary Button',
                    onPressed: () {},
                    type: DFButtonType.secondary,
                  ),
                  const SizedBox(height: 12),
                  DFButton(
                    label: 'Ghost Button',
                    onPressed: () {},
                    type: DFButtonType.ghost,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Seção de Cards
            _buildSection(
              'Cards',
              Column(
                children: [
                  DFCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Card Padrão', style: DuelTypography.displaySmall),
                          const SizedBox(height: 8),
                          Text('Este é um card com o estilo glassmorphic do UI Kit.',
                              style: DuelTypography.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Cores de Raridade
            _buildSection(
              'Cores de Raridade',
              Column(
                children: [
                  _buildRarityCard('Comum', DuelColors.rarityCommon),
                  const SizedBox(height: 8),
                  _buildRarityCard('Raro', DuelColors.rarityRare),
                  const SizedBox(height: 8),
                  _buildRarityCard('Épico', DuelColors.rarityEpic),
                  const SizedBox(height: 8),
                  _buildRarityCard('Lendário', DuelColors.rarityLegendary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: DuelTypography.labelCaps.copyWith(
          color: DuelColors.primary,
          fontSize: 14,
        )),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
  
  Widget _buildColorSwatch(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: DuelTypography.bodyMedium),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: DuelTypography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    color: DuelColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRarityCard(String rarity, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuelColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: color, size: 24),
          const SizedBox(width: 12),
          Text(rarity, style: DuelTypography.bodyLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
