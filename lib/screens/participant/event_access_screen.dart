// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/event_access_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../models/participant.dart';
import '../../models/event.dart';
import '../../screens/admin/participants_screen.dart';
import 'secret_friend_screen.dart';
import '../../services/pin_service.dart';

class EventAccessScreen extends StatelessWidget {
  final String eventId;
  final String participantPhone;

  const EventAccessScreen({
    super.key,
    required this.eventId,
    required this.participantPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere(
          (e) => e.id == eventId,
          orElse: () => Event(
            id: '', name: 'Evento', date: DateTime.now(),
            location: '', adminPhone: '',
          ),
        );

        final participant = event.participants.firstWhere(
          (p) => p.phone == participantPhone,
          orElse: () => Participant(id: '', name: 'Participante', phone: ''),
        );

        // Verifica se quem acessou é o admin do evento.
        // admin vê painel com acesso ao gerenciamento e ao sorteio.
        final isAdmin = participantPhone == event.adminPhone;

        final dateStr = DateFormat(
          "dd 'de' MMMM 'de' yyyy", 'pt_BR',
        ).format(event.date);

        return Scaffold(
          body: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  GiftLoopAppBar(
                    title: isAdmin ? 'Painel do Admin' : 'Evento',
                    actions: isAdmin
                        ? null
                        : [
                            // Botão de sair — limpa sessão local imediatamente.
                            // Essencial para quem acessa o app no celular de outra pessoa.
                            TextButton.icon(
                              onPressed: () async {
                                await PinService.clearSession(eventId, participantPhone);
                                if (context.mounted) {
                                  Navigator.of(context).popUntil((r) => r.isFirst);
                                }
                              },
                              icon: const Icon(Icons.logout_rounded,
                                  size: 16, color: AppTheme.subText),
                              label: const Text(
                                'Sair',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.subText,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // ── Boas-vindas ──────────────────────────────
                          GlassCard(
                            color: (isAdmin
                                    ? AppTheme.pinkPastel
                                    : AppTheme.lilac)
                                .withValues(alpha: 0.1),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: isAdmin
                                        ? AppTheme.pinkGradient
                                        : AppTheme.blueGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isAdmin
                                        ? const Icon(
                                            Icons.admin_panel_settings_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          )
                                        : Text(
                                            participant.name.isNotEmpty
                                                ? participant.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isAdmin
                                      ? 'Olá, ${participant.name.split(' ').first}! 👑'
                                      : 'Olá, ${participant.name.split(' ').first}! 👋',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.deepText,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAdmin
                                      ? 'Você é o organizador deste evento'
                                      : 'Você está participando de:',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.subText,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15, end: 0),

                          const SizedBox(height: 16),

                          // ── Info do evento ───────────────────────────
                          GlassCard(
                            child: Column(
                              children: [
                                _InfoRow(
                                  icon: Icons.celebration_rounded,
                                  label: 'Evento',
                                  value: event.name,
                                  color: AppTheme.pinkPastel,
                                ),
                                const Divider(color: AppTheme.divider, height: 20),
                                _InfoRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Data',
                                  value: dateStr,
                                  color: AppTheme.lilac,
                                ),
                                const Divider(color: AppTheme.divider, height: 20),
                                _InfoRow(
                                  icon: Icons.location_on_rounded,
                                  label: 'Local',
                                  value: event.location,
                                  color: AppTheme.babyBlue,
                                ),
                                if (event.message != null &&
                                    event.message!.isNotEmpty) ...[
                                  const Divider(color: AppTheme.divider, height: 20),
                                  _InfoRow(
                                    icon: Icons.message_rounded,
                                    label: 'Mensagem',
                                    value: event.message!,
                                    color: AppTheme.pinkPastel,
                                  ),
                                ],
                              ],
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                          const SizedBox(height: 16),

                          // ── Status dos participantes ─────────────────
                          GlassCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.babyBlue.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.group_rounded,
                                          color: AppTheme.babyBlue, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${event.participants.length} participante${event.participants.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    const Spacer(),
                                    StatusChip(
                                      label: event.isDrawn ? 'Sorteado ✓' : 'Aguardando',
                                      color: event.isDrawn
                                          ? const Color(0xFF6DBB7E)
                                          : AppTheme.subText,
                                      bgColor: event.isDrawn
                                          ? const Color(0xFFE8F8EC)
                                          : AppTheme.divider,
                                    ),
                                  ],
                                ),
                                if (event.participants.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(color: AppTheme.divider, height: 1),
                                  const SizedBox(height: 12),
                                  ...event.participants.map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              gradient: p.phone == participantPhone
                                                  ? AppTheme.pinkGradient
                                                  : AppTheme.blueGradient,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                p.name.isNotEmpty
                                                    ? p.name[0].toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  fontFamily: 'Nunito',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              p.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: p.phone == participantPhone
                                                    ? FontWeight.w900
                                                    : FontWeight.w600,
                                                color: AppTheme.deepText,
                                                fontFamily: 'Nunito',
                                              ),
                                            ),
                                          ),
                                          if (p.phone == participantPhone)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppTheme.pinkPastel
                                                    .withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'você',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.pinkPastel,
                                                  fontFamily: 'Nunito',
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

                          const SizedBox(height: 28),

                          // ── Botões de ação ───────────────────────────
                          if (isAdmin)
                            _AdminActionsPanel(
                              event: event,
                              participantPhone: participantPhone,
                              eventId: eventId,
                            )
                          else
                            _ParticipantActionsPanel(
                              event: event,
                              eventId: eventId,
                              participantPhone: participantPhone,
                            ),

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

// ── Painel do Admin ───────────────────────────────────────────────────────────

class _AdminActionsPanel extends StatelessWidget {
  final Event event;
  final String participantPhone;
  final String eventId;

  const _AdminActionsPanel({
    required this.event,
    required this.participantPhone,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientButton(
          text: event.isDrawn ? '👥 Gerenciar evento' : '🎁 Gerenciar e sortear',
          gradient: AppTheme.pinkGradient,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParticipantsScreen(eventId: eventId),
            ),
          ),
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

        const SizedBox(height: 14),

        if (event.isDrawn) ...[
          // Admin também é participante: pode ver seu amigo secreto
          GradientButton(
            text: '🎉 Ver meu amigo secreto',
            gradient: AppTheme.blueGradient,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SecretFriendScreen(
                  eventId: eventId,
                  participantPhone: participantPhone,
                ),
              ),
            ),
          ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pinkPastel.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.pinkPastel.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Acesse o gerenciamento para adicionar participantes e realizar o sorteio.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.subText,
                      fontFamily: 'Nunito',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ],
    );
  }
}

// ── Painel do Participante ────────────────────────────────────────────────────

class _ParticipantActionsPanel extends StatelessWidget {
  final Event event;
  final String eventId;
  final String participantPhone;

  const _ParticipantActionsPanel({
    required this.event,
    required this.eventId,
    required this.participantPhone,
  });

  @override
  Widget build(BuildContext context) {
    if (event.isDrawn) {
      return GradientButton(
        text: '🎁 Ver quem você tirou!',
        gradient: AppTheme.pinkGradient,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecretFriendScreen(
              eventId: eventId,
              participantPhone: participantPhone,
            ),
          ),
        ),
      ).animate(delay: 400.ms).fadeIn().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.babyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.babyBlue.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Text('⏳', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aguardando o organizador realizar o sorteio...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subText,
                fontFamily: 'Nunito',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.subText,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepText,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}