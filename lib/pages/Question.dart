import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/models/quiz_entity.dart';
import 'package:flashgamer/services/user_service.dart';
import 'package:flashgamer/services/quiz_service.dart';
import 'package:flashgamer/services/mission_service.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  int _currentXp = 0;
  int _streak = 0;
  int _userLevel = 1;
  int _coins = 0;
  bool _isLoading = true;

  int _timeLeft = 18;
  Timer? _timer;
  int? _selectedAnswerIdx;
  bool _hasAnswered = false;

  int? _missionId;
  int? _quizId;
  bool _initialized = false;
  QuizQuestionEntity? _loadedQuiz;
  String _questionText = 'Carregando pergunta...';
  List<Map<String, dynamic>> _alternatives = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _quizId = args['quizId'] as int?;
        _missionId = args['missionId'] as int?;
      } else if (args is int) {
        _missionId = args;
      }
      _loadQuizData();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final UserEntity profile = await UserService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _userName = profile.nome;
        _userLevel = profile.lv;
        _coins = profile.saldo.toInt();
        _currentXp = profile.xp;
        _streak = profile.diasSeguidos;
      });
    } catch (_) {}
  }

  Future<void> _loadQuizData() async {
    try {
      final quizzes = await QuizService.list();
      if (quizzes.isEmpty) {
        _useFallbackQuiz();
        return;
      }
      QuizQuestionEntity? targetQuiz;
      if (_quizId != null) {
        for (final q in quizzes) {
          if (q.id == _quizId) {
            targetQuiz = q;
            break;
          }
        }
      } else if (_missionId != null) {
        for (final q in quizzes) {
          if (q.id == _missionId) {
            targetQuiz = q;
            break;
          }
        }
      }
      targetQuiz ??= quizzes.first;

      if (!mounted) return;
      setState(() {
        _loadedQuiz = targetQuiz;
        _questionText = targetQuiz!.nome;
        final List<Color> bgColors = [const Color(0xFFF3E8FF), const Color(0xFFE0F2FE), const Color(0xFFFEF3C7), const Color(0xFFF3F4F6)];
        final List<Color> borderColors = [const Color(0xFFC084FC), const Color(0xFF38BDF8), const Color(0xFFFBBF24), const Color(0xFF9CA3AF)];

        _alternatives = [];
        for (int i = 0; i < targetQuiz.respostas.length; i++) {
          final resp = targetQuiz.respostas[i];
          _alternatives.add({
            'id': resp.id,
            'texto': resp.nome,
            'correta': resp.certa,
            'cor': bgColors[i % bgColors.length],
            'borda': borderColors[i % borderColors.length],
          });
        }
        _timeLeft = targetQuiz.tempoParaResposta;
        _isLoading = false;
      });
      _startTimer();
    } catch (_) {
      _useFallbackQuiz();
    }
  }

  void _useFallbackQuiz() {
    if (!mounted) return;
    setState(() {
      _questionText = 'Quem descobriu o caminho marítimo para as Índias?';
      _alternatives = [
        {'id': 1, 'texto': 'Vasco da Gama', 'correta': true, 'cor': const Color(0xFFF3E8FF), 'borda': const Color(0xFFC084FC)},
        {'id': 2, 'texto': 'Pedro Álvares Cabral', 'correta': false, 'cor': const Color(0xFFE0F2FE), 'borda': const Color(0xFF38BDF8)},
        {'id': 3, 'texto': 'Cristóvão Colombo', 'correta': false, 'cor': const Color(0xFFFEF3C7), 'borda': const Color(0xFFFBBF24)},
        {'id': 4, 'texto': 'Fernão de Magalhães', 'correta': false, 'cor': const Color(0xFFF3F4F6), 'borda': const Color(0xFF9CA3AF)},
      ];
      _timeLeft = 20;
      _isLoading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !_hasAnswered) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        if (!_hasAnswered) _onAnswerSelected(-1); // Tempo esgotado
      }
    });
  }

  void _onAnswerSelected(int idx) async {
    if (_hasAnswered) return;
    _timer?.cancel();
    setState(() {
      _selectedAnswerIdx = idx;
      _hasAnswered = true;
    });

    bool isCorrect = false;
    int xpGanhado = 0;
    int saldoGanhado = 0;

    if (idx >= 0) {
      final alt = _alternatives[idx];
      final respId = alt['id'];
      if (_loadedQuiz != null) {
        try {
          final result = await QuizService.submit(
            questionId: _loadedQuiz!.id,
            respostaId: respId,
          );
          isCorrect = result['correto'] == true;
          if (isCorrect) {
            xpGanhado = (result['xpGanhado'] as num?)?.toInt() ?? 50;
            saldoGanhado = (result['saldoGanhado'] as num?)?.toInt() ?? 20;

            if (_missionId != null) {
              try {
                final missionResult = await MissionService.complete(_missionId!);
                final int missionXp = (missionResult['xpGanhado'] as num?)?.toInt() ?? 150;
                xpGanhado += missionXp;
              } catch (_) {}
            }
          }
        } catch (_) {
          isCorrect = alt['correta'] == true;
          if (isCorrect) {
            xpGanhado = 150;
            saldoGanhado = 50;
          }
        }
      } else {
        isCorrect = alt['correta'] == true;
        if (isCorrect) {
          xpGanhado = 150;
          saldoGanhado = 50;
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      if (isCorrect) {
        _showResultDialog(
          title: 'Parabéns, Herói! 🎉',
          msg: 'Você acertou e ganhou +$xpGanhado XP e +$saldoGanhado Moedas!',
          buttonLabel: 'CONCLUIR MISSÃO',
          isSuccess: true,
        );
      } else {
        _showResultDialog(
          title: 'Não foi dessa vez! 😢',
          msg: idx == -1 ? 'O tempo acabou! Tente novamente.' : 'Essa resposta está incorreta. Revise o conteúdo!',
          buttonLabel: 'TENTAR NOVAMENTE',
          isSuccess: false,
        );
      }
    });
  }

  void _showResultDialog({
    required String title,
    required String msg,
    required String buttonLabel,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: isSuccess ? const Color(0xFF6B21A8) : Colors.red.shade700), textAlign: TextAlign.center),
        content: Text(msg, style: const TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: AppGradientButton(
              label: buttonLabel,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/home');
              },
              borderRadius: 12,
              gradientColors: isSuccess ? const [Color(0xFF7C3AED), Color(0xFFDB2777)] : const [Colors.grey, Colors.black87],
            ),
          ),
        ],
      ),
    );
  }

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Aprender', icon: Icons.school_rounded),
    _NavItem(label: 'Missões', icon: Icons.flag_rounded),
    _NavItem(label: 'Ranking', icon: Icons.emoji_events_rounded),
    _NavItem(label: 'Loja', icon: Icons.store_rounded),
  ];

  void _onNavTap(int index) {
    if (index == 0 || index == 1) Navigator.pushReplacementNamed(context, '/home');
    if (index == 2) Navigator.pushReplacementNamed(context, '/ranking');
    if (index == 3) Navigator.pushReplacementNamed(context, '/shop');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Column(
          children: [
            isMobile ? _buildMobileTopBar() : _buildDesktopTopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildMissionBadge(),
                          const SizedBox(height: 24),
                          _buildTimerSection(),
                          const SizedBox(height: 36),
                          _buildQuestionText(),
                          const SizedBox(height: 48),
                          _buildAlternativesGrid(),
                          const SizedBox(height: 60),
                          _buildFooter(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, -2)) ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) => _onNavTap(i + 1),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        elevation: 0,
        items: _navItems.sublist(1).map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            )).toList(),
      ),
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 2)) ],
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
            ).createShader(bounds),
            child: const Text(
              'FLASHGAMER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 14),
                const SizedBox(width: 3),
                Text(
                  _coins.toString(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF7C3AED), size: 14),
                const SizedBox(width: 3),
                Text(
                  'Nvl $_userLevel',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B21A8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showProfilePopup(
              context: context,
              nome: _userName,
              lv: _userLevel,
              xp: _currentXp,
              saldo: _coins,
              diasSeguidos: _streak,
            ),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                boxShadow: [ BoxShadow(color: const Color(0xFF7C3AED).withAlpha(40), blurRadius: 6) ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF3B1564),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 2)) ],
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
            ).createShader(bounds),
            child: const Text(
              'FLASHGAMER',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isActive = i == 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _onNavTap(i),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? const Color(0xFF6B21A8) : Colors.grey.shade500,
                      decoration: isActive ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: const Color(0xFF6B21A8),
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 4),
                Text(
                  _coins.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Nvl $_userLevel',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B21A8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => showProfilePopup(
              context: context,
              nome: _userName,
              lv: _userLevel,
              xp: _currentXp,
              saldo: _coins,
              diasSeguidos: _streak,
            ),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                boxShadow: [ BoxShadow(color: const Color(0xFF7C3AED).withAlpha(40), blurRadius: 8) ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF3B1564),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.menu_book_rounded, color: Color(0xFFB45309), size: 14),
          SizedBox(width: 6),
          Text(
            'MISSÃO DE HISTÓRIA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    final double progress = (_timeLeft / 18).clamp(0.0, 1.0);
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tempo Restante',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
              ),
              Text(
                '${_timeLeft}s',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Text(
        _questionText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1E1B4B),
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildAlternativesGrid() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.2,
        ),
        itemCount: _alternatives.length,
        itemBuilder: (context, idx) {
          final alt = _alternatives[idx];
          final bool isSelected = _selectedAnswerIdx == idx;
          final bool isCorrect = alt['correta'] == true;

          Color bgColor = alt['cor'];
          Color borderColor = alt['borda'];
          Color textColor = const Color(0xFF1E1B4B);

          if (_hasAnswered) {
            if (isCorrect) {
              bgColor = Colors.green.shade100;
              borderColor = Colors.green.shade500;
              textColor = Colors.green.shade800;
            } else if (isSelected) {
              bgColor = Colors.red.shade100;
              borderColor = Colors.red.shade500;
              textColor = Colors.red.shade800;
            } else {
              bgColor = alt['cor'].withAlpha(100);
              borderColor = alt['borda'].withAlpha(100);
            }
          } else if (isSelected) {
            borderColor = const Color(0xFF7C3AED);
            bgColor = const Color(0xFFF5F0FF);
          }

          return InkWell(
            onTap: _hasAnswered ? null : () => _onAnswerSelected(idx),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: isSelected
                    ? [ BoxShadow(color: borderColor.withAlpha(60), blurRadius: 10) ]
                    : [ BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 6, offset: const Offset(0, 2)) ],
              ),
              child: Center(
                child: Text(
                  alt['texto'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ).createShader(bounds),
                child: const Text(
                  'LearnHero',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '© 2024 LearnHero. Transformando o aprendizado em uma jornada épica.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Privacidade'),
              _buildFooterSeparator(),
              _buildFooterLink('Termos de Uso'),
              _buildFooterSeparator(),
              _buildFooterLink('Suporte'),
              _buildFooterSeparator(),
              _buildFooterLink('Trabalhe Conosco'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ),
    );
  }

  Widget _buildFooterSeparator() => Text('|', style: TextStyle(fontSize: 10, color: Colors.grey.shade300));
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}
