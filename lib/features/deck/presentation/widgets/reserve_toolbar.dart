import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/deck_view_model.dart';
import '../../domain/deck_types.dart';
import '../../../../ui/widgets/df_search_box.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import 'sort_key_toggle_button.dart';
import 'sort_order_toggle_button.dart';

class ReserveToolbar extends StatelessWidget {
  const ReserveToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DeckViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DFSearchBox(
                hintText: 'Buscar carta...',
                onChanged: vm.setSearchQuery,
              ),
            ),
            const SizedBox(width: 8),
            SortKeyToggleButton(
              sortKey: vm.sortKey,
              onTap: vm.toggleSortKey,
            ),
            const SizedBox(width: 8),
            SortOrderToggleButton(
              sortOrder: vm.sortOrder,
              onTap: vm.toggleSortOrder,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFeedbackChip(vm),
      ],
    );
  }

  Widget _buildFeedbackChip(DeckViewModel vm) {
    if (vm.filteredSortedReserveCards.isEmpty && vm.searchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          'Nenhuma carta encontrada',
          style: DuelTypography.bodySmall.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    String sortLabel = '';
    switch (vm.sortKey) {
      case ReserveSortKey.type:
        sortLabel = 'TIPO';
        break;
      case ReserveSortKey.rarity:
        sortLabel = 'RARIDADE';
        break;
      case ReserveSortKey.power:
        sortLabel = 'PODER';
        break;
      case ReserveSortKey.level:
        sortLabel = 'NÍVEL';
        break;
    }

    final orderLabel = vm.sortOrder == SortOrder.asc ? 'Crescente' : 'Decrescente';
    final text = 'Ordenando por: $sortLabel • $orderLabel';

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: DuelTypography.labelCaps.copyWith(
          color: DuelColors.primaryDim,
          fontSize: 10,
        ),
      ),
    );
  }
}
