// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/group_gifts_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../models/participant.dart';

class GroupGiftsScreen extends StatelessWidget {
  final String eventId;

  const GroupGiftsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere((e) => e.id == eventId);

        final participantsWithGifts = event.participants
            .where((p) => p.wishlist.isNotEmpty)
            .toList();

        final participantsOptedOut = event.participants
            .where((p) => p.optedOutOfGifts && p.wishlist.isEmpty)
            .toList();

        final participantsNoAction = event.participants
            .where((p) => !p.optedOutOfGifts && p.wishlist.isEmpty)
            .toList();

        final totalGifts = event.participants
            .expand((p) => p.wishlist)
            .length;

        return Scaffold(
          body: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const GiftLoopAppBar(title: 'Lista de Presentes'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Stats
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  emoji: '🎁',
                                  value: '$totalGifts',
                                  label: 'Presentes',
                                  gradient: AppTheme.pinkGradient,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  emoji: '👥',
                                  value: '${event.participants.length}',
                                  label: 'Participantes',
                                  gradient: AppTheme.blueGradient,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Aviso de contexto
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.babyBlue.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.babyBlue.withValues(alpha:0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Text('💡', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Veja o que cada pessoa quer ganhar e use como inspiracao para o seu presente!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.subText,
                                      fontFamily: 'Nunito',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Lista por participante
                          if (participantsWithGifts.isEmpty &&
                              participantsOptedOut.isEmpty &&
                              participantsNoAction.isEmpty)
                            _EmptyGiftsState()
                          else ...[
                            // Participantes COM lista de presentes
                            ...participantsWithGifts.asMap().entries.map((entry) {
                              return _ParticipantWishlistCard(
                                participant: entry.value,
                              ).animate(
                                delay: Duration(milliseconds: entry.key * 100),
                              ).fadeIn().slideY(begin: 0.1, end: 0);
                            }),

                            // Participantes que optaram por nao cadastrar
                            if (participantsOptedOut.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              GlassCard(
                                color: AppTheme.divider.withValues(alpha:0.4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text('🙈', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Preferiram a surpresa',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: AppTheme.subText,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...participantsOptedOut.map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• ${p.name}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.subText,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Participantes que ainda nao cadastraram nada
                            if (participantsNoAction.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              GlassCard(
                                color: AppTheme.pinkPastel.withValues(alpha:0.08),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text('⏳', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Ainda nao cadastraram',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: AppTheme.subText,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...participantsNoAction.map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• ${p.name}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.subText,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],

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

// ── Card de lista de desejos por participante ─────────────────────────────────

class _ParticipantWishlistCard extends StatelessWidget {
  final Participant participant;

  const _ParticipantWishlistCard({required this.participant});

  @override
  Widget build(BuildContext context) {
    final avatarColors = [
      AppTheme.pinkPastel,
      AppTheme.lilac,
      AppTheme.babyBlue,
    ];
    final color = avatarColors[
        participant.name.codeUnitAt(0) % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do participante
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      participant.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: color.withValues(alpha: 0.85),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    participant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppTheme.deepText,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                StatusChip(
                  label: '${participant.wishlist.length} presente(s)',
                  color: color.withValues(alpha: 0.8),
                  bgColor: color.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),

          // Presentes desejados
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: participant.wishlist.asMap().entries.map((entry) {
                final gift = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.softBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: color.withValues(alpha: 0.7),
                          fontFamily: 'Nunito',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gift.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.deepText,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            if (gift.notes != null && gift.notes!.isNotEmpty)
                              Text(
                                gift.notes!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.subText,
                                  fontFamily: 'Nunito',
                                  height: 1.3,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Text('🎁', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Gradient gradient;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lilac.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyGiftsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: const Column(
        children: [
          Text('🎀', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Nenhum presente cadastrado ainda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.subText,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Seja o primeiro a cadastrar!',
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