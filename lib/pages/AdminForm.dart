import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
import 'package:flashgamer/models/user_entity.dart';
import 'package:flashgamer/models/mission_entity.dart';
import 'package:flashgamer/models/quiz_entity.dart';
import 'package:flashgamer/models/equipment.dart';
import 'package:flashgamer/services/user_service.dart';
import 'package:flashgamer/services/mission_service.dart';
import 'package:flashgamer/services/quiz_service.dart';
import 'package:flashgamer/services/equipment_service.dart';

class AdminFormPage extends StatefulWidget {
  final dynamic entity;
  final String mode;

  const AdminFormPage({super.key, this.entity, required this.mode});

  @override
  State<AdminFormPage> createState() => _AdminFormPageState();
}

class _AdminFormPageState extends State<AdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores genéricos
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  // Controladores para Jogador
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _lvController = TextEditingController();
  final _xpController = TextEditingController();
  final _saldoController = TextEditingController();

  // Controladores para Missão
  final _categoriaController = TextEditingController();
  final _xpRecompensaController = TextEditingController();
  int? _selectedQuizId;
  List<QuizQuestionEntity> _quizzesList = [];

  // Controladores para Equipamento
  int _selectedEquipmentType = 1; // 1 = Capa, 2 = Capacete, 3 = Pet
  final _valorController = TextEditingController();

  // Controladores para Quiz
  final _tempoQuizController = TextEditingController();
  final _alt1Controller = TextEditingController();
  final _alt2Controller = TextEditingController();
  final _alt3Controller = TextEditingController();
  final _alt4Controller = TextEditingController();
  int _correctAnswerIndex = 0; // 0 = Alt 1, 1 = Alt 2, 2 = Alt 3, 3 = Alt 4

  @override
  void initState() {
    super.initState();
    _fillFormValues();
    if (widget.mode == 'mission') _loadQuizzes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _lvController.dispose();
    _xpController.dispose();
    _saldoController.dispose();
    _categoriaController.dispose();
    _xpRecompensaController.dispose();
    _valorController.dispose();
    _tempoQuizController.dispose();
    _alt1Controller.dispose();
    _alt2Controller.dispose();
    _alt3Controller.dispose();
    _alt4Controller.dispose();
    super.dispose();
  }

  void _fillFormValues() {
    if (widget.entity == null) {
      // Valores padrão para criação
      _lvController.text = '1';
      _xpController.text = '0';
      _saldoController.text = '0';
      _xpRecompensaController.text = '150';
      _tempoQuizController.text = '20';
      _valorController.text = '1000';
      return;
    }

    final entity = widget.entity;
    _nomeController.text = entity.nome;

    if (widget.mode == 'user' && entity is UserEntity) {
      _emailController.text = entity.email;
      _lvController.text = entity.lv.toString();
      _xpController.text = entity.xp.toString();
      _saldoController.text = entity.saldo.toInt().toString();
    } else if (widget.mode == 'mission' && entity is MissionEntity) {
      _descricaoController.text = entity.descricao;
      _categoriaController.text = entity.categoria;
      _xpRecompensaController.text = entity.xpRecompensa.toString();
      _selectedQuizId = entity.quizId;
    } else if (widget.mode == 'equipment' && entity is Equipment) {
      _descricaoController.text = entity.descricao;
      _selectedEquipmentType = entity.tipoId;
      _valorController.text = entity.valor.toInt().toString();
    } else if (widget.mode == 'quiz' && entity is QuizQuestionEntity) {
      _tempoQuizController.text = entity.tempoParaResposta.toString();
      if (entity.respostas.length >= 4) {
        _alt1Controller.text = entity.respostas[0].nome;
        _alt2Controller.text = entity.respostas[1].nome;
        _alt3Controller.text = entity.respostas[2].nome;
        _alt4Controller.text = entity.respostas[3].nome;

        for (int i = 0; i < entity.respostas.length; i++) {
          if (entity.respostas[i].certa) {
            _correctAnswerIndex = i;
            break;
          }
        }
      }
    }
  }

  Future<void> _loadQuizzes() async {
    try {
      final list = await QuizService.list();
      if (!mounted) return;
      setState(() => _quizzesList = list);
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final isEdit = widget.entity != null;
      final id = isEdit ? widget.entity.id : 0;

      if (widget.mode == 'user') {
        final nome = _nomeController.text.trim();
        final email = _emailController.text.trim();
        final senha = _senhaController.text;
        final lv = int.parse(_lvController.text);
        final xp = int.parse(_xpController.text);
        final saldo = double.parse(_saldoController.text);

        if (isEdit) {
          await UserService.updateUserAdmin(id, nome, email, senha: senha, lv: lv, xp: xp, saldo: saldo);
        } else {
          await UserService.createUserAdmin(nome, email, senha, lv, xp, saldo);
        }
      } else if (widget.mode == 'mission') {
        final nome = _nomeController.text.trim();
        final descricao = _descricaoController.text.trim();
        final categoria = _categoriaController.text.trim();
        final xp = int.parse(_xpRecompensaController.text);

        if (isEdit) {
          await MissionService.update(id, nome, descricao, categoria, xp, quizId: _selectedQuizId);
        } else {
          await MissionService.create(nome, descricao, categoria, xp, quizId: _selectedQuizId);
        }
      } else if (widget.mode == 'equipment') {
        final nome = _nomeController.text.trim();
        final descricao = _descricaoController.text.trim();
        final valor = double.parse(_valorController.text);

        if (isEdit) {
          await EquipmentService.update(id, nome, descricao, _selectedEquipmentType, valor);
        } else {
          await EquipmentService.create(nome, descricao, _selectedEquipmentType, valor);
        }
      } else if (widget.mode == 'quiz') {
        final nome = _nomeController.text.trim();
        final tempo = int.parse(_tempoQuizController.text);
        final List<Map<String, dynamic>> alternativas = [
          {'nome': _alt1Controller.text.trim(), 'certa': _correctAnswerIndex == 0},
          {'nome': _alt2Controller.text.trim(), 'certa': _correctAnswerIndex == 1},
          {'nome': _alt3Controller.text.trim(), 'certa': _correctAnswerIndex == 2},
          {'nome': _alt4Controller.text.trim(), 'certa': _correctAnswerIndex == 3},
        ];

        if (isEdit) {
          await QuizService.update(id, nome, tempo, alternativas);
        } else {
          await QuizService.create(nome, tempo, alternativas);
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red.shade600);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  String get _titleText {
    final prefix = widget.entity == null ? 'Adicionar' : 'Editar';
    if (widget.mode == 'user') return '$prefix Jogador';
    if (widget.mode == 'mission') return '$prefix Missão';
    if (widget.mode == 'quiz') return '$prefix Pergunta de Quiz';
    return '$prefix Item na Loja';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text(
          _titleText,
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.purple.shade50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._buildFormFields(),
                        const SizedBox(height: 36),
                        AppGradientButton(
                          label: 'SALVAR REGISTRO',
                          icon: Icons.save_rounded,
                          onPressed: _handleSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildFormFields() {
    final quizItems = [
      const DropdownMenuItem<int?>(value: null, child: Text('Nenhum Quiz')),
      ..._quizzesList.map((q) => DropdownMenuItem<int?>(
            value: q.id,
            child: Text(
              q.nome.length > 30 ? '${q.nome.substring(0, 30)}...' : q.nome,
              style: const TextStyle(fontSize: 13),
            ),
          )),
    ];
    if (_selectedQuizId != null && !_quizzesList.any((q) => q.id == _selectedQuizId))
      quizItems.add(DropdownMenuItem<int?>(
        value: _selectedQuizId,
        child: const Text('Carregando quiz...'),
      ));

    if (widget.mode == 'user') {
      return [
        AppTextField(
          label: 'Nome Completo',
          hint: 'Ex: Arthur Lancelot',
          icon: Icons.person_outline_rounded,
          controller: _nomeController,
          validator: (val) => val == null || val.isEmpty ? 'Insira o nome' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'E-mail do Jogador',
          hint: 'jogador@email.com',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Insira o e-mail';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'E-mail inválido';
            return null;
          },
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Senha da Conta',
          hint: widget.entity == null ? 'Mínimo 6 caracteres' : 'Deixe em branco para não alterar',
          icon: Icons.lock_outline_rounded,
          controller: _senhaController,
          obscureText: true,
          validator: (val) {
            if (widget.entity == null && (val == null || val.isEmpty)) return 'Insira uma senha inicial';
            if (val != null && val.isNotEmpty && val.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Nível',
                hint: '1',
                icon: Icons.star_outline_rounded,
                controller: _lvController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'Nível inválido' : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AppTextField(
                label: 'XP Atual',
                hint: '0',
                icon: Icons.bolt_rounded,
                controller: _xpController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'XP inválido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Saldo de Moedas',
          hint: '1000',
          icon: Icons.monetization_on_outlined,
          controller: _saldoController,
          keyboardType: TextInputType.number,
          validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'Saldo inválido' : null,
        ),
      ];
    }

    if (widget.mode == 'mission') {
      return [
        AppTextField(
          label: 'Nome da Missão',
          hint: 'Ex: Quiz de Física Espacial',
          icon: Icons.outlined_flag,
          controller: _nomeController,
          validator: (val) => val == null || val.isEmpty ? 'Insira o nome da missão' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Descrição Detalhada',
          hint: 'O que o herói deve fazer nesta missão?',
          icon: Icons.description_outlined,
          controller: _descricaoController,
          maxLines: 3,
          validator: (val) => val == null || val.isEmpty ? 'Insira a descrição' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Categoria',
          hint: 'Ex: Matemática, Física, Redação',
          icon: Icons.category_outlined,
          controller: _categoriaController,
          validator: (val) => val == null || val.isEmpty ? 'Insira a categoria' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Recompensa (XP)',
          hint: '150',
          icon: Icons.bolt_rounded,
          controller: _xpRecompensaController,
          keyboardType: TextInputType.number,
          validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'XP de recompensa inválido' : null,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<int?>(
          value: _selectedQuizId,
          decoration: InputDecoration(
            labelText: 'Quiz Associado',
            labelStyle: const TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.w700),
            prefixIcon: const Icon(Icons.quiz_outlined, color: Color(0xFF7C3AED)),
            filled: true,
            fillColor: const Color(0xFFF3E8FF).withAlpha(100),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: quizItems,
          onChanged: (val) => setState(() => _selectedQuizId = val),
        ),
      ];
    }

    if (widget.mode == 'equipment') {
      return [
        AppTextField(
          label: 'Nome do Item',
          hint: 'Ex: Capa Solar Cósmica',
          icon: Icons.shopping_bag_outlined,
          controller: _nomeController,
          validator: (val) => val == null || val.isEmpty ? 'Insira o nome' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Descrição do Item',
          hint: 'Qual o bônus estético deste equipamento?',
          icon: Icons.description_outlined,
          controller: _descricaoController,
          maxLines: 2,
          validator: (val) => val == null || val.isEmpty ? 'Insira a descrição' : null,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<int>(
          value: _selectedEquipmentType,
          decoration: InputDecoration(
            labelText: 'Tipo de Equipamento',
            labelStyle: const TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.w700),
            prefixIcon: const Icon(Icons.layers_rounded, color: Color(0xFF7C3AED)),
            filled: true,
            fillColor: const Color(0xFFF3E8FF).withAlpha(100),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('Capa')),
            DropdownMenuItem(value: 2, child: Text('Capacete')),
            DropdownMenuItem(value: 3, child: Text('Pet Companheiro')),
          ],
          onChanged: (val) => setState(() => _selectedEquipmentType = val ?? 1),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Preço (Moedas)',
          hint: '1500',
          icon: Icons.monetization_on_outlined,
          controller: _valorController,
          keyboardType: TextInputType.number,
          validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Preço inválido' : null,
        ),
      ];
    }

    // Modo Quiz
    return [
      AppTextField(
        label: 'Pergunta do Quiz',
        hint: 'Ex: Qual é a fórmula química da água?',
        icon: Icons.quiz_outlined,
        controller: _nomeController,
        maxLines: 2,
        validator: (val) => val == null || val.isEmpty ? 'Insira a pergunta' : null,
      ),
      const SizedBox(height: 20),
      AppTextField(
        label: 'Tempo para Responder (segundos)',
        hint: '20',
        icon: Icons.timer_outlined,
        controller: _tempoQuizController,
        keyboardType: TextInputType.number,
        validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'Tempo inválido' : null,
      ),
      const SizedBox(height: 24),
      const Text(
        'Alternativas do Quiz',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4C1D95)),
      ),
      const SizedBox(height: 12),
      AppTextField(
        label: 'Alternativa 1',
        hint: 'H2O',
        icon: Icons.looks_one_outlined,
        controller: _alt1Controller,
        validator: (val) => val == null || val.isEmpty ? 'Insira a alternativa 1' : null,
      ),
      const SizedBox(height: 10),
      AppTextField(
        label: 'Alternativa 2',
        hint: 'CO2',
        icon: Icons.looks_two_outlined,
        controller: _alt2Controller,
        validator: (val) => val == null || val.isEmpty ? 'Insira a alternativa 2' : null,
      ),
      const SizedBox(height: 10),
      AppTextField(
        label: 'Alternativa 3',
        hint: 'NaCl',
        icon: Icons.looks_3_outlined,
        controller: _alt3Controller,
        validator: (val) => val == null || val.isEmpty ? 'Insira a alternativa 3' : null,
      ),
      const SizedBox(height: 10),
      AppTextField(
        label: 'Alternativa 4',
        hint: 'O2',
        icon: Icons.looks_4_outlined,
        controller: _alt4Controller,
        validator: (val) => val == null || val.isEmpty ? 'Insira a alternativa 4' : null,
      ),
      const SizedBox(height: 20),
      DropdownButtonFormField<int>(
        value: _correctAnswerIndex,
        decoration: InputDecoration(
          labelText: 'Qual é a resposta CORRETA?',
          labelStyle: const TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.w700),
          prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          filled: true,
          fillColor: Colors.green.shade50.withAlpha(100),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Alternativa 1')),
          DropdownMenuItem(value: 1, child: Text('Alternativa 2')),
          DropdownMenuItem(value: 2, child: Text('Alternativa 3')),
          DropdownMenuItem(value: 3, child: Text('Alternativa 4')),
        ],
        onChanged: (val) => setState(() => _correctAnswerIndex = val ?? 0),
      ),
    ];
  }
}
