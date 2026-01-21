import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // --- Configuration ---
  static const bool _enableDevBypass = true; 

  bool get isBypassEnabled => kDebugMode && _enableDevBypass;

  // --- State ---
  bool _isAuthenticated = false;
  String? _userId;
  String? _email;
  bool _isOnboardingCompleted = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get email => _email;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  // --- Initialization ---
  Future<void> init() async {
    // 1. Check Supabase Session
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      _isAuthenticated = true;
      _userId = session.user.id;
      _email = session.user.email;
      await _checkOnboardingStatus();
    } else if (isBypassEnabled) {
      await _performBypassLogin();
    } else {
      _isAuthenticated = false;
    }
    
    // DEV: Ensure specific test user exists
    if (kDebugMode) {
      await _ensureDevUserExists();
    }

    notifyListeners();
  }

  Future<void> _ensureDevUserExists() async {
    const email = 'barcelos32@gmail.com';
    const password = 'teste'; // User requested 'teste'. Supabase might require 6 chars.
    const nickname = 'barcelos32';

    try {
      // 1. Try Login
      try {
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        print('DEV User ($email) already exists and logged in.');
        return;
      } catch (_) {
        // Login failed, proceed to signup
      }

      // 2. Sign Up
      print('Creating DEV User ($email)...');
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 3. Create Profile
        await Supabase.instance.client.from('players').upsert({
          'user_id': res.user!.id,
          'game_name': nickname,
          'country_code': 'BR',
          'trophies': 2450, // Default for this user to match previous mock
          'avatar_id': 'warrior_m',
        });
        print('DEV User created successfully with profile.');
      }
    } catch (e) {
      print('Error creating DEV user: $e');
      if (e.toString().contains('password')) {
        print('Password might be too short. Trying "teste123"...');
        try {
           final res = await Supabase.instance.client.auth.signUp(
            email: email,
            password: 'teste123',
          );
          if (res.user != null) {
             await Supabase.instance.client.from('players').upsert({
              'user_id': res.user!.id,
              'game_name': nickname,
              'country_code': 'BR',
              'trophies': 2450,
              'avatar_id': 'warrior_m',
            });
          }
        } catch (e2) {
          print('Retry failed: $e2');
        }
      }
    }
  }

  // --- Bypass Logic ---
  Future<void> _performBypassLogin() async {
    print('AuthService: Performing DEV_AUTH_BYPASS login...');
    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = true;
    _userId = 'dev_user_001';
    _email = 'dev@duelforge.local';
    _isOnboardingCompleted = true; // Bypass assumes onboarding done

    print('AuthService: Bypass login successful. User: $_email');
  }

  // --- Public Methods ---
  
  Future<void> loginWithEmail(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _isAuthenticated = true;
        _userId = response.user!.id;
        _email = response.user!.email;
        await _checkOnboardingStatus();
        notifyListeners();
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }
  
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Auto login usually happens, but let's ensure state
        _isAuthenticated = true;
        _userId = response.user!.id;
        _email = response.user!.email;
        _isOnboardingCompleted = false; // New user
        notifyListeners();
      }
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    if (!isBypassEnabled) {
      await Supabase.instance.client.auth.signOut();
    }
    
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _isOnboardingCompleted = false;
    
    notifyListeners();
  }

  Future<void> completeOnboarding(String nickname, String country, String avatarId) async {
    if (isBypassEnabled && _userId == 'dev_user_001') {
      _isOnboardingCompleted = true;
      notifyListeners();
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await Supabase.instance.client.from('players').upsert({
        'user_id': user.id,
        'game_name': nickname,
        'country_code': country, // Ensure this is 2 chars
        'avatar_id': avatarId,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _isOnboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      print('Onboarding Error: $e');
      rethrow;
    }
  }

  // --- Helpers ---
  Future<void> _checkOnboardingStatus() async {
    if (isBypassEnabled && _userId == 'dev_user_001') {
      _isOnboardingCompleted = true;
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('players')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();
          
      _isOnboardingCompleted = data != null;
    } catch (e) {
      print('Check Onboarding Error: $e');
      _isOnboardingCompleted = false;
    }
  }
}
