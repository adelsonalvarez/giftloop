// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/services/widgets.dart
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Constante de largura máxima web ──────────────────────────────────────────
// Em telas maiores que este valor o conteúdo é centralizado com esta largura,
// replicando a experiência do app mobile no browser.
const double kWebMaxWidth = 480.0;

// ── GradientButton ───────────────────────────────────────────────────────────

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double? width;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppTheme.pinkGradient,
    this.width,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? gradient
              : const LinearGradient(
                  colors: [Color(0xFFDDD0EE), Color(0xFFDDD0EE)],
                ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppTheme.lilac.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: AppTheme.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── GiftLoopAppBar ───────────────────────────────────────────────────────────

class GiftLoopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const GiftLoopAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lilac.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppTheme.deepText,
                ),
              ),
            )
          : null,
      title: ShaderMask(
        shaderCallback: (bounds) =>
            AppTheme.primaryGradient.createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

// ── GlassCard ────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lilac.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

// ── GiftLoopTextField ────────────────────────────────────────────────────────

class GiftLoopTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  const GiftLoopTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.subText,
            letterSpacing: 0.8,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepText,
            fontFamily: 'Nunito',
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.lilac, size: 20)
                : null,
            suffix: suffix,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── BubbleBackground — com wrapper responsivo para web ───────────────────────
// No mobile: ocupa tela inteira normalmente.
// No web/desktop: centraliza o conteúdo em até kWebMaxWidth com sombra lateral,
// simulando a experiência do app mobile no browser.

class BubbleBackground extends StatelessWidget {
  final Widget child;

  const BubbleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = kIsWeb && screenWidth > kWebMaxWidth;

    return Stack(
      children: [
        // Gradient de fundo — sempre ocupa a tela toda
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        ),

        // Bolhas decorativas
        Positioned(
          top: -60,
          right: isWide ? (screenWidth - kWebMaxWidth) / 2 - 40 : -40,
          child: _blur(140, AppTheme.pinkPastel.withValues(alpha: 0.35)),
        ),
        Positioned(
          top: 200,
          left: isWide ? (screenWidth - kWebMaxWidth) / 2 - 60 : -60,
          child: _blur(120, AppTheme.babyBlue.withValues(alpha: 0.3)),
        ),
        Positioned(
          bottom: 100,
          right: isWide ? (screenWidth - kWebMaxWidth) / 2 - 30 : -30,
          child: _blur(100, AppTheme.lilac.withValues(alpha: 0.25)),
        ),

        // Conteúdo — centralizado e limitado em largura no web
        if (isWide)
          Center(
            child: Container(
              width: kWebMaxWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lilac.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 0),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          )
        else
          child,
      ],
    );
  }

  Widget _blur(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ── Chip de status ───────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          fontFamily: 'Nunito',
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}