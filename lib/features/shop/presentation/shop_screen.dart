import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economy_service.dart';
import '../domain/shop_models.dart';
import '../data/shop_catalog.dart';
import '../../profile/services/profile_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeta EconomyService se não estiver no topo
    return ChangeNotifierProvider(
      create: (_) => EconomyService(context.read<ProfileService>()),
      child: const _ShopContent(),
    );
  }
}

class _ShopContent extends StatelessWidget {
  const _ShopContent();

  @override
  Widget build(BuildContext context) {
    final economy = context.watch<EconomyService>();
    final profile = context.watch<ProfileService>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark Theme
      appBar: AppBar(
        title: const Text('Loja Real'),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          _CurrencyDisplay(
            icon: Icons.monetization_on,
            amount: profile.profile.coins,
            color: Colors.amber,
          ),
          const SizedBox(width: 10),
          _CurrencyDisplay(
            icon: Icons.diamond,
            amount: profile.profile.rubies,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // 1. Ofertas Diárias (Daily Deals)
          _SectionHeader(title: 'Ofertas Diárias', icon: Icons.calendar_today),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: economy.dailyDeals.length,
              itemBuilder: (ctx, i) => _ShopItemCard(item: economy.dailyDeals[i]),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Pacotes de Rubis (IAP)
          _SectionHeader(title: 'Tesouro (Rubis)', icon: Icons.diamond_outlined),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ShopCatalog.gemPacks.length,
              itemBuilder: (ctx, i) => _ShopItemCard(item: ShopCatalog.gemPacks[i], isPremium: true),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Pacotes de Ouro (Soft Currency)
          _SectionHeader(title: 'Banco (Ouro)', icon: Icons.savings),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ShopCatalog.goldPacks.length,
              itemBuilder: (ctx, i) => _ShopItemCard(item: ShopCatalog.goldPacks[i]),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 4. Cosméticos (Skins)
          _SectionHeader(title: 'Estilo (Skins)', icon: Icons.palette),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('Em breve...', style: TextStyle(color: Colors.white54))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyDisplay extends StatelessWidget {
  final IconData icon;
  final int amount;
  final Color color;

  const _CurrencyDisplay({required this.icon, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isPremium;

  const _ShopItemCard({required this.item, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    final economy = context.read<EconomyService>();

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252A40),
        borderRadius: BorderRadius.circular(12),
        border: isPremium ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header / Quantity
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              item.quantity != null ? 'x${item.quantity}' : '',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Icon / Image
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                item.type == ItemType.card ? Icons.style : 
                item.type == ItemType.currency ? (item.id.contains('rubies') ? Icons.diamond : Icons.monetization_on) :
                Icons.card_giftcard,
                size: 48,
                color: item.id.contains('rubies') ? Colors.redAccent : Colors.amber,
              ),
            ),
          ),
          
          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),

          // Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.cost == 0 ? Colors.green : (isPremium ? Colors.amber[800] : Colors.blueGrey),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final success = await economy.purchaseItem(item);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comprado: ${item.name}!'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saldo insuficiente!'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: item.cost == 0 
                  ? const Text('GRÁTIS', style: TextStyle(fontWeight: FontWeight.bold))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.costType == CurrencyType.realMoney)
                          const Text('R\$ ', style: TextStyle(fontSize: 12)),
                        if (item.costType == CurrencyType.rubies)
                          const Icon(Icons.diamond, size: 14, color: Colors.white),
                        if (item.costType == CurrencyType.gold)
                          const Icon(Icons.monetization_on, size: 14, color: Colors.amberAccent),
                        const SizedBox(width: 4),
                        Text(item.cost.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
