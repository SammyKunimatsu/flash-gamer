import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/services/user_service.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  int _currentXp = 0;
  int _streak = 0;
  int _userLevel = 1;
  int _coins = 0;
  List<dynamic> _rankingList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final UserEntity profile = await UserService.getMyProfile();
      final ranking = await UserService.getRanking();
      if (!mounted) return;
      setState(() {
        _userName = profile.nome;
        _userLevel = profile.lv;
        _coins = profile.saldo.toInt();
        _currentXp = profile.xp;
        _streak = profile.diasSeguidos;
        _rankingList = ranking;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Aprender', icon: Icons.school_rounded),
    _NavItem(label: 'Missões', icon: Icons.flag_rounded),
    _NavItem(label: 'Ranking', icon: Icons.emoji_events_rounded),
    _NavItem(label: 'Loja', icon: Icons.store_rounded),
  ];

  void _onNavTap(int index) {
    if (index == 0 || index == 1) Navigator.pushReplacementNamed(context, '/home');
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          _buildBody(context),
                          const SizedBox(height: 48),
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
        currentIndex: 1,
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
            final isActive = i == 2;
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

  Widget _buildBody(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildRankingCard()),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: _buildTrophyCard()),
        ],
      );
    }
    return Column(
      children: [
        _buildRankingCard(),
        const SizedBox(height: 24),
        _buildTrophyCard(),
      ],
    );
  }

  Widget _buildRankingCard() {
    final List<Map<String, dynamic>> fallbackRanking = [
      {'nome': 'Sofia M.', 'xp': 8900},
      {'nome': 'Lucas R.', 'xp': 7450},
      {'nome': 'Mariana P.', 'xp': 6200},
      {'nome': 'João S.', 'xp': 5800},
      {'nome': 'Beatriz C.', 'xp': 5100},
      {'nome': 'Carlos A.', 'xp': 4320},
    ];

    final ranking = _rankingList.isNotEmpty ? _rankingList : fallbackRanking;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top 20 Semanal',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A corrida pela liderança reseta em 2d 14h.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.groups_rounded, color: Color(0xFF7C3AED), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Liga Ouro II',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B21A8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (ctx) {
              int userPos = 0;
              int userXp = 0;
              for (int i = 0; i < ranking.length; i++) {
                if (ranking[i]['nome'] == _userName) {
                  userPos = i + 1;
                  userXp = (ranking[i]['xp'] as num?)?.toInt() ?? 0;
                  break;
                }
              }
              if (userPos == 0) {
                userPos = ranking.length + 1;
                userXp = _currentXp;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7C3AED)),
                      child: Center(
                        child: Text(userPos.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3B1564)),
                      child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Você',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                          ),
                          Text(
                            'Nível $_userLevel • Ofensiva de $_streak dias 🔥',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7C3AED)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$userXp XP',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF6B21A8)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ranking.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
             itemBuilder: (context, index) {
              final user = ranking[index];
              final pos = index + 1;
              final isPodium = pos <= 3;
              final isMe = user['nome'] == _userName;
              
              Color rowBg = Colors.white;
              Color posColor = Colors.grey.shade500;
              Color xpColor = Colors.grey.shade600;
              Color borderColor = isMe ? const Color(0xFF7C3AED) : (isPodium ? Colors.transparent : Colors.grey.shade100);
              
              if (isMe) {
                rowBg = const Color(0xFFF5F0FF);
                posColor = const Color(0xFF7C3AED);
                xpColor = const Color(0xFF6B21A8);
              } else if (pos == 1) {
                rowBg = const Color(0xFFFEF3C7);
                posColor = const Color(0xFFD97706);
                xpColor = const Color(0xFF92400E);
              } else if (pos == 2) {
                rowBg = const Color(0xFFF3F4F6);
                posColor = const Color(0xFF4B5563);
                xpColor = const Color(0xFF374151);
              } else if (pos == 3) {
                rowBg = const Color(0xFFFEE2E2);
                posColor = const Color(0xFFDC2626);
                xpColor = const Color(0xFF991B1B);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: rowBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isMe ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        pos.toString(),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: posColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMe ? const Color(0xFF7C3AED) : (isPodium ? posColor : Colors.grey.shade300),
                      ),
                      child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMe ? '${user['nome'] ?? ''} (Você)' : (user['nome'] ?? 'Explorador'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                    ),
                    Text(
                      'Nível ${user['lv'] ?? 1} • ${user['xp'] ?? 0} XP',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: xpColor),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppGradientButton(
              label: 'Carregar mais posições',
              onPressed: () {},
              height: 46,
              borderRadius: 10,
              gradientColors: const [Color(0xFFE9D5FF), Color(0xFFF3E8FF)],
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Galeria de Troféus',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
          ),
          const SizedBox(height: 4),
          Text(
            'Suas conquistas épicas na jornada.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0284C7)),
                  child: const Center(child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mestre das Chamas',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '30 dias de ofensiva mantida com perfeição.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildTrophyItem(Icons.menu_book_rounded, 'Ouro em Matemática', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              _buildTrophyItem(Icons.star_rounded, 'Prata em Ciências', const Color(0xFFF3F4F6), const Color(0xFF4B5563)),
              _buildTrophyItem(Icons.auto_awesome_rounded, 'Mente Brilhante', const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
              _buildTrophyItem(Icons.lock_rounded, 'Foco Total', const Color(0xFFF9FAFB), Colors.grey.shade400, isLocked: true),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Ver todas as conquistas',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyItem(IconData icon, String title, Color bg, Color itemColor, {bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: itemColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isLocked ? Colors.grey.shade500 : const Color(0xFF1E1B4B)),
            textAlign: TextAlign.center,
          ),
        ],
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
