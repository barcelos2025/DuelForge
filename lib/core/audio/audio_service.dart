import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();

  bool _isMusicPlaying = false;
  bool _isMuted = false;
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;
  
  // Reference to ProfileService for persistence
  dynamic _profileService; // Using dynamic to avoid circular dependency

  bool get isMuted => _isMuted;

  Future<void> init({dynamic profileService}) async {
    _profileService = profileService;
    
    // Load mute status from profile if available
    if (_profileService != null) {
      _isMuted = _profileService.isMuted;
      print('🔊 AudioService: Loaded mute status from profile: $_isMuted');
      
      // Listen to profile changes to sync mute status
      _profileService.addListener(_onProfileChanged);
    }
    
    // Preload music and sfx
    await FlameAudio.audioCache.loadAll([
      'main_menu_theme.mp3',
      'deck_theme.mp3',
      'victory_stinger.mp3',
      'defeat_stinger.mp3',
      // Uncomment when files are added:
      // 'sfx/ui_click.mp3',
      // 'sfx/battle_deploy.mp3',
      // 'sfx/battle_tower_destroy.mp3',
    ]);
  }

  void _onProfileChanged() {
    if (_profileService != null) {
      final newMuteStatus = _profileService.isMuted;
      if (newMuteStatus != _isMuted) {
        _isMuted = newMuteStatus;
        print('🔊 AudioService: Mute status synced from profile: $_isMuted');
        
        if (_isMuted) {
          FlameAudio.bgm.pause();
        } else {
          if (_isMusicPlaying) {
            FlameAudio.bgm.resume();
          }
        }
        notifyListeners();
      }
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    
    // Save to profile
    if (_profileService != null) {
      _profileService.setMuted(_isMuted);
      print('🔊 AudioService: Saved mute status to profile: $_isMuted');
    }
    
    if (_isMuted) {
      FlameAudio.bgm.pause();
    } else {
      if (_isMusicPlaying) {
        FlameAudio.bgm.resume();
      }
    }
    notifyListeners();
  }

  void playMusic(String filename) {
    print('AudioService: Request to play $filename. Muted: $_isMuted, Playing: $_isMusicPlaying');
    if (_isMuted) {
      _isMusicPlaying = true; // Mark as playing even if muted so it resumes correctly
      return; 
    }

    // If already playing, stop first
    if (_isMusicPlaying) {
      FlameAudio.bgm.stop();
    }
    
    try {
      FlameAudio.bgm.play(filename, volume: _musicVolume).catchError((e) {
        print('AudioService: Error playing music (async): $e');
      });
      _isMusicPlaying = true;
      print('AudioService: Playing $filename');
    } catch (e) {
      print('AudioService: Error playing music: $e');
    }
  }

  Future<void> fadeOutMusic({Duration duration = const Duration(milliseconds: 500)}) async {
    if (!_isMusicPlaying) return;
    FlameAudio.bgm.stop();
    _isMusicPlaying = false;
  }

  void playSfx(String filename) {
    if (_isMuted) return;
    FlameAudio.play(filename, volume: _sfxVolume);
  }

  // --- SFX Methods ---

  void playUiClick() {
    // if (_isMuted) return;
    // FlameAudio.play('sfx/ui_click.mp3', volume: _sfxVolume);
  }

  void playDeploySfx() {
    // if (_isMuted) return;
    // FlameAudio.play('sfx/battle_deploy.mp3', volume: _sfxVolume);
  }

  void playTowerDestroyedSfx() {
    // if (_isMuted) return;
    // FlameAudio.play('sfx/battle_tower_destroy.mp3', volume: _sfxVolume);
  }
  
  void playCardSelectSfx() {
    // if (_isMuted) return;
    // FlameAudio.play('sfx/ui_card_select.mp3', volume: _sfxVolume);
  }

  void playErrorSfx() {
    // if (_isMuted) return;
    // FlameAudio.play('sfx/ui_error.mp3', volume: _sfxVolume);
  }


  void stopMusic() {
    FlameAudio.bgm.stop();
    _isMusicPlaying = false;
  }

  void pauseMusic() {
    FlameAudio.bgm.pause();
    _isMusicPlaying = false;
  }

  void resumeMusic() {
    if (_isMuted) return;
    if (_isMusicPlaying) return;
    FlameAudio.bgm.resume();
    _isMusicPlaying = true;
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }
}
