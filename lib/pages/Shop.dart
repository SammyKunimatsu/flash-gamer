import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/models/equipment.dart';
import 'package:flashgamer/services/user_service.dart';
import 'package:flashgamer/services/equipment_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  int _currentXp = 0;
  int _streak = 0;
  int _userLevel = 1;
  int _coins = 0;
  List<Equipment> _equipmentList = [];
  bool _isLoading = true;
  int _activeCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final UserEntity profile = await UserService.getMyProfile();
      final items = await EquipmentService.list();
      if (!mounted) return;
      setState(() {
        _userName = profile.nome;
        _userLevel = profile.lv;
        _coins = profile.saldo.toInt();
        _currentXp = profile.xp;
        _streak = profile.diasSeguidos;
        _equipmentList = items;
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
    if (index == 2) Navigator.pushReplacementNamed(context, '/ranking');
  }

  Future<void> _handleBuy(Equipment item) async {
    final int preco = item.valor.toInt();
    if (_coins < preco) {
      _showSnackBar('Faltam Moedas! Você precisa de mais ${preco - _coins} moedas.', Colors.red.shade600);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await EquipmentService.buy(item.id);
      _showSnackBar('Compra realizada com sucesso!', Colors.green.shade600);
      _loadData();
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red.shade600);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleToggle(Equipment item) async {
    setState(() => _isLoading = true);
    try {
      await EquipmentService.toggle(equipamentoId: item.id, ativo: item.ativo ? 0 : 1);
      _showSnackBar(item.ativo ? 'Item desequipado.' : 'Item equipado com sucesso!', Colors.purple.shade600);
      _loadData();
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red.shade600);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
        currentIndex: 2,
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
            final isActive = i == 3;
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
          SizedBox(width: 280, child: _buildHeroProfileCard()),
          const SizedBox(width: 24),
          Expanded(child: _buildStoreSection()),
        ],
      );
    }
    return Column(
      children: [
        _buildHeroProfileCard(),
        const SizedBox(height: 24),
        _buildStoreSection(),
      ],
    );
  }

  Widget _buildHeroProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [ BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        children: [
          const Text(
            'Seu Herói',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
          ),
          const SizedBox(height: 20),
          AvatarBadge(
            level: 42,
            size: 150,
            innerColor: const Color(0xFF3B1564),
            badgeColor: const Color(0xFF7C3AED),
            child: ClipOval(
              child: Image.asset(
                'assets/images/hero_store.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(Icons.layers_rounded, color: Color(0xFF7C3AED), size: 14),
                    SizedBox(width: 8),
                    Text('Capa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                    Spacer(),
                    Text('Capa Cósmica', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.pets_rounded, color: Color(0xFF7C3AED), size: 14),
                    SizedBox(width: 8),
                    Text('Pat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                    Spacer(),
                    Text('Robo-Owl v2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppGradientButton(
              label: 'Compartilhar Visual',
              icon: Icons.share_rounded,
              onPressed: () {},
              height: 44,
              borderRadius: 10,
              gradientColors: const [Color(0xFF375160), Color(0xFF4C6A7B)],
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loja de Equipamentos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalize seu herói e destaque-se no ranking!',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: [ BoxShadow(color: const Color(0xFFF59E0B).withAlpha(30), blurRadius: 10, offset: const Offset(0, 4)) ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SALDO TOTAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                      Text(
                        _coins.toString(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF92400E), height: 1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab(0, Icons.layers_rounded, 'Capas Heróicas'),
              const SizedBox(width: 8),
              _buildCategoryTab(1, Icons.healing_rounded, 'Capacetes'),
              const SizedBox(width: 8),
              _buildCategoryTab(2, Icons.pets_rounded, 'Pets Companheiros'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildStoreGrid(),
      ],
    );
  }

  Widget _buildCategoryTab(int idx, IconData icon, String label) {
    final isActive = _activeCategory == idx;
    return InkWell(
      onTap: () => setState(() => _activeCategory = idx),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7C3AED) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey.shade600, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGrid() {
    final List<Equipment> fallbackItems = [
      const CapeEquipment(id: 1, nome: 'Capa de Fogo Ignis', descricao: 'Efeito de chamas ao andar.', valor: 2500, comprado: false, ativo: false),
      const CapeEquipment(id: 2, nome: 'Capa Cósmica', descricao: 'A gravidade é opcional.', valor: 1500, comprado: true, ativo: true),
      const CapeEquipment(id: 3, nome: 'Capa Rei Dragão', descricao: 'Apenas para lendas.', valor: 50000, comprado: false, ativo: false),
      const CapeEquipment(id: 4, nome: 'Capa Glacial', descricao: 'Mantenha a calma na prova.', valor: 1800, comprado: false, ativo: false),
    ];

    final List<Equipment> items = _equipmentList.isNotEmpty ? _equipmentList : fallbackItems;

    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 900 ? 3 : 2;
    final double childAspectRatio = width > 900 ? 0.92 : 0.78;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final int preco = item.valor.toInt();
            final isEquipped = item.ativo;
            final isPurchased = item.comprado || isEquipped;
            final isLocked = !isPurchased && _coins < preco;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isEquipped ? const Color(0xFF7C3AED) : Colors.grey.shade100, width: isEquipped ? 2 : 1),
                boxShadow: [ BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 10, offset: const Offset(0, 4)) ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              item.categoryIcon,
                              size: 40,
                              color: isEquipped ? const Color(0xFF7C3AED) : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.nome,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.descricao,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _buildItemButton(item, isEquipped, isPurchased, isLocked, preco),
                    ],
                  ),
                  if (isEquipped)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_rounded, color: Color(0xFFD97706), size: 10),
                            SizedBox(width: 2),
                            Text('EQUIPADO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                          ],
                        ),
                      ),
                    ),
                  if (isLocked)
                    const Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(Icons.lock_rounded, color: Colors.grey, size: 16),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B21A8),
              side: const BorderSide(color: Color(0xFFE9D5FF)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Carregar Mais Itens', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemButton(Equipment item, bool isEquipped, bool isPurchased, bool isLocked, int preco) {
    if (isEquipped) {
      return SizedBox(
        height: 34,
        child: OutlinedButton(
          onPressed: () => _handleToggle(item),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE9D5FF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.zero,
          ),
          child: const Text('Em Uso', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
        ),
      );
    }
    if (isPurchased) {
      return SizedBox(
        height: 34,
        child: ElevatedButton(
          onPressed: () => _handleToggle(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: const Text('Equipar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      );
    }
    if (isLocked) {
      return Container(
        height: 34,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.red.shade100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Faltam Moedas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
        ),
      );
    }
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: () => _handleBuy(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(preco.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 4),
            const Text('Comprar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
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
