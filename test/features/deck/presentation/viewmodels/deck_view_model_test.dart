import 'package:flutter_test/flutter_test.dart';
import 'package:duelforge_proto/features/deck/presentation/viewmodels/deck_view_model.dart';
import 'package:duelforge_proto/features/deck/domain/deck_types.dart';
import 'package:duelforge_proto/features/profile/services/profile_service.dart';
import 'package:duelforge_proto/features/profile/models/player_profile.dart';

// Fake ProfileService to avoid Hive dependency
class FakeProfileService extends ProfileService {
  final PlayerProfile _fakeProfile;

  FakeProfileService(this._fakeProfile);

  @override
  PlayerProfile get profile => _fakeProfile;

  @override
  Future<void> saveDeck(List<String> deck) async {
    _fakeProfile.currentDeck = List.from(deck);
    notifyListeners();
  }
}

void main() {
  group('DeckViewModel Tests', () {
    late DeckViewModel viewModel;
    late FakeProfileService fakeProfileService;
    late PlayerProfile fakeProfile;

    setUp(() {
      // Setup initial deck with 8 unique cards
      final initialDeck = List.generate(8, (i) => 'card_$i');
      fakeProfile = PlayerProfile(currentDeck: initialDeck);
      fakeProfileService = FakeProfileService(fakeProfile);
      viewModel = DeckViewModel(fakeProfileService);
    });

    test('Initial state should load deck from profile', () {
      expect(viewModel.currentDeck.length, 8);
      expect(viewModel.currentDeck, fakeProfile.currentDeck);
      expect(viewModel.selected, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    test('selectCard should update selected state', () {
      viewModel.selectCard('card_0', DeckSide.game, 0);
      
      expect(viewModel.selected, isNotNull);
      expect(viewModel.selected!.cardId, 'card_0');
      expect(viewModel.selected!.side, DeckSide.game);
      expect(viewModel.selected!.index, 0);
    });

    test('selectCard should toggle selection off if same card tapped', () {
      // Select first
      viewModel.selectCard('card_0', DeckSide.game, 0);
      expect(viewModel.selected, isNotNull);

      // Tap again
      viewModel.selectCard('card_0', DeckSide.game, 0);
      expect(viewModel.selected, isNull);
    });

    test('canSwap should return true for valid swap', () {
      viewModel.selectCard('card_0', DeckSide.game, 0);
      
      // Swap with a card NOT in the deck
      final canSwap = viewModel.canSwap('new_card', DeckSide.reserve, 0);
      
      expect(canSwap, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('canSwap should return false for duplicate card', () {
      viewModel.selectCard('card_0', DeckSide.game, 0);
      
      // Try to swap with 'card_1' which IS in the deck
      final canSwap = viewModel.canSwap('card_1', DeckSide.reserve, 0);
      
      expect(canSwap, false);
      expect(viewModel.errorMessage, 'Carta já está no deck!');
    });

    test('swapCards should update deck and save', () async {
      viewModel.selectCard('card_0', DeckSide.game, 0);
      
      final success = await viewModel.swapCards('new_card', DeckSide.reserve, 0);
      
      expect(success, true);
      expect(viewModel.currentDeck[0], 'new_card');
      expect(fakeProfile.currentDeck[0], 'new_card'); // Verify save was called
      expect(viewModel.selected!.cardId, 'new_card'); // Selection should follow swap
    });

    test('swapCards should fail if duplicate', () async {
      viewModel.selectCard('card_0', DeckSide.game, 0);
      
      final success = await viewModel.swapCards('card_1', DeckSide.reserve, 0);
      
      expect(success, false);
      expect(viewModel.currentDeck[0], 'card_0'); // Should not change
      expect(viewModel.errorMessage, 'Carta já está no deck!');
    });
  });
}
