// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/home_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/widgets.dart';
import '../services/auth_service.dart';
import 'auth/admin_login_screen.dart';
import 'admin/my_events_screen.dart';
import 'admin/create_event_screen.dart';
import 'participant/join_event_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleCreateEvent(BuildContext context) {
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Consumer<AuthService>(
            builder: (context, auth, _) {
              return auth.isLoggedIn
                  ? _AdminDashboard(
                      auth: auth,
                      onCreateEvent: () => _handleCreateEvent(context),
                    )
                  : _GuestLanding(
                      onCreateEvent: () => _handleCreateEvent(context),
                    );
            },
          ),
        ),
      ),
    );
  }
}

// ── Dashboard do Admin ────────────────────────────────────────────────────────

class _AdminDashboard extends StatelessWidget {
  final AuthService auth;
  final VoidCallback onCreateEvent;
  const _AdminDashboard({required this.auth, required this.onCreateEvent});

  @override
  Widget build(BuildContext context) {
    final firstName = (auth.currentUser?.displayName ?? 'Admin')
        .split(' ')
        .first;
    final email = auth.currentUser?.email ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── Header: logo pequena + saudação + logout ─────────────
          Row(
            children: [
              // Mini logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lilac.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎁',
                      style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // Saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepText,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.subText,
                          fontFamily: 'Nunito',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Sobre
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.subText.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.subText.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 18, color: AppTheme.subText),
                ),
                tooltip: 'Sobre',
              ),
              const SizedBox(width: 2),
              // Logout
              IconButton(
                onPressed: () => auth.signOut(),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.subText.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.subText.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      size: 18, color: AppTheme.subText),
                ),
                tooltip: 'Sair',
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 32),

          // ── Título do painel ──────────────────────────────────────
          const Text(
            'O que vamos fazer\nhoje? 🎉',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.deepText,
              height: 1.2,
              fontFamily: 'Nunito',
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 28),

          // ── Cards de ação ─────────────────────────────────────────
          _ActionCard(
            emoji: '✨',
            title: 'Criar nova dinâmica',
            description: 'Organize um novo amigo oculto e convide participantes.',
            gradient: AppTheme.pinkGradient,
            onTap: onCreateEvent,
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          _ActionCard(
            emoji: '📋',
            title: 'Meus eventos',
            description: 'Gerencie suas dinâmicas, veja participantes e resultados.',
            gradient: AppTheme.primaryGradient,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyEventsScreen())),
          ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          _ActionCard(
            emoji: '🔑',
            title: 'Entrar com código',
            description: 'Acesse um evento como participante usando o código.',
            gradient: AppTheme.blueGradient,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JoinEventScreen())),
          ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const Spacer(),

          // ── Footer ────────────────────────────────────────────────
          Center(
            child: const Text(
              'GiftLoop • Amigo Oculto',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.subText,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            ).animate(delay: 500.ms).fadeIn(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Card de ação ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lilac.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            // Ícone com gradiente
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lilac.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepText,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.subText,
                      fontFamily: 'Nunito',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.subText),
          ],
        ),
      ),
    );
  }
}

// ── Landing do visitante ──────────────────────────────────────────────────────

class _GuestLanding extends StatelessWidget {
  final VoidCallback onCreateEvent;
  const _GuestLanding({required this.onCreateEvent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 60),

          _LogoSection()
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(begin: -0.2, end: 0),

          const SizedBox(height: 40),

          const Text(
            'O amigo oculto\nmais divertido! 🎁',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.deepText,
              height: 1.2,
              fontFamily: 'Nunito',
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 8),

          const Text(
            'Crie e gerencie sua dinâmica\nde forma simples e encantadora',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.subText,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontFamily: 'Nunito',
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 600.ms),

          const Spacer(),

          GradientButton(
            text: '✨ Criar nova dinâmica',
            gradient: AppTheme.pinkGradient,
            icon: Icons.celebration_rounded,
            onPressed: onCreateEvent,
          ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 14),

          GradientButton(
            text: '🔑 Entrar com código',
            gradient: AppTheme.blueGradient,
            icon: Icons.key_rounded,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JoinEventScreen())),
          ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 40),

          const Text(
            'GiftLoop • Amigo Oculto',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.subText,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
            ),
          ).animate(delay: 600.ms).fadeIn(),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
            child: const Text(
              'Sobre o app',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.lilac,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.lilac,
              ),
            ),
          ).animate(delay: 650.ms).fadeIn(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Logo Section ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lilac.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Center(child: _InfinityGiftIcon()),
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Gift',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.pinkPastel,
                  fontFamily: 'Nunito',
                ),
              ),
              TextSpan(
                text: 'Loop',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.babyBlue,
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

// ── Infinity Gift Icon ────────────────────────────────────────────────────────

class _InfinityGiftIcon extends StatelessWidget {
  const _InfinityGiftIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(72, 56),
      painter: _InfinityPainter(),
    );
  }
}

class _InfinityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.9);

    final cx = size.width / 2;
    final cy = size.height / 2 + 4;
    final r = size.height * 0.28;

    final path = Path();
    path.moveTo(cx, cy);
    path.cubicTo(cx - r * 0.5, cy - r * 1.5, cx - r * 2.5, cy - r * 1.5, cx - r * 2, cy);
    path.cubicTo(cx - r * 1.5, cy + r * 1.5, cx + r * 0.5, cy + r * 1.5, cx, cy);
    path.cubicTo(cx - r * 0.5, cy - r * 1.5, cx + r * 1.5, cy - r * 1.5, cx + r * 2, cy);
    path.cubicTo(cx + r * 2.5, cy + r * 1.5, cx + r * 0.5, cy + r * 1.5, cx, cy);
    canvas.drawPath(path, paint);

    final bowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy - r * 0.2), Offset(cx, cy - r * 1.8), bowPaint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - r * 0.5, cy - r * 1.6), width: r, height: r * 0.8),
      0, 3.14, false, bowPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + r * 0.5, cy - r * 1.6), width: r, height: r * 0.8),
      0, -3.14, false, bowPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}