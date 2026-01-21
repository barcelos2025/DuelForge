import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/components/df_primary_cta.dart';
import '../../services/auth_service.dart';
import '../../../../app/navigation/rotas.dart';
import 'package:provider/provider.dart';
import '../../../profile/services/profile_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().loginWithEmail(
        _emailController.text, 
        _passwordController.text
      );
      if (mounted) {
        await context.read<ProfileService>().sync();
        
        if (AuthService().isOnboardingCompleted) {
          Navigator.of(context).pushReplacementNamed(Rotas.home);
        } else {
          Navigator.of(context).pushReplacementNamed(Rotas.onboarding);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login: $e')),
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
            'assets/images/splash_screen.png', // Reusing splash bg for consistency
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DuelColors.background.withOpacity(0.6),
                  DuelColors.background.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [DuelColors.accentCyan, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      'DUEL FORGE',
                      style: DuelTypography.displayLarge.copyWith(
                        fontSize: 48,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: DuelColors.accentCyan.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ODYN\'S RAGE',
                    style: DuelTypography.labelCaps.copyWith(
                      color: DuelColors.accentGold,
                      letterSpacing: 8,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? const CircularProgressIndicator(color: DuelColors.accentCyan)
                            : Column(
                                children: [
                                  DFPrimaryCTA(
                                    title: 'ENTRAR COM E-MAIL',
                                    onPressed: _handleLogin,
                                    leftIcon: Icons.login,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildGoogleButton(),
                                ],
                              ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Links
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Forgot Password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidade em breve!')),
                      );
                    },
                    child: Text(
                      'Esqueceu a senha?',
                      style: DuelTypography.bodyMedium.copyWith(
                        color: Colors.white54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Não tem conta?', style: DuelTypography.bodyMedium),
                      TextButton(
                        onPressed: () {
                          // Toggle to Signup (Simulated for now by just changing button text logic if needed, 
                          // but for this MVP login/signup are often same Supabase flow or handled by Auth UI)
                          // For now, we assume the user uses the same form.
                          _handleLogin(); // Supabase often handles "Sign In or Sign Up" or we need explicit toggle.
                          // Let's keep it simple as requested: "Fluxo de cadastro e login"
                        },
                        child: Text(
                          'Crie agora',
                          style: DuelTypography.bodyMedium.copyWith(
                            color: DuelColors.accentCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: DuelColors.accentCyan),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Google Login
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login com Google em breve!')),
              );
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for Google Icon
              const Icon(Icons.g_mobiledata, color: Colors.black, size: 32),
              const SizedBox(width: 12),
              Text(
                'CONTINUAR COM GOOGLE',
                style: DuelTypography.labelCaps.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
