// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/admin/draw_result_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../home_screen.dart';

class DrawResultScreen extends StatefulWidget {
  final String eventId;

  const DrawResultScreen({super.key, required this.eventId});

  @override
  State<DrawResultScreen> createState() => _DrawResultScreenState();
}

class _DrawResultScreenState extends State<DrawResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _copyShareMessage(String eventId, String eventName) {
    final msg =
        '🎁 Você foi convidado para o amigo oculto: *$eventName*!\n\nUse o código *$eventId* para acessar.\n\nBaixe o GiftLoop e participe! 🎉';
    Clipboard.setData(ClipboardData(text: msg));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensagem copiada! Cole no WhatsApp 📱')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere((e) => e.id == widget.eventId);

        return Scaffold(
          body: BubbleBackground(
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      const GiftLoopAppBar(title: 'Sorteio Realizado!', showBack: false),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              // ── Success card ───────────────────────
                              GlassCard(
                                color: AppTheme.pinkPastel.withValues(alpha: 0.15),
                                child: Column(
                                  children: [
                                    const Text('🎉', style: TextStyle(fontSize: 56))
                                        .animate()
                                        .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
                                        .then()
                                        .shake(),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Sorteio concluído!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Todos os ${event.participants.length} participantes foram sorteados',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.subText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 200.ms).fadeIn().slideY(begin: -0.2, end: 0),

                              const SizedBox(height: 20),

                              // ── Código para compartilhar ───────────
                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.share_rounded, color: AppTheme.lilac, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Compartilhe com os participantes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppTheme.deepText,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Código do evento',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event.id,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 6,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    GradientButton(
                                      text: 'Compartilhar convite',
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                      ),
                                      icon: Icons.share_rounded,
                                      onPressed: () => _copyShareMessage(event.id, event.name),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

                              const SizedBox(height: 20),

                              // ── Confirmação de privacidade ─────────
                              GlassCard(
                                color: AppTheme.lilac.withValues(alpha: 0.08),
                                child: Column(
                                  children: [
                                    const Text('🔒', style: TextStyle(fontSize: 40))
                                        .animate(delay: 500.ms).fadeIn().scale(
                                          begin: const Offset(0.5, 0.5),
                                          end: const Offset(1, 1),
                                        ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Resultado protegido',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Cada participante descobre seu amigo secreto ao entrar no app com seu número. Ninguém — nem o organizador — pode ver o resultado dos outros.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.subText,
                                        fontFamily: 'Nunito',
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.babyBlue.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.babyBlue.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_rounded,
                                              color: Color(0xFF6DBB7E), size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${event.participants.length} participantes sorteados',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.deepText,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),

                              const SizedBox(height: 24),

                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  (route) => false,
                                ),
                                icon: const Icon(Icons.home_rounded),
                                label: const Text('Voltar ao início'),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    numberOfParticles: 30,
                    colors: const [
                      AppTheme.pinkPastel,
                      AppTheme.lilac,
                      AppTheme.babyBlue,
                      Colors.white,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}