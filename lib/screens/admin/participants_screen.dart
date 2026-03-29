// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/admin/participants_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../models/event.dart';
import '../../models/participant.dart';
import '../../services/event_provider.dart';
import 'draw_result_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ParticipantsScreen extends StatefulWidget {
  final String eventId;

  const ParticipantsScreen({super.key, required this.eventId});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isDrawing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _addParticipant() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EventProvider>();
    final event = provider.events.where((e) => e.id == widget.eventId).firstOrNull;
    if (event == null) return;

    // Verificar duplicata de telefone
    final phone = _phoneCtrl.text.trim();
    if (event.participants.any((p) => p.phone == phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este telefone já está cadastrado')),
      );
      return;
    }

    final participant = Participant(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: phone,
    );

    await provider.addParticipant(widget.eventId, participant);
    _nameCtrl.clear();
    _phoneCtrl.clear();

    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _shareWhatsApp(Event event) async {
    final dateStr = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(event.date);
    final buffer = StringBuffer();
    buffer.writeln('🎁 *${event.name}*');
    buffer.writeln();
    buffer.writeln('📅 Data: $dateStr');
    if (event.location.isNotEmpty) {
      buffer.writeln('📍 Local: ${event.location}');
    }
    if (event.message != null && event.message!.isNotEmpty) {
      buffer.writeln('📝 Obs: ${event.message}');
    }
    buffer.writeln();
    buffer.writeln('Para participar, acesse o GiftLoop e use o código:');
    buffer.writeln('👉 *${event.id}*');
    buffer.writeln();
    buffer.writeln('🔗 https://giftloop-41150.web.app');

    final encoded = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp não encontrado')),
      );
    }
  }

  Future<void> _editEventMeta(BuildContext screenContext, Event event) async {
    final nameCtrl = TextEditingController(text: event.name);
    final locationCtrl = TextEditingController(text: event.location);
    final messageCtrl = TextEditingController(text: event.message ?? '');
    DateTime selectedDate = event.date;
    final formKey = GlobalKey<FormState>();

    // Captura o provider ANTES de abrir o sheet
    final provider = screenContext.read<EventProvider>();

    await showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Título
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Editar evento',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Nunito',
                            color: AppTheme.deepText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Nome
                    GiftLoopTextField(
                      label: 'Nome do evento',
                      controller: nameCtrl,
                      prefixIcon: Icons.celebration_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o nome' : null,
                    ),
                    // Data
                    const Text(
                      'DATA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.subText,
                        letterSpacing: 0.8,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: screenContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: AppTheme.lilac, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR')
                                  .format(selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepText,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Local
                    GiftLoopTextField(
                      label: 'Local',
                      hint: 'Ex: Salão de festas do prédio',
                      controller: locationCtrl,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    // Observações
                    GiftLoopTextField(
                      label: 'Observações (opcional)',
                      hint: 'Ex: Valor máximo R\$ 50, traje casual...',
                      controller: messageCtrl,
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    // Salvar
                    GradientButton(
                      text: 'Salvar alterações',
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        await provider.updateEventMeta(
                          eventId: event.id,
                          name: nameCtrl.text.trim(),
                          date: selectedDate,
                          location: locationCtrl.text.trim(),
                          message: messageCtrl.text.trim().isEmpty
                              ? null
                              : messageCtrl.text.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    nameCtrl.dispose();
    locationCtrl.dispose();
    messageCtrl.dispose();
  }

  Future<void> _performDraw() async {
    final provider = context.read<EventProvider>();
    final event = provider.events.where((e) => e.id == widget.eventId).firstOrNull;
    if (event == null) return;

    if (event.participants.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 3 participantes para sortear'),
        ),
      );
      return;
    }

    // Confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Realizar o sorteio?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            color: AppTheme.deepText,
          ),
        ),
        content: Text(
          'Serão sorteados ${event.participants.length} participantes.\nApós o sorteio, não será possível adicionar mais participantes.',
          style: const TextStyle(
            fontFamily: 'Nunito',
            color: AppTheme.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.subText, fontFamily: 'Nunito'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lilac,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sortear!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDrawing = true);
    try {
      final success = await provider.performDraw(widget.eventId);
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DrawResultScreen(eventId: widget.eventId),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao realizar o sorteio. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDrawing = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado! 📋')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere(
          (e) => e.id == widget.eventId,
          orElse: () => Event(
            id: '', name: '', date: DateTime.now(),
            location: '', adminPhone: '',
          ),
        );

        return Scaffold(
          body: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  GiftLoopAppBar(
                    title: 'Participantes',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.lilac),
                        onPressed: () => _editEventMeta(context, event),
                        tooltip: 'Editar evento',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: AppTheme.lilac),
                        onPressed: () => _copyCode(event.id),
                        tooltip: 'Copiar código',
                      ),
                    ],
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // ── Código do evento ──────────────────────
                          GlassCard(
                            color: AppTheme.lilac.withValues(alpha: 0.1),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.blueGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.qr_code_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Código do evento',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.subText,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        event.id,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.lilac,
                                          letterSpacing: 4,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _copyCode(event.id),
                                  icon: const Icon(Icons.copy_rounded,
                                      color: AppTheme.lilac, size: 20),
                                  tooltip: 'Copiar código',
                                ),
                                IconButton(
                                  onPressed: () => _shareWhatsApp(event),
                                  icon: const Icon(Icons.share_rounded,
                                      color: Color(0xFF25D366), size: 20),
                                  tooltip: 'Compartilhar no WhatsApp',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Evento já sorteado — bloqueia edição ──
                          if (event.isDrawn) ...[
                            GlassCard(
                              color: AppTheme.pinkPastel.withValues(alpha: 0.08),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.pinkGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.lock_rounded,
                                        color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sorteio realizado',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.deepText,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Este evento está encerrado. Não é possível adicionar participantes ou realizar um novo sorteio.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.subText,
                                            fontFamily: 'Nunito',
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Formulário — só exibe se não sorteado ─
                          if (!event.isDrawn) ...[
                            GlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '➕ Adicionar participante',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    GiftLoopTextField(
                                      label: 'Nome',
                                      hint: 'Nome do participante',
                                      controller: _nameCtrl,
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator: (v) => v == null || v.trim().isEmpty
                                          ? 'Informe o nome'
                                          : null,
                                    ),
                                    GiftLoopTextField(
                                      label: 'Telefone (WhatsApp)',
                                      hint: '(11) 99999-9999',
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icons.phone_outlined,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Informe o telefone';
                                        }
                                        return null;
                                      },
                                    ),
                                    GradientButton(
                                      text: 'Adicionar',
                                      gradient: AppTheme.blueGradient,
                                      icon: Icons.add_rounded,
                                      onPressed: _addParticipant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Lista ─────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${event.participants.length} participante(s)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.subText,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              if (!event.isDrawn && event.participants.length >= 3)
                                const StatusChip(
                                  label: '✓ Pronto para sortear',
                                  color: Color(0xFF6DBB7E),
                                  bgColor: Color(0xFFE8F8EC),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (event.participants.isEmpty)
                            _EmptyState()
                          else
                            ...event.participants.asMap().entries.map((entry) {
                              return _ParticipantTile(
                                participant: entry.value,
                                index: entry.key + 1,
                                // Remove só permitido se não sorteado
                                onRemove: event.isDrawn
                                    ? null
                                    : () => context
                                        .read<EventProvider>()
                                        .removeParticipant(
                                            widget.eventId, entry.value.id),
                              ).animate(delay: Duration(milliseconds: entry.key * 80)).fadeIn().slideX(begin: 0.1, end: 0);
                            }),

                          const SizedBox(height: 24),

                          // ── Botão sortear — só exibe se não sorteado ──
                          if (!event.isDrawn && event.participants.length >= 3)
                            GradientButton(
                              text: '🎁 Realizar o Sorteio!',
                              gradient: AppTheme.pinkGradient,
                              onPressed: _performDraw,
                              isLoading: _isDrawing,
                            ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  final int index;
  final VoidCallback? onRemove; // null quando evento já foi sorteado

  const _ParticipantTile({
    required this.participant,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.pinkPastel,
      AppTheme.lilac,
      AppTheme.babyBlue,
    ];
    final color = colors[(index - 1) % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: color.withValues(alpha: 0.8),
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.deepText,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  participant.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.subText,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close_rounded,
                color: AppTheme.pinkPastel.withValues(alpha: 0.8), size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: const Column(
        children: [
          Text('👥', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Nenhum participante ainda',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.subText,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Adicione pelo menos 3 para sortear',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.subText,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}