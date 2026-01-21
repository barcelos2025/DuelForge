import 'dart:async';
import 'reward_models.dart';

/// Barramento de eventos simples para desacoplar Serviço <-> UI
class RewardEventBus {
  static final RewardEventBus _instance = RewardEventBus._internal();
  factory RewardEventBus() => _instance;
  RewardEventBus._internal();

  // Stream para notificar a UI de novas recompensas
  final _rewardController = StreamController<RewardBatch>.broadcast();
  Stream<RewardBatch> get onRewardReceived => _rewardController.stream;

  // Stream para notificar o Serviço que a animação acabou (consumir item)
  final _consumedController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get onRewardConsumed => _consumedController.stream;

  void emitReward(RewardBatch batch) {
    _rewardController.add(batch);
  }

  void emitConsumed(List<String> outboxIds) {
    _consumedController.add(outboxIds);
  }

  void dispose() {
    _rewardController.close();
    _consumedController.close();
  }
}
