import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/services/auth_service.dart';
class NewPage extends StatefulWidget {
  const NewPage({super.key});
  @override
  State<NewPage> createState() => _NewPageState();
}
class _NewPageState extends State<NewPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ));
    _animCtrl.forward();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        nome: _nameController.text.trim(),
        email: _emailController.text.trim(),
        senha: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Conta criada com sucesso! Faça login.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground.darkPurple(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withAlpha(100),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 24),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE9D5FF), Color(0xFFF9A8D4)],
                        ).createShader(bounds),
                        child: const Text(
                          'Criar Conta',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha os dados para se cadastrar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(150),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),
                              AppTextField(
                                label: 'Nome',
                                hint: 'Seu nome completo',
                                icon: Icons.person_outline_rounded,
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor, insira seu nome';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'O nome deve ter pelo menos 2 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Email',
                                hint: 'seu@email.com',
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Senha',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.white.withAlpha(120),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira uma senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Confirmar Senha',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.white.withAlpha(120),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, confirme sua senha';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              AppGradientButton(
                                label: 'CADASTRAR',
                                icon: Icons.how_to_reg_rounded,
                                isLoading: _isLoading,
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 16),
                              AppOutlinedButton(
                                label: 'JÁ TENHO CONTA',
                                icon: Icons.login_rounded,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}