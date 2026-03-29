// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/join_event_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../services/pin_service.dart';
import '../../services/pin_access_screen.dart';
import 'event_access_screen.dart';

class JoinEventScreen extends StatefulWidget {
  const JoinEventScreen({super.key});

  @override
  State<JoinEventScreen> createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _access() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<EventProvider>();
      final event = await provider.getEventByCode(_codeCtrl.text.trim());

      if (event == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento não encontrado. Verifique o código.'),
            ),
          );
        }
        return;
      }

      // Garante que o evento está no cache do provider
      // para que EventAccessScreen consiga exibi-lo
      provider.cacheEvent(event);

      // Verifica se o telefone está cadastrado no evento
      final phone = _phoneCtrl.text.trim();
      final participant = event.participants
          .where((p) => p.phone == phone)
          .firstOrNull;

      if (participant == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Telefone não encontrado neste evento.\nVerifique com o organizador.'),
            ),
          );
        }
        return;
      }

      // Verifica sessão local — se válida, entra direto sem pedir PIN
      final hasSession = await PinService.hasValidSession(event.id, phone);
      if (hasSession && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventAccessScreen(
              eventId: event.id,
              participantPhone: phone,
            ),
          ),
        );
        return;
      }

      // Sem sessão — abre tela de PIN (criar ou verificar)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PinAccessScreen(
              eventId: event.id,
              phone: phone,
              onVerified: (verifiedPhone) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventAccessScreen(
                      eventId: event.id,
                      participantPhone: verifiedPhone,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const GiftLoopAppBar(title: 'Entrar no Evento'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // ── Ícone ─────────────────────────────────────
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.blueGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.babyBlue.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.card_giftcard_rounded,
                              color: Colors.white, size: 50),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Acessar dinâmica',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.deepText,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Use o código enviado pelo organizador\npara encontrar o evento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.subText,
                            fontFamily: 'Nunito',
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        GlassCard(
                          child: Column(
                            children: [
                              GiftLoopTextField(
                                label: 'Código do evento',
                                hint: 'Ex: ABC123',
                                controller: _codeCtrl,
                                prefixIcon: Icons.tag_rounded,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Informe o código'
                                    : null,
                              ),
                              GiftLoopTextField(
                                label: 'Seu telefone (WhatsApp)',
                                hint: '(11) 99999-9999',
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Informe seu telefone'
                                    : null,
                              ),
                              GradientButton(
                                text: 'Entrar no evento',
                                gradient: AppTheme.blueGradient,
                                icon: Icons.login_rounded,
                                onPressed: _access,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Explicação do PIN ──────────────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.babyBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.babyBlue.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🔐', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Na primeira vez você cria um PIN de 4 dígitos. Nas próximas entradas, o PIN não será solicitado por 30 dias neste dispositivo.',
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
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.pinkPastel.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.pinkPastel.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text('💡', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'O código foi enviado pelo organizador via WhatsApp.',
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
                        ),
                      ],
                    ),
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