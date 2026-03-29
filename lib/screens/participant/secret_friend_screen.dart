// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/secret_friend_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../models/participant.dart';
import 'add_gift_screen.dart';
import 'group_gifts_screen.dart';

class SecretFriendScreen extends StatefulWidget {
  final String eventId;
  final String participantPhone;

  const SecretFriendScreen({
    super.key,
    required this.eventId,
    required this.participantPhone,
  });

  @override
  State<SecretFriendScreen> createState() => _SecretFriendScreenState();
}

class _SecretFriendScreenState extends State<SecretFriendScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere((e) => e.id == widget.eventId);
        final secretFriend = event.getSecretFriend(widget.participantPhone);

        return Scaffold(
          body: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const GiftLoopAppBar(title: 'Seu Amigo Secreto'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // ── Card Amigo Secreto ─────────────────────
                          _SecretRevealCard(
                            secretFriend: secretFriend,
                            revealed: _revealed,
                            onReveal: () => setState(() => _revealed = true),
                          ),

                          const SizedBox(height: 16),

                          // ── Aviso ─────────────────────────────────
                          if (_revealed)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.pinkPastel.withValues(alpha: 0.2),
                                    AppTheme.lilac.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.pinkPastel.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text('🤫', style: TextStyle(fontSize: 24)),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Não conte para ninguém!\nGuarde esse segredo com carinho.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 24),

                          // ── Ações ─────────────────────────────────
                          if (_revealed) ...[
                            GradientButton(
                              text: '🎁 Cadastrar meu presente',
                              gradient: AppTheme.pinkGradient,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddGiftScreen(
                                    eventId: widget.eventId,
                                    participantPhone: widget.participantPhone,
                                  ),
                                ),
                              ),
                            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 14),

                            GradientButton(
                              text: '👀 Ver lista de presentes do grupo',
                              gradient: AppTheme.blueGradient,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GroupGiftsScreen(
                                    eventId: widget.eventId,
                                  ),
                                ),
                              ),
                            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
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

class _SecretRevealCard extends StatelessWidget {
  final Participant? secretFriend;
  final bool revealed;
  final VoidCallback onReveal;

  const _SecretRevealCard({
    this.secretFriend,
    required this.revealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          // Avatar
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: revealed ? AppTheme.pinkGradient : AppTheme.blueGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (revealed ? AppTheme.pinkPastel : AppTheme.babyBlue)
                      .withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: revealed
                  ? Text(
                      secretFriend?.name.isNotEmpty == true
                          ? secretFriend!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Nunito',
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
            ),
          ),

          const SizedBox(height: 16),

          if (!revealed) ...[
            const Text(
              'Seu amigo secreto está esperando!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.deepText,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Toque no botão para revelar quem você tirou no sorteio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.subText,
                fontFamily: 'Nunito',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: '🎉 Revelar amigo secreto',
              gradient: AppTheme.primaryGradient,
              onPressed: onReveal,
            ),
          ] else ...[
            const Text(
              'Você tirou...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subText,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                secretFriend?.name ?? 'Desconhecido',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5))
                .then()
                .shimmer(duration: 1000.ms, color: AppTheme.pinkPastel),
          ],
        ],
      ),
    );
  }
}