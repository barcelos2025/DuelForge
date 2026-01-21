import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/components/df_primary_cta.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../app/navigation/rotas.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';

import '../../../../ui/avatar/avatar_selection_screen.dart';
import '../../../../features/avatars/registry/avatar_registry.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _nicknameController = TextEditingController();
  String _selectedCountry = 'Brasil'; // Default
  String _selectedAvatarId = 'warrior_m';
  bool _isLoading = false;

  final List<String> _countries = ['Brasil', 'USA', 'Japan', 'Germany', 'France'];

  Future<void> _handleComplete() async {
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escolha um nome de guerreiro!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final countryMap = {
        'Brasil': 'BR',
        'USA': 'US',
        'Japan': 'JP',
        'Germany': 'DE',
        'France': 'FR',
      };

      // Save profile to Supabase
      await AuthService().completeOnboarding(
        _nicknameController.text,
        countryMap[_selectedCountry] ?? 'BR',
        _selectedAvatarId,
      );
      
      
      if (mounted) {
        await context.read<ProfileService>().sync();
        Navigator.of(context).pushReplacementNamed(Rotas.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
           // Background Image with Overlay
          Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DuelColors.background.withOpacity(0.8),
                  DuelColors.background.withOpacity(0.95),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon / Header
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DuelColors.accentCyan.withOpacity(0.1),
                      border: Border.all(color: DuelColors.accentCyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: DuelColors.accentCyan.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add, color: DuelColors.accentCyan, size: 40),
                  ),
                  const SizedBox(height: 24),

                  Text('QUEM É VOCÊ?', style: DuelTypography.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Sua lenda começa agora.',
                    style: DuelTypography.bodyMedium.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 48),
                  
                  // Form Container
                   Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        // Avatar Selection
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AvatarSelectionScreen(
                                  initialAvatarId: _selectedAvatarId,
                                  onAvatarSelected: (id) {
                                    setState(() => _selectedAvatarId = id);
                                  },
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() => _selectedAvatarId = result);
                            }
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: DuelColors.accentGold, width: 2),
                                  image: DecorationImage(
                                    image: AssetImage(AvatarRegistry.instance.get(_selectedAvatarId).assetPath),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DuelColors.accentGold.withOpacity(0.3),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: DuelColors.accentGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Alterar Avatar',
                                style: DuelTypography.labelCaps.copyWith(color: DuelColors.accentGold),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Nickname Field
                        TextField(
                          controller: _nicknameController,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (val) => setState(() {}), // Trigger validation rebuild
                          decoration: InputDecoration(
                            labelText: 'Nome de Guerreiro',
                            labelStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.person, color: DuelColors.accentCyan),
                            suffixIcon: _nicknameController.text.length >= 3 
                                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                                : null,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: DuelColors.accentCyan, width: 1.5),
                            ),
                          ),
                        ),
                        if (_nicknameController.text.isNotEmpty && _nicknameController.text.length < 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Mínimo de 3 caracteres',
                                  style: DuelTypography.labelCaps.copyWith(color: Colors.redAccent, fontSize: 10),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),
                        
                        // Country Selector
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          dropdownColor: const Color(0xFF1E1E2C),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Reino de Origem',
                            labelStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.flag, color: DuelColors.accentGold),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: DuelColors.accentGold, width: 1.5),
                            ),
                          ),
                          items: _countries.map((c) => DropdownMenuItem(
                            value: c, 
                            child: Row(
                              children: [
                                Text(c), // Could add flag emoji here if available
                              ],
                            ),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedCountry = val!),
                        ),

                        const SizedBox(height: 32),
                        
                        _isLoading 
                          ? const CircularProgressIndicator(color: DuelColors.accentGold)
                          : DFPrimaryCTA(
                              title: 'FORJAR IDENTIDADE',
                              subtitle: 'Entrar na Arena',
                              onPressed: _handleComplete,
                              leftIcon: Icons.build_outlined, // Hammer icon for "Forge"
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
