// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/admin/my_events_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/auth_service.dart';
import '../../services/event_provider.dart';
import '../../models/event.dart';
import 'participants_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Recarrega do Firestore sempre que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              GiftLoopAppBar(
                title: 'Meus Eventos',
                actions: [
                  IconButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.white,
                          title: const Text(
                            'Sair da conta?',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              color: AppTheme.deepText,
                            ),
                          ),
                          content: const Text(
                            'Você será desconectado e precisará fazer login novamente para gerenciar seus eventos.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppTheme.subText,
                              height: 1.4,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: AppTheme.subText,
                                      fontWeight: FontWeight.w700)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lilac,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Sair',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await auth.signOut();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppTheme.subText, size: 22),
                    tooltip: 'Sair',
                  ),
                ],
              ),
              Expanded(
                child: Consumer<EventProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.lilac),
                      );
                    }

                    final events = provider.events;

                    if (events.isEmpty) return _EmptyState();

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _EventCard(event: events[index])
                            .animate(delay: (index * 80).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card de evento ─────────────────────────────────────────────────────────────

class _EventCard extends StatefulWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard>
    with SingleTickerProviderStateMixin {
  bool _deleteMode = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _enterDeleteMode() {
    HapticFeedback.mediumImpact();
    setState(() => _deleteMode = true);
    _shakeController.repeat();
  }

  void _exitDeleteMode() {
    setState(() => _deleteMode = false);
    _shakeController.stop();
    _shakeController.reset();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    _shakeController.stop();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Excluir evento?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                  color: AppTheme.deepText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    color: AppTheme.subText,
                    height: 1.5),
                children: [
                  const TextSpan(text: 'Você está prestes a excluir o evento\n'),
                  TextSpan(
                    text: '"${widget.event.name}"',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppTheme.deepText),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação é permanente e não pode ser desfeita.',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppTheme.subText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Sim, excluir',
                style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await context.read<EventProvider>().deleteEvent(widget.event.id);
    } else {
      _exitDeleteMode();
      _shakeController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmall = screenWidth < 360;
    final isDrawn = widget.event.isDrawn;

    final dateStr =
        DateFormat("dd 'de' MMM 'de' yyyy", 'pt_BR').format(widget.event.date);
    final hasLocation = widget.event.location.isNotEmpty;
    final hasMessage = widget.event.message != null &&
        widget.event.message!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: _deleteMode
            ? _exitDeleteMode
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ParticipantsScreen(eventId: widget.event.id),
                  ),
                ),
        onLongPress: _deleteMode ? null : _enterDeleteMode,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shake = _deleteMode
                ? 2.0 *
                    (0.5 - (_shakeController.value * 6 % 1.0 - 0.5).abs())
                : 0.0;
            return Transform.translate(offset: Offset(shake, 0), child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _deleteMode
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // ── Card ──────────────────────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  color: _deleteMode
                      ? Colors.red.withValues(alpha: 0.06)
                      : isDrawn
                          ? AppTheme.pinkPastel.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.85),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Header: ícone + nome + badge ──────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmall ? 38 : 44,
                            height: isSmall ? 38 : 44,
                            decoration: BoxDecoration(
                              gradient: _deleteMode
                                  ? const LinearGradient(colors: [
                                      Colors.red,
                                      Color(0xFFFF6B6B)
                                    ])
                                  : isDrawn
                                      ? AppTheme.pinkGradient
                                      : AppTheme.blueGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _deleteMode
                                  ? Icons.delete_outline_rounded
                                  : isDrawn
                                      ? Icons.celebration_rounded
                                      : Icons.hourglass_top_rounded,
                              color: Colors.white,
                              size: isSmall ? 18 : 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.event.name,
                              style: TextStyle(
                                fontSize: isSmall ? 14 : 16,
                                fontWeight: FontWeight.w900,
                                color: _deleteMode
                                    ? Colors.red
                                    : AppTheme.deepText,
                                fontFamily: 'Nunito',
                                decoration: _deleteMode
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.red,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge status
                          _deleteMode
                              ? GestureDetector(
                                  onTap: _exitDeleteMode,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('✕ Cancelar',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Nunito',
                                          color: AppTheme.subText,
                                        )),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDrawn
                                        ? AppTheme.pinkPastel
                                            .withValues(alpha: 0.2)
                                        : AppTheme.babyBlue
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isDrawn ? 'Sorteado' : 'Aguardando',
                                    style: TextStyle(
                                      fontSize: isSmall ? 9 : 11,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Nunito',
                                      color: isDrawn
                                          ? AppTheme.pinkPastel
                                          : AppTheme.babyBlue,
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(
                        color: _deleteMode
                            ? Colors.red.withValues(alpha: 0.2)
                            : AppTheme.divider,
                        height: 1,
                      ),
                      const SizedBox(height: 10),

                      // ── Infos: data, local, observações ───────────────
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: dateStr,
                        faded: _deleteMode,
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 5),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: widget.event.location,
                          faded: _deleteMode,
                        ),
                      ],
                      if (hasMessage) ...[
                        const SizedBox(height: 5),
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          text: widget.event.message!,
                          faded: _deleteMode,
                          maxLines: 2,
                        ),
                      ],

                      const SizedBox(height: 10),
                      Divider(
                        color: _deleteMode
                            ? Colors.red.withValues(alpha: 0.2)
                            : AppTheme.divider,
                        height: 1,
                      ),
                      const SizedBox(height: 10),

                      // ── Footer: código + participantes + seta ─────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CÓDIGO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.subText,
                                      fontFamily: 'Nunito',
                                      letterSpacing: 1,
                                    )),
                                Text(
                                  widget.event.id,
                                  style: TextStyle(
                                    fontSize: isSmall ? 16 : 20,
                                    fontWeight: FontWeight.w900,
                                    color: _deleteMode
                                        ? Colors.red.withValues(alpha: 0.4)
                                        : AppTheme.lilac,
                                    letterSpacing: 2,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('PARTICIPANTES',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.subText,
                                    fontFamily: 'Nunito',
                                    letterSpacing: 1,
                                  )),
                              Row(
                                children: [
                                  Icon(Icons.people_rounded,
                                      color: _deleteMode
                                          ? Colors.red.withValues(alpha: 0.4)
                                          : AppTheme.lilac,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.event.participants.length}',
                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 20,
                                      fontWeight: FontWeight.w900,
                                      color: _deleteMode
                                          ? Colors.red.withValues(alpha: 0.4)
                                          : AppTheme.lilac,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _deleteMode
                                ? Colors.transparent
                                : AppTheme.subText,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Lixeira central — modo exclusão ───────────────────────
                if (_deleteMode)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.delete_forever_rounded,
                              color: Colors.white, size: 34),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.08, 1.08),
                              duration: 600.ms,
                              curve: Curves.easeInOut,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Linha de informação ───────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool faded;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.faded = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final color = faded
        ? AppTheme.subText.withValues(alpha: 0.4)
        : AppTheme.subText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Estado vazio ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.event_note_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum evento ainda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.deepText,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie sua primeira dinâmica\nde amigo oculto!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subText,
                fontFamily: 'Nunito',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Criar dinâmica',
              gradient: AppTheme.pinkGradient,
              icon: Icons.add_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }
}