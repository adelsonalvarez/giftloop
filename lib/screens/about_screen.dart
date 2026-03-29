// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/about_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const GiftLoopAppBar(title: 'Sobre'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(
                    children: [

                      // ── Logo + nome + versão ───────────────────────────
                      _LogoHeader()
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: -0.2, end: 0),

                      const SizedBox(height: 28),

                      // ── Descrição ──────────────────────────────────────
                      const GlassCard(
                        child: Text(
                          'O GiftLoop é um aplicativo para organizar dinâmicas de amigo oculto de forma simples, segura e encantadora. Cada participante acessa o resultado com um PIN pessoal criado por ele mesmo — nem o organizador sabe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.subText,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

                      const SizedBox(height: 16),

                      // ── Tecnologias ────────────────────────────────────
                      const _Section(
                        title: '🛠️ Tecnologias',
                        delay: 150,
                        child: Column(
                          children: [
                            _TechRow('Flutter', 'Framework multiplataforma', Icons.phone_android_rounded, AppTheme.babyBlue),
                            _TechRow('Firebase', 'Auth + Firestore + Hosting', Icons.cloud_rounded, AppTheme.pinkPastel),
                            _TechRow('Provider', 'Gerenciamento de estado MVVM', Icons.account_tree_rounded, AppTheme.lilac),
                            _TechRow('SHA-256', 'Hash seguro do PIN', Icons.lock_rounded, Color(0xFF6DBB7E)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Desenvolvedor ──────────────────────────────────
                      _Section(
                        title: '👨‍💻 Desenvolvedor',
                        delay: 200,
                        child: Column(
                          children: [
                            const _InfoTile(
                              icon: Icons.person_rounded,
                              label: 'Adelson Alvarez',
                              subtitle: 'Bacharel em Sistemas de Informação — UNISUL',
                            ),
                            const SizedBox(height: 10),
                            const _InfoTile(
                              icon: Icons.school_rounded,
                              label: 'Pós-graduação',
                              subtitle: 'Desenvolvimento de Aplicativos Móveis — PUC/PR (2024–2026)',
                            ),
                            const SizedBox(height: 12),
                            // GitHub
                            _LinkButton(
                              icon: Icons.code_rounded,
                              label: 'github.com/adelsonalvarez/giftloop',
                              color: AppTheme.deepText,
                              bgColor: AppTheme.divider.withValues(alpha: 0.5),
                              onTap: () => _openUrl(
                                  'https://github.com/adelsonalvarez/giftloop'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Projeto acadêmico ──────────────────────────────
                      const _Section(
                        title: '🎓 Projeto Acadêmico',
                        delay: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoTile(
                              icon: Icons.account_balance_rounded,
                              label: 'Curso',
                              subtitle: 'Pós-Graduação em Desenvolvimento de Aplicativos Móveis — PUC/PR',
                            ),
                            SizedBox(height: 10),
                            _InfoTile(
                              icon: Icons.menu_book_rounded,
                              label: 'Disciplina',
                              subtitle: 'Desenvolvimento Mobile Profissional',
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Este aplicativo foi desenvolvido como uma tarefa prática que coloca em prática os conceitos e técnicas ensinados ao longo da disciplina, entre eles:',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.subText,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 12),
                            _BulletItem('Clean Code'),
                            _BulletItem('Arquitetura de Software'),
                            _BulletItem('Injeção de Dependência'),
                            _BulletItem('Testes Unitários'),
                            _BulletItem('Design Patterns'),
                            _BulletItem('Interface com UI/UX'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Licença + versão ───────────────────────────────
                      _Section(
                        title: '📄 Licença',
                        delay: 300,
                        child: Column(
                          children: [
                            const Text(
                              'Distribuído sob a licença MIT. Uso livre para fins acadêmicos e pessoais.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.subText,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _LinkButton(
                              icon: Icons.gavel_rounded,
                              label: 'Ver licença MIT no GitHub',
                              color: AppTheme.lilac,
                              bgColor: AppTheme.lilac.withValues(alpha: 0.08),
                              onTap: () => _openUrl(
                                  'https://github.com/adelsonalvarez/giftloop/blob/main/LICENSE'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Footer ─────────────────────────────────────────
                      Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: const Text(
                              'GiftLoop',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Versão 1.0.0 • © 2026 Adelson Alvarez',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.subText,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ).animate(delay: 350.ms).fadeIn(duration: 500.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo Header ───────────────────────────────────────────────────────────────

class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lilac.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎁', style: TextStyle(fontSize: 42)),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Gift',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.pinkPastel,
                  fontFamily: 'Nunito',
                ),
              ),
              TextSpan(
                text: 'Loop',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.babyBlue,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lilac.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.lilac.withValues(alpha: 0.25)),
          ),
          child: const Text(
            'Versão 1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.lilac,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Seção com título ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final int delay;

  const _Section({
    required this.title,
    required this.child,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppTheme.deepText,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(child: child),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }
}

// ── Tech Row ──────────────────────────────────────────────────────────────────

class _TechRow extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const _TechRow(this.name, this.description, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
                Text(name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepText,
                      fontFamily: 'Nunito',
                    )),
                Text(description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.subText,
                      fontFamily: 'Nunito',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.subtitle,
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
            color: AppTheme.lilac.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.lilac, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepText,
                    fontFamily: 'Nunito',
                  )),
              Text(subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.subText,
                    fontFamily: 'Nunito',
                    height: 1.4,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bullet Item ───────────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.deepText,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Nunito',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: color.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}