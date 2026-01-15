/// DuelForge UI Assets - Technical Specification
/// 
/// Sistema completo de assets otimizados para mobile com 9-slice, sprite sheets e atlas.
class DFAssetsTechnical {
  // ==================== 9-SLICE PANELS ====================
  
  /// Painel Base (vidro fosco + borda metálica)
  static const String panelBaseCorner = 'assets/ui/9slice/df_panel_base_corner_v01.png';
  static const String panelBaseEdge = 'assets/ui/9slice/df_panel_base_edge_v01.png';
  static const String panelBaseCenter = 'assets/ui/9slice/df_panel_base_center_v01.png';
  
  /// Painel Card (para cartas e slots)
  static const String panelCardCorner = 'assets/ui/9slice/df_panel_card_corner_v01.png';
  static const String panelCardEdge = 'assets/ui/9slice/df_panel_card_edge_v01.png';
  static const String panelCardCenter = 'assets/ui/9slice/df_panel_card_center_v01.png';
  
  /// Tooltip (balão com cauda)
  static const String tooltipCorner = 'assets/ui/9slice/df_tooltip_corner_v01.png';
  static const String tooltipEdge = 'assets/ui/9slice/df_tooltip_edge_v01.png';
  static const String tooltipCenter = 'assets/ui/9slice/df_tooltip_center_v01.png';
  
  // ==================== PROGRESS BARS ====================
  
  /// Barra de Progresso
  static const String progressBase9Slice = 'assets/ui/bars/df_progress_base_9slice_v01.png';
  static const String progressFill9Slice = 'assets/ui/bars/df_progress_fill_9slice_v01.png';
  
  /// Barra de Runa (energia)
  static const String runeBarBase9Slice = 'assets/ui/bars/df_rune_bar_base_9slice_v01.png';
  static const String runeBarFill9Slice = 'assets/ui/bars/df_rune_bar_fill_9slice_v01.png';
  
  // ==================== BUTTONS (S/M/L + STATES) ====================
  
  /// Botão Primário (Ciano Rúnico)
  static const String btnPrimarySNormal = 'assets/ui/buttons/df_btn_primary_s_normal_v01.png';
  static const String btnPrimarySPressed = 'assets/ui/buttons/df_btn_primary_s_pressed_v01.png';
  static const String btnPrimarySDisabled = 'assets/ui/buttons/df_btn_primary_s_disabled_v01.png';
  static const String btnPrimaryMNormal = 'assets/ui/buttons/df_btn_primary_m_normal_v01.png';
  static const String btnPrimaryLNormal = 'assets/ui/buttons/df_btn_primary_l_normal_v01.png';
  
  /// Botão CTA Batalhar (Gigante com profundidade)
  static const String btnCtaBattleNormal = 'assets/ui/buttons/df_btn_cta_battle_normal_v01.png';
  static const String btnCtaBattlePressed = 'assets/ui/buttons/df_btn_cta_battle_pressed_v01.png';
  
  /// Botão Ícone Circular
  static const String btnIconCircleNormal = 'assets/ui/buttons/df_btn_icon_circle_normal_v01.png';
  
  // ==================== CHESTS (STATIC + ANIMATIONS) ====================
  
  /// Baús Estáticos
  static const String chestCommonClosed = 'assets/ui/chests/df_chest_common_closed_v01.png';
  static const String chestCommonReady = 'assets/ui/chests/df_chest_common_ready_v01.png';
  static const String chestCommonOpening = 'assets/ui/chests/df_chest_common_opening_v01.png';
  static const String chestLegendaryClosed = 'assets/ui/chests/df_chest_legendary_closed_v01.png';
  static const String chestMasterClosed = 'assets/ui/chests/df_chest_master_closed_v01.png';
  static const String chestArenaClosed = 'assets/ui/chests/df_chest_arena_closed_v01.png';
  
  /// Animações de Baú (Sprite Sheets)
  static const String chestOpeningLoopSheet = 'assets/ui/chests/anim/df_chest_opening_loop_sheet_v01.png';
  static const String chestBurstRewardSheet = 'assets/ui/chests/anim/df_chest_burst_reward_sheet_v01.png';
  
  // ==================== VFX UI (SPRITE SHEETS) ====================
  
  /// Seleção de Item (glow circular - 12 frames loop)
  static const String vfxSelectGlowLoopSheet = 'assets/ui/vfx/df_vfx_select_glow_loop_sheet_v01.png';
  
  /// Press Feedback (8 frames)
  static const String vfxPressFeedbackSheet = 'assets/ui/vfx/df_vfx_press_feedback_sheet_v01.png';
  
  /// CTA Rune Pulse (16 frames)
  static const String vfxCtaRunePulseSheet = 'assets/ui/vfx/df_vfx_cta_rune_pulse_sheet_v01.png';
  
  /// Lightning Sparks (12 frames)
  static const String vfxLightningSparksSheet = 'assets/ui/vfx/df_vfx_lightning_sparks_sheet_v01.png';
  
  /// Frost Shards (12 frames)
  static const String vfxFrostShardsSheet = 'assets/ui/vfx/df_vfx_frost_shards_sheet_v01.png';
  
  /// Poison Smoke Loop (16 frames)
  static const String vfxPoisonSmokeLoopSheet = 'assets/ui/vfx/df_vfx_poison_smoke_loop_sheet_v01.png';
  
  /// Level Up Burst (16 frames)
  static const String vfxLevelupBurstSheet = 'assets/ui/vfx/df_vfx_levelup_burst_sheet_v01.png';
  
  // ==================== ATLAS REFERENCES ====================
  
  static const String atlasUI = 'assets/ui/atlas/atlas_ui_v01.png';
  static const String atlasUIJson = 'assets/ui/atlas/atlas_ui_v01.json';
  
  static const String atlasItems = 'assets/ui/atlas/atlas_items_v01.png';
  static const String atlasItemsJson = 'assets/ui/atlas/atlas_items_v01.json';
  
  static const String atlasVFX = 'assets/ui/atlas/atlas_vfx_v01.png';
  static const String atlasVFXJson = 'assets/ui/atlas/atlas_vfx_v01.json';
  
  // ==================== SPRITE SHEET METADATA ====================
  
  /// Metadata para animações de sprite sheet
  static const Map<String, SpriteSheetInfo> spriteSheetInfo = {
    'chest_opening_loop': SpriteSheetInfo(frames: 12, frameSize: 256, fps: 12),
    'chest_burst_reward': SpriteSheetInfo(frames: 16, frameSize: 512, fps: 24),
    'select_glow_loop': SpriteSheetInfo(frames: 12, frameSize: 128, fps: 12),
    'press_feedback': SpriteSheetInfo(frames: 8, frameSize: 128, fps: 24),
    'cta_rune_pulse': SpriteSheetInfo(frames: 16, frameSize: 256, fps: 12),
    'lightning_sparks': SpriteSheetInfo(frames: 12, frameSize: 256, fps: 24),
    'frost_shards': SpriteSheetInfo(frames: 12, frameSize: 256, fps: 24),
    'poison_smoke_loop': SpriteSheetInfo(frames: 16, frameSize: 256, fps: 12),
    'levelup_burst': SpriteSheetInfo(frames: 16, frameSize: 512, fps: 24),
  };
}

/// Informações de Sprite Sheet
class SpriteSheetInfo {
  final int frames;
  final int frameSize;
  final int fps;
  
  const SpriteSheetInfo({
    required this.frames,
    required this.frameSize,
    required this.fps,
  });
  
  Duration get frameDuration => Duration(milliseconds: (1000 / fps).round());
  Duration get totalDuration => Duration(milliseconds: (1000 * frames / fps).round());
}
