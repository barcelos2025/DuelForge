# DuelForge UI Assets - Guia de Referência

## 📦 Assets Integrados (21 itens)

### ✅ Moedas e Recursos

| Asset | Arquivo | Uso |
|-------|---------|-----|
| Moeda de Ouro (single) | `df_item_gold_coin_v01.png` | Recompensas, loja, display de moeda |
| Pilha de Moedas | `df_item_gold_stack_v01.png` | Grandes quantidades de ouro |

### ✅ Cristais Rúnicos

| Asset | Arquivo | Uso |
|-------|---------|-----|
| Cristal Pequeno | `df_item_rune_crystal_small_v01.png` | Fragmentos, pequenas recompensas |
| Cristal Médio | `df_item_rune_crystal_medium_v01.png` | Recompensas normais |
| Cristal Grande | `df_item_rune_crystal_large_v01.png` | Grandes recompensas, premium |

### ✅ Gemas Premium

| Asset | Arquivo | Uso |
|-------|---------|-----|
| Gema Single | `df_item_gem_premium_single_v01.png` | Display de moeda premium |
| Saco de Gemas | `df_item_gem_premium_bag_v01.png` | Pacotes de gemas |
| Pilha de Gemas | `df_item_gem_premium_stack_v01.png` | Grandes quantidades |

### ✅ Fragmentos de Carta (5 Raridades)

| Raridade | Arquivo | Cor |
|----------|---------|-----|
| Comum | `df_item_card_shards_common_v01.png` | Verde suave |
| Raro | `df_item_card_shards_rare_v01.png` | Azul |
| Épico | `df_item_card_shards_epic_v01.png` | Roxo |
| Lendário | `df_item_card_shards_legendary_v01.png` | Dourado |
| Mestre | `df_item_card_shards_master_v01.png` | Vermelho rubi |

### ✅ Orbes de Energia

| Estado | Arquivo | Uso |
|--------|---------|-----|
| Vazio | `df_item_rune_orb_empty_v01.png` | Energia 0% |
| Meio | `df_item_rune_orb_half_v01.png` | Energia 1-99% |
| Cheio | `df_item_rune_orb_full_v01.png` | Energia 100% |

### ✅ Itens de Upgrade

| Asset | Arquivo | Uso |
|-------|---------|-----|
| Pergaminho | `df_item_upgrade_scroll_v01.png` | Upgrades, melhorias |
| Martelo de Forja | `df_item_forge_hammer_v01.png` | Forja, crafting |

### ✅ Poções (3/6)

| Tipo | Arquivo | Cor | Status |
|------|---------|-----|--------|
| Cura | `df_potion_heal_v01.png` | Verde | ✅ |
| Fúria | `df_potion_rage_v01.png` | Vermelho | ✅ |
| Gelo | `df_potion_frost_v01.png` | Azul | ✅ |
| Veneno | `df_potion_poison_v01.png` | Esmeralda | ⏳ Pendente |
| Raios | `df_potion_lightning_v01.png` | Ciano | ⏳ Pendente |
| Lendária | `df_potion_legendary_v01.png` | Dourado | ⏳ Pendente |

---

## 🎨 Especificações Visuais

### Estilo
- **Estética**: Fantasia Nórdica + Cartoon Premium 3D
- **Outline**: Contorno fino e sutil
- **Contraste**: Alto contraste para legibilidade

### Iluminação
- **Tipo**: Cinematográfica
- **Rim Light**: Suave em todos os itens
- **Brilho Rúnico**: Ciano como acento mágico

### Materiais
- Metal escovado (moedas, martelo)
- Cristal translúcido (cristais, orbes)
- Vidro (poções)
- Couro (sacos, alças)
- Madeira entalhada (pergaminho)

### Paleta de Cores
- **Ouro**: `#FFC44D` (quente, brilho suave)
- **Ciano Mágico**: `#00FFFF` (runas, energia)
- **Roxo Premium**: `#B35CFF` (gemas, épico)
- **Verde Comum**: Suave, natural
- **Azul Raro**: Vibrante
- **Vermelho Mestre**: Rubi intenso

---

## 💻 Uso no Código

### Importação
```dart
import 'package:duelforge_proto/ui/theme/df_assets.dart';
```

### Exemplos de Uso

#### Asset Direto
```dart
Image.asset(
  DFAssets.goldCoin,
  width: 64,
  height: 64,
)
```

#### Com Helper (Raridade)
```dart
Image.asset(
  DFAssets.getCardShardsByRarity('legendary'),
  width: 48,
  height: 48,
)
```

#### Com Helper (Energia)
```dart
Image.asset(
  DFAssets.getRuneOrbByLevel(0.75), // Retorna runeOrbHalf
  width: 32,
  height: 32,
)
```

#### Com Helper (Tamanho)
```dart
Image.asset(
  DFAssets.getRuneCrystalBySize('large'),
  width: 80,
  height: 80,
)
```

---

## 🧪 Tela de Teste

Para visualizar todos os assets integrados:

```dart
Navigator.pushNamed(context, Rotas.assetsShowcase);
```

---

## 📋 Próximos Assets (Pendentes)

### Poções Restantes (3)
- Poção de Veneno
- Poção de Raios
- Poção Lendária

### Baús (21 itens)
- 7 tipos × 3 estados (fechado, abrindo, pronto)
- Comum, Raro, Épico, Lendário, Mestre, Grátis, Arena

### Ícones de Navegação (6)
- Loja, Deck, Evoluir, Arena, Configurações, Perfil

### Botões e UI Chrome
- Botões (Primary, Secondary, Danger, CTA)
- Pills/Badges
- Tabs/Segmented controls

### Badges e Rank
- Troféus (5 ranks)
- Badges de nível (5 variações)
- Medalhas de conquistas (8 tipos)

### VFX Overlays
- Glow rúnico circular
- Partículas de runas
- Faíscas elétricas
- Estilhaços de gelo
- Fumaça tóxica

**Total Estimado**: ~80 assets adicionais

---

## 📝 Notas Técnicas

- **Formato**: PNG com transparência
- **Resolução**: 1024px+ no maior lado
- **Fundo**: Transparente (alpha channel)
- **Ângulo**: Isométrico 3/4 consistente
- **Sem texto/números**: Assets puros, texto via código
- **Nomeação**: `df_[categoria]_[nome]_v01.png`

---

**Última atualização**: 14/01/2026 00:00  
**Versão**: v0.1  
**Status**: 21/~100 assets integrados (21%)
