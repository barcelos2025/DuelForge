import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../battle/data/card_catalog.dart';
import '../../data/card_lore_data.dart';
import '../../../../core/assets/asset_registry.dart';
import '../../domain/models/card_stats.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';
import '../../../../ui/widgets/effects/snow_effect.dart';

class CardInfoModal extends StatefulWidget {
  final CardDefinition card;
  final int level;

  const CardInfoModal({super.key, required this.card, required this.level});

  @override
  State<CardInfoModal> createState() => _CardInfoModalState();
}

class _CardInfoModalState extends State<CardInfoModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate height based on screen size (clamp 0.82–0.92)
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = (screenHeight * 0.88).clamp(600.0, screenHeight * 0.95);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: modalHeight,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            // Backdrop Blur
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: DuelColors.background.withOpacity(0.95),
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // 1. Hero Card Preview (~38% height)
                Expanded(
                  flex: 38,
                  child: _buildHeroHeader(),
                ),

                // 2. Tabs
                _buildTabBar(),

                // 3. Content Area
                Expanded(
                  flex: 62,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildLoreTab(),
                    ],
                  ),
                ),
              ],
            ),

            // Close Button (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Snow Effect
        const Positioned.fill(
          child: SnowEffect(
            particleCount: 50,
            color: Colors.white,
          ),
        ),

        // Card Image
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Image.asset(
              AssetRegistry.getCardAsset(widget.card.cardId),
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
        
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                DuelColors.background.withOpacity(0.2),
                DuelColors.background.withOpacity(0.9),
                DuelColors.background,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        ),

        // Card Info
        Positioned(
          bottom: 16,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Runic Decoration (Subtle)
              Opacity(
                opacity: 0.3,
                child: Text(
                  'RUNES OF POWER', // Placeholder for runic font text
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 10,
                    letterSpacing: 4,
                    color: DuelColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              
              // Title
              Text(
                widget.card.displayName.toUpperCase(),
                style: DuelTypography.displayMedium,
              ),
              
              // Subtitle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRarityColor(widget.card.rarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getRarityColor(widget.card.rarity).withOpacity(0.5)),
                    ),
                    child: Text(
                      'NÍVEL ${widget.level}',
                      style: DuelTypography.labelCaps.copyWith(
                        color: _getRarityColor(widget.card.rarity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${widget.card.rarity.name.toUpperCase()}',
                    style: DuelTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cost Badge
        Positioned(
          top: 24,
          right: 64, // Left of close button
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DuelColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DuelColors.secondary.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${widget.card.cost}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: DuelColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: DuelColors.primary.withOpacity(0.3)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: DuelColors.primary,
        unselectedLabelColor: DuelColors.textSecondary,
        labelStyle: DuelTypography.buttonText,
        tabs: const [
          Tab(text: 'ATRIBUTOS'),
          Tab(text: 'HISTÓRIA'),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = widget.card.stats;
    if (stats == null) return const Center(child: Text('Sem dados'));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stat Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(Icons.category, widget.card.type.name.toUpperCase()),
              _buildStatChip(Icons.stars, stats.role),
              _buildStatChip(Icons.gps_fixed, stats.targets.map((t) => t.name.toUpperCase()).join('/')),
              if (stats.components > 0) _buildStatChip(Icons.group, '${stats.components} UNID.'),
            ],
          ),
          
          const SizedBox(height: 24),

          // 2. Combat Stats Grid
          Text('COMBATE', style: DuelTypography.labelCaps.copyWith(color: DuelColors.primary)),
          const SizedBox(height: 12),
          
          if (stats is UnitStats) _buildUnitGrid(stats),
          if (stats is SpellStats) _buildSpellGrid(stats),
          if (stats is BuildingStats) _buildBuildingGrid(stats),
        ],
      ),
    );
  }

  Widget _buildUnitGrid(UnitStats stats) {
    return _buildGrid([
      _buildStatCard('Vida', '${stats.hitPoints.toInt()}', Icons.favorite),
      _buildStatCard('Dano', '${stats.damagePerHit.toInt()}', Icons.flash_on),
      _buildStatCard('DPS', '${stats.dps.toInt()}', Icons.speed),
      _buildStatCard('Vel. Ataque', '${stats.attacksPerSecond}s', Icons.timer),
      _buildStatCard('Alcance', '${stats.rangeTiles}', Icons.radar),
      _buildStatCard('Velocidade', '${stats.moveSpeedTilesPerSec}', Icons.directions_run),
      if (stats.splashRadiusTiles > 0) _buildStatCard('Área', '${stats.splashRadiusTiles}', Icons.blur_circular),
    ]);
  }

  Widget _buildSpellGrid(SpellStats stats) {
    return _buildGrid([
      if (stats.damageInstant > 0) _buildStatCard('Dano', '${stats.damageInstant.toInt()}', Icons.flash_on),
      if (stats.damagePerTick > 0) _buildStatCard('Dano/Tick', '${stats.damagePerTick.toInt()}', Icons.water_drop),
      if (stats.durationSec > 0) _buildStatCard('Duração', '${stats.durationSec}s', Icons.timer),
      if (stats.radiusTiles > 0) _buildStatCard('Raio', '${stats.radiusTiles}', Icons.radar),
      if (stats.slowPercent > 0) _buildStatCard('Lentidão', '${stats.slowPercent}%', Icons.snowshoeing),
      if (stats.freezeSec > 0) _buildStatCard('Congelar', '${stats.freezeSec}s', Icons.ac_unit),
    ]);
  }

  Widget _buildBuildingGrid(BuildingStats stats) {
    return _buildGrid([
      _buildStatCard('Vida', '${stats.hitPoints.toInt()}', Icons.favorite),
      _buildStatCard('Tempo Vida', '${stats.lifetimeSec}s', Icons.timer),
      if (stats.canAttack) ...[
        _buildStatCard('Dano', '${stats.damagePerHit.toInt()}', Icons.flash_on),
        _buildStatCard('Vel. Ataque', '${stats.attacksPerSecond}s', Icons.speed),
        _buildStatCard('Alcance', '${stats.rangeTiles}', Icons.radar),
      ],
      if (stats.spawnUnits > 0) _buildStatCard('Gera Unid.', '${stats.spawnIntervalSec}s', Icons.group_add),
    ]);
  }

  Widget _buildGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: children,
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DuelColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: DuelTypography.labelCaps),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DuelColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DuelColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: DuelColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: DuelTypography.labelCaps.copyWith(fontSize: 10)),
              Text(value, style: DuelTypography.hudNumber.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoreTab() {
    final loreData = CardLoreData.loreMap[widget.card.cardId];
    final lore = loreData?.lore ?? 'Uma carta misteriosa de origens desconhecidas.';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lore,
            style: DuelTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DuelColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DuelColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_stories, color: DuelColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FUNÇÃO TÁTICA', style: DuelTypography.labelCaps.copyWith(color: DuelColors.primary)),
                      const SizedBox(height: 4),
                      Text(
                        widget.card.function,
                        style: DuelTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common: return DuelColors.rarityCommon;
      case CardRarity.rare: return DuelColors.rarityRare;
      case CardRarity.epic: return DuelColors.rarityEpic;
      case CardRarity.legendary: return DuelColors.rarityLegendary;
    }
  }
}
