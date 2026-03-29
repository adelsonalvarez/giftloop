// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/pin_access_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../services/pin_service.dart';

/// Tela de acesso por PIN do participante.
///
/// Dois modos:
///   - [_Mode.create] → participante ainda não tem PIN — cria e confirma
///   - [_Mode.verify] → participante já tem PIN — digita para validar
///
/// Após acesso bem-sucedido chama [onVerified] com o telefone confirmado.
/// A sessão é salva localmente por 30 dias — o PIN não será pedido
/// novamente neste dispositivo durante esse período.
class PinAccessScreen extends StatefulWidget {
  final String eventId;
  final String phone;
  final void Function(String phone) onVerified;

  const PinAccessScreen({
    super.key,
    required this.eventId,
    required this.phone,
    required this.onVerified,
  });

  @override
  State<PinAccessScreen> createState() => _PinAccessScreenState();
}

enum _Mode { create, verify }

class _PinAccessScreenState extends State<PinAccessScreen> {
  _Mode _mode = _Mode.verify;
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false; // true quando está na etapa de confirmação do PIN
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detectMode();
  }

  Future<void> _detectMode() async {
    final provider = context.read<EventProvider>();
    final event = await provider.getEventByCode(widget.eventId);
    if (event == null) return;

    final participant = event.participants
        .where((p) => p.phone == widget.phone)
        .firstOrNull;

    if (participant?.pinHash == null) {
      setState(() => _mode = _Mode.create);
    } else {
      setState(() => _mode = _Mode.verify);
    }
  }

  void _onDigit(String digit) {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.length < 4) _pin += digit;
        if (_pin.length == 4 && _mode == _Mode.create) {
          // Vai para confirmação
          _isConfirming = true;
        } else if (_pin.length == 4 && _mode == _Mode.verify) {
          _verify();
        }
      } else {
        if (_confirmPin.length < 4) _confirmPin += digit;
        if (_confirmPin.length == 4) _createPin();
      }
    });
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Volta para o primeiro PIN
          _isConfirming = false;
          _pin = '';
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _createPin() async {
    if (_pin != _confirmPin) {
      setState(() {
        _error = 'Os PINs não coincidem. Tente novamente.';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<EventProvider>();
      final pinHash = PinService.hash(_pin, widget.phone);
      await provider.setParticipantPin(widget.eventId, widget.phone, pinHash);
      await PinService.saveSession(widget.eventId, widget.phone);
      widget.onVerified(widget.phone);
    } catch (e) {
      setState(() => _error = 'Erro ao salvar PIN. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<EventProvider>();
      final event = await provider.getEventByCode(widget.eventId);
      if (event == null) throw Exception('Evento não encontrado');

      final participant = event.participants
          .where((p) => p.phone == widget.phone)
          .firstOrNull;

      if (participant?.pinHash == null) {
        setState(() {
          _mode = _Mode.create;
          _pin = '';
          _isLoading = false;
        });
        return;
      }

      final valid = PinService.verify(_pin, widget.phone, participant!.pinHash!);
      if (valid) {
        await PinService.saveSession(widget.eventId, widget.phone);
        widget.onVerified(widget.phone);
      } else {
        setState(() {
          _error = 'PIN incorreto. Tente novamente.';
          _pin = '';
        });
      }
    } catch (e) {
      setState(() => _error = 'Erro ao verificar PIN.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _title {
    if (_mode == _Mode.create) {
      return _isConfirming ? 'Confirme seu PIN' : 'Crie seu PIN';
    }
    return 'Digite seu PIN';
  }

  String get _subtitle {
    if (_mode == _Mode.create) {
      return _isConfirming
          ? 'Digite o PIN novamente para confirmar'
          : 'Escolha 4 dígitos que só você saiba.\nVocê usará este PIN para acessar o evento.';
    }
    return 'Digite o PIN que você criou\npara acessar este evento.';
  }

  String get _currentPin => _isConfirming ? _confirmPin : _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const GiftLoopAppBar(title: 'Acesso ao Evento'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Ícone ─────────────────────────────────────
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
                        child: Icon(
                          _mode == _Mode.create
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(),

                      const SizedBox(height: 24),

                      // ── Título ────────────────────────────────────
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepText,
                          fontFamily: 'Nunito',
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 8),

                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.subText,
                          fontFamily: 'Nunito',
                          height: 1.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 40),

                      // ── Pontos do PIN ─────────────────────────────
                      _PinDots(filledCount: _currentPin.length),

                      // ── Erro ──────────────────────────────────────
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().shake(),
                      ],

                      const Spacer(),

                      // ── Teclado numérico ──────────────────────────
                      if (_isLoading)
                        const CircularProgressIndicator(color: AppTheme.lilac)
                      else
                        _NumPad(onDigit: _onDigit, onDelete: _onDelete),

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
  }
}

// ── PIN Dots ──────────────────────────────────────────────────────────────────

class _PinDots extends StatelessWidget {
  final int filledCount;
  const _PinDots({required this.filledCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: filled ? 20 : 16,
          height: filled ? 20 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: filled ? AppTheme.primaryGradient : null,
            color: filled ? null : AppTheme.divider,
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppTheme.lilac.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ── Teclado numérico ──────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  const _NumPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((d) {
            if (d.isEmpty) return const SizedBox(width: 80, height: 72);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (d == '⌫') {
                  onDelete();
                } else {
                  onDigit(d);
                }
              },
              child: Container(
                width: 80,
                height: 72,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: d == '⌫'
                      ? AppTheme.divider.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: d == '⌫'
                      ? const Icon(Icons.backspace_outlined,
                          color: AppTheme.subText, size: 22)
                      : Text(
                          d,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepText,
                            fontFamily: 'Nunito',
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}