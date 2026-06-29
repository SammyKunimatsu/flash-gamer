import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/models/mission_entity.dart';
import 'package:flashgamer/services/user_service.dart';
import 'package:flashgamer/services/mission_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 1;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  String _userName = 'Explorador';
  int _userLevel = 12;
  int _currentXp = 550;
  int _maxXp = 1000;
  int _coins = 1250;
  int _streak = 3;
  List<Map<String, dynamic>> _topHeroes = [];
  List<MissionEntity> _missions = [];
  bool _isLoading = true;

  final Map<int, bool> _expandedCards = {};
  final List<Map<String, dynamic>> _learnCards = const [
    {
      'title': 'Quem descobriu o caminho marítimo para as Índias?',
      'subject': 'História',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFFF3E8FF),
      'textColor': Color(0xFF6B21A8),
      'borderColor': Color(0xFFC084FC),
      'content': 'Vasco da Gama foi um navegador e explorador português. Na Era dos Descobrimentos, destacou-se por ter comandado a primeira expedição marítima da Europa à Índia, em uma das viagens mais célebres da história colonialista de Portugal. A rota permitiu consolidar a hegemonia comercial portuguesa e conectar o Ocidente e Oriente de forma permanente por mar.',
    },
    {
      'title': 'Aproximação do valor de Pi (π)',
      'subject': 'Matemática',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFFE0F2FE),
      'textColor': Color(0xFF0369A1),
      'borderColor': Color(0xFF38BDF8),
      'content': 'Pi (π) é uma constante matemática definida pela razão entre a circunferência de um círculo e seu diâmetro. Seu valor aproximado com 5 casas decimais é 3.14159. Trata-se de um número irracional, o que significa que sua representação decimal é infinita e não periódica, sendo fundamental na geometria e trigonometria.',
    },
    {
      'title': 'O que é Silogismo Lógico?',
      'subject': 'Lógica',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFFFEF3C7),
      'textColor': Color(0xFFB45309),
      'borderColor': Color(0xFFFBBF24),
      'content': 'Um silogismo lógico é uma forma de raciocínio dedutivo que consiste em uma premissa maior, uma premissa menor e uma conclusão lógica. Por exemplo:\n• Premissa Maior: Todos os humanos são mortais.\n• Premissa Menor: Sócrates é humano.\n• Conclusão: Logo, Sócrates é mortal.\nMuito útil nos testes e desafios intelectuais!',
    },
    {
      'title': 'Estrutura do Conto Épico',
      'subject': 'Redação',
      'icon': Icons.create_rounded,
      'color': Color(0xFFF3F4F6),
      'textColor': Color(0xFF374151),
      'borderColor': Color(0xFF9CA3AF),
      'content': 'Um conto épico foca nas conquistas heróicas, grandes viagens e batalhas lendárias. Ele geralmente contém elementos de fantasia ou mitológicos. Dica de ouro para redigir um bom conto: divida a narrativa em Introdução da Missão, Confluxo de forças e a Resolução vitoriosa do Herói com a colheita dos frutos!',
    },
  ];

  static const Map<String, _CategoryTheme> _categoryThemes = {
    'História': _CategoryTheme(
      icon: Icons.quiz_rounded,
      borderColor: Color(0xFF7C3AED),
      buttonGradient: [Color(0xFF7C3AED), Color(0xFF9333EA)],
      iconBg: Color(0xFFF3E8FF),
      iconColor: Color(0xFF7C3AED),
    ),
    'Lógica': _CategoryTheme(
      icon: Icons.psychology_rounded,
      borderColor: Color(0xFF0891B2),
      buttonGradient: [Color(0xFF0891B2), Color(0xFF0E7490)],
      iconBg: Color(0xFFE0F7FA),
      iconColor: Color(0xFF0891B2),
    ),
    'Redação': _CategoryTheme(
      icon: Icons.edit_note_rounded,
      borderColor: Color(0xFFDC2626),
      buttonGradient: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      iconBg: Color(0xFFFEE2E2),
      iconColor: Color(0xFFDC2626),
    ),
    'Matemática': _CategoryTheme(
      icon: Icons.calculate_rounded,
      borderColor: Color(0xFF059669),
      buttonGradient: [Color(0xFF059669), Color(0xFF047857)],
      iconBg: Color(0xFFD1FAE5),
      iconColor: Color(0xFF059669),
    ),
    'Ciências': _CategoryTheme(
      icon: Icons.science_rounded,
      borderColor: Color(0xFFD97706),
      buttonGradient: [Color(0xFFD97706), Color(0xFFB45309)],
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
    ),
  };

  static const _CategoryTheme _defaultTheme = _CategoryTheme(
    icon: Icons.flag_rounded,
    borderColor: Color(0xFF7C3AED),
    buttonGradient: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    iconBg: Color(0xFFF3E8FF),
    iconColor: Color(0xFF7C3AED),
  );

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileFuture = UserService.getMyProfile();
      final rankingFuture = UserService.getRanking();
      final missionsFuture = MissionService.list();
      final UserEntity profile = await profileFuture;
      final ranking = await rankingFuture;
      List<MissionEntity> missions = [];
      try {
        missions = await missionsFuture;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _userName = profile.nome;
        _userLevel = profile.lv;
        _currentXp = profile.xp;
        _maxXp = profile.lv * 1000;
        _coins = profile.saldo.toInt();
        _streak = profile.diasSeguidos;
        _topHeroes = ranking
            .take(3)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _missions = missions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Aprender', icon: Icons.school_rounded),
    _NavItem(label: 'Missões', icon: Icons.flag_rounded),
    _NavItem(label: 'Ranking', icon: Icons.emoji_events_rounded),
    _NavItem(label: 'Loja', icon: Icons.store_rounded),
  ];

  static const List<MissionEntity> _fallbackMissions = [
    MissionEntity(id: 0, nome: 'Quiz de História', descricao: 'Desvende os mistérios do Império Romano.', categoria: 'História', xpRecompensa: 150),
    MissionEntity(id: 0, nome: 'Desafio de Lógica', descricao: 'Resolva 5 puzzles de pensamento lateral.', categoria: 'Lógica', xpRecompensa: 200),
    MissionEntity(id: 0, nome: 'Escrita Épica', descricao: 'Redija um conto heroico de 3 parágrafos.', categoria: 'Redação', xpRecompensa: 300),
  ];
  _CategoryTheme _themeFor(String? categoria) {
    return _categoryThemes[categoria] ?? _defaultTheme;
  }
  void _onNavTap(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/ranking');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/shop');
    } else {
      setState(() => _selectedTab = index);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              isMobile ? _buildMobileTopBar() : _buildDesktopTopBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: _buildBody(context),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }
  Widget _buildBottomNav() {
    final mobileItems = _navItems.sublist(1);
    final mobileIndex = (_selectedTab - 1).clamp(0, mobileItems.length - 1);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: mobileIndex,
        onTap: (i) => _onNavTap(i + 1),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        elevation: 0,
        items: mobileItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
  Widget _buildMobileTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                const Icon(Icons.monetization_on_rounded,
                    color: Color(0xFFF59E0B), size: 14),
                const SizedBox(width: 3),
                Text(
                  _coins.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
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
                const Icon(Icons.star_rounded,
                    color: Color(0xFF7C3AED), size: 14),
                const SizedBox(width: 3),
                Text(
                  'Nvl $_userLevel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B21A8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF7C3AED), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pushNamed(context, '/admin').then((_) => _loadData()),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withAlpha(40),
                    blurRadius: 6,
                  ),
                ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
            final isActive = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _onNavTap(i),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF6B21A8)
                          : Colors.grey.shade500,
                      decoration:
                          isActive ? TextDecoration.underline : TextDecoration.none,
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
                const Icon(Icons.monetization_on_rounded,
                    color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 4),
                Text(
                  _coins.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
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
                const Icon(Icons.star_rounded,
                    color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Nvl $_userLevel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B21A8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF7C3AED), size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pushNamed(context, '/admin').then((_) => _loadData()),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withAlpha(40),
                    blurRadius: 8,
                  ),
                ],
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
  Widget _buildBody(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    if (_selectedTab == 0) {
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildLearnSection(),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 260,
              child: _buildTopHeroesCard(),
            ),
          ],
        );
      }
      return Column(
        children: [
          _buildLearnSection(),
          const SizedBox(height: 24),
          _buildTopHeroesCard(),
        ],
      );
    }

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _buildMissionsSection(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 260,
            child: _buildTopHeroesCard(),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 24),
        _buildTopHeroesCard(),
        const SizedBox(height: 24),
        _buildMissionsSection(),
      ],
    );
  }

  Widget _buildLearnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conteúdos de Aprendizado 📚',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estude as matérias abaixo para se preparar para os desafios das missões diárias!',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(_learnCards.length, (i) => _buildLearnCard(i)),
        ),
      ],
    );
  }

  Widget _buildLearnCard(int idx) {
    final card = _learnCards[idx];
    final bool isExp = _expandedCards[idx] ?? false;
    final Color color = card['color'];
    final Color textColor = card['textColor'];
    final Color borderColor = card['borderColor'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isExp ? borderColor : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isExp ? borderColor.withAlpha(20) : Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandedCards[idx] = !isExp),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(card['icon'], color: textColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['subject'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            card['title'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExp)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      card['content'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildWelcomeCard() {
    final xpRemaining = _maxXp - _currentXp;
    final progress = _maxXp > 0 ? _currentXp / _maxXp : 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
        ),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarBadge(
            level: _userLevel,
            size: 80,
            innerColor: const Color(0xFF3B1564),
            badgeColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $_userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Faltam apenas $xpRemaining XP para alcançar o Nível ${_userLevel + 1}.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso Atual',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '$_currentXp / $_maxXp XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE9D5FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Missões do Dia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak dias seguidos',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final missions = _missions.isNotEmpty ? _missions : _fallbackMissions;
            if (constraints.maxWidth > 600) {
              return Row(
                children: missions
                    .map((m) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _buildMissionCard(m),
                          ),
                        ))
                    .toList(),
              );
            }
            return Column(
              children: missions
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMissionCard(m),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
  Widget _buildMissionCard(MissionEntity mission) {
    final theme = _themeFor(mission.categoria);
    final int xp = mission.xpRecompensa;
    final String title = mission.nome;
    final String description = mission.descricao;
    final int missionId = mission.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: theme.borderColor.withAlpha(80), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.borderColor.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(theme.icon, color: theme.iconColor, size: 22),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$xp XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: theme.iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppGradientButton(
              label: 'Iniciar Missão',
              onPressed: () {
                Navigator.pushNamed(context, '/question', arguments: {
                  'quizId': mission.quizId,
                  'missionId': missionId,
                }).then((_) => _loadData());
              },
              height: 40,
              borderRadius: 10,
              gradientColors: theme.buttonGradient,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTopHeroesCard() {
    final List<Map<String, dynamic>> heroes = _topHeroes.isNotEmpty
        ? _topHeroes
        : [
            {'nome': 'Mestre_K', 'xp': 12450},
            {'nome': 'NinjaMat', 'xp': 11000},
            {'nome': 'Ana_Hero', 'xp': 10850},
          ];
    final List<Color> medalColors = [
      const Color(0xFFF59E0B),
      const Color(0xFF9CA3AF),
      const Color(0xFFCD7F32),
    ];
    final List<Color> bgColors = [
      const Color(0xFFFEF3C7),
      Colors.white,
      Colors.white,
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 6),
              Text(
                'Top Heróis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(heroes.length, (i) {
            final hero = heroes[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: bgColors[i],
                border: i == 0
                    ? Border.all(color: const Color(0xFFFDE68A), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: medalColors[i],
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          medalColors[i],
                          medalColors[i].withAlpha(180),
                        ],
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: Color(0xFF3B1564),
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero['nome'] ?? 'Herói',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        Text(
                          '${_formatNumber(hero['xp'] ?? 0)} XP',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/ranking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B21A8),
                side: const BorderSide(color: Color(0xFFE9D5FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Ver Ranking Completo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return n.toString();
  }
}
class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}
class _CategoryTheme {
  final IconData icon;
  final Color borderColor;
  final List<Color> buttonGradient;
  final Color iconBg;
  final Color iconColor;
  const _CategoryTheme({
    required this.icon,
    required this.borderColor,
    required this.buttonGradient,
    required this.iconBg,
    required this.iconColor,
  });
}