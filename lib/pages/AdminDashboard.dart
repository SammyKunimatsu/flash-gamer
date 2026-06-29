import 'package:flutter/material.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/models/mission_entity.dart';
import 'package:flashgamer/models/quiz_entity.dart';
import 'package:flashgamer/models/equipment.dart';
import 'package:flashgamer/services/user_service.dart';
import 'package:flashgamer/services/mission_service.dart';
import 'package:flashgamer/services/quiz_service.dart';
import 'package:flashgamer/services/equipment_service.dart';
import 'package:flashgamer/pages/AdminForm.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  List<UserEntity> _users = [];
  List<MissionEntity> _missions = [];
  List<QuizQuestionEntity> _quizzes = [];
  List<Equipment> _equipments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadTabCachedData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _loadCurrentTabData();
  }

  Future<void> _loadTabCachedData() async {
    _loadCurrentTabData();
  }

  Future<void> _loadCurrentTabData() async {
    setState(() => _isLoading = true);
    try {
      final index = _tabController.index;
      if (index == 0) {
        final list = await UserService.listAllUsers();
        setState(() => _users = list);
      } else if (index == 1) {
        final list = await MissionService.list();
        setState(() => _missions = list);
      } else if (index == 2) {
        final list = await QuizService.list();
        setState(() => _quizzes = list);
      } else if (index == 3) {
        final list = await EquipmentService.list();
        setState(() => _equipments = list);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red.shade600);
    } finally {
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

  void _openForm({dynamic entity, required String mode}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminFormPage(entity: entity, mode: mode),
      ),
    ).then((success) {
      if (success == true) {
        _showSnackBar(
          entity == null ? 'Registro criado com sucesso!' : 'Registro atualizado com sucesso!',
          Colors.green.shade600,
        );
        _loadCurrentTabData();
      }
    });
  }

  Future<void> _handleDelete(dynamic entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar Exclusão', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
        content: const Text('Você tem certeza de que deseja excluir este registro de forma permanente? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final id = entity.id;
      if (entity is UserEntity) {
        await UserService.deleteUserAdmin(id);
      } else if (entity is MissionEntity) {
        await MissionService.delete(id);
      } else if (entity is QuizQuestionEntity) {
        await QuizService.delete(id);
      } else if (entity is Equipment) {
        await EquipmentService.delete(id);
      }
      _showSnackBar('Registro excluído com sucesso!', Colors.green.shade600);
      _loadCurrentTabData();
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red.shade600);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text(
          'Painel do Mestre',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFBBF24),
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(160),
          tabs: const [
            Tab(icon: Icon(Icons.people_rounded), text: 'Jogadores'),
            Tab(icon: Icon(Icons.flag_rounded), text: 'Missões'),
            Tab(icon: Icon(Icons.quiz_rounded), text: 'Quizzes'),
            Tab(icon: Icon(Icons.store_rounded), text: 'Loja'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(),
                _buildMissionsList(),
                _buildQuizzesList(),
                _buildEquipmentsList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final idx = _tabController.index;
          if (idx == 0) _openForm(mode: 'user');
          if (idx == 1) _openForm(mode: 'mission');
          if (idx == 2) _openForm(mode: 'quiz');
          if (idx == 3) _openForm(mode: 'equipment');
        },
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) return const Center(child: Text('Nenhum jogador cadastrado.', style: TextStyle(color: Colors.grey)));
    return RefreshIndicator(
      onRefresh: _loadCurrentTabData,
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final user = _users[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 40).clamp(0, 300)),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade50),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF3B1564),
                  child: Text('Nvl ${user.lv}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                title: Text(user.nome, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B))),
                subtitle: Text('${user.email} | ${user.saldo.toInt()} Moedas | ${user.xp} XP', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C3AED)),
                      onPressed: () => _openForm(entity: user, mode: 'user'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
                      onPressed: () => _handleDelete(user),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissionsList() {
    if (_missions.isEmpty) return const Center(child: Text('Nenhuma missão cadastrada.', style: TextStyle(color: Colors.grey)));
    return RefreshIndicator(
      onRefresh: _loadCurrentTabData,
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _missions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final mission = _missions[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 40).clamp(0, 300)),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade50),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFEF3C7),
                  child: const Icon(Icons.flag_rounded, color: Color(0xFFD97706)),
                ),
                title: Text(mission.nome, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B))),
                subtitle: Text('${mission.categoria} | Recompensa: +${mission.xpRecompensa} XP', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C3AED)),
                      onPressed: () => _openForm(entity: mission, mode: 'mission'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
                      onPressed: () => _handleDelete(mission),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizzesList() {
    if (_quizzes.isEmpty) return const Center(child: Text('Nenhuma pergunta de quiz cadastrada.', style: TextStyle(color: Colors.grey)));
    return RefreshIndicator(
      onRefresh: _loadCurrentTabData,
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 40).clamp(0, 300)),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade50),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF3E8FF),
                  child: const Icon(Icons.quiz_rounded, color: Color(0xFF7C3AED)),
                ),
                title: Text(quiz.nome, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Tempo: ${quiz.tempoParaResposta}s | ${quiz.respostas.length} alternativas', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C3AED)),
                      onPressed: () => _openForm(entity: quiz, mode: 'quiz'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
                      onPressed: () => _handleDelete(quiz),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipmentsList() {
    if (_equipments.isEmpty) return const Center(child: Text('Nenhum item na loja cadastrado.', style: TextStyle(color: Colors.grey)));
    return RefreshIndicator(
      onRefresh: _loadCurrentTabData,
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _equipments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final eq = _equipments[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 40).clamp(0, 300)),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade50),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE0F2FE),
                  child: Icon(eq.categoryIcon, color: const Color(0xFF0284C7)),
                ),
                title: Text(eq.nome, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B))),
                subtitle: Text('${eq.categoryName} | Preço: ${eq.valor.toInt()} moedas', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C3AED)),
                      onPressed: () => _openForm(entity: eq, mode: 'equipment'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
                      onPressed: () => _handleDelete(eq),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
