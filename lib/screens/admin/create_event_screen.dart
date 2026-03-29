// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/admin/create_event_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/auth_service.dart';
import '../../services/event_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/participant.dart';
import 'participants_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _adminPhoneCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _adminJoinsAsDraw = true;

  /// Nome do admin vem do Google Account — não há campo de texto para ele.
  String get _adminName {
    final displayName = context.read<AuthService>().currentUser?.displayName;
    return displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : 'Organizador';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _messageCtrl.dispose();
    _adminPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.lilac,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _advance() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data do evento')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<EventProvider>();
      final event = await provider.createEvent(
        name: _nameCtrl.text.trim(),
        date: _selectedDate!,
        location: _locationCtrl.text.trim(),
        message: _messageCtrl.text.trim().isEmpty
            ? null
            : _messageCtrl.text.trim(),
        adminPhone: _adminPhoneCtrl.text.trim(),
      );

      if (_adminJoinsAsDraw) {
        final adminParticipant = Participant(
          id: const Uuid().v4(),
          name: _adminName,
          phone: _adminPhoneCtrl.text.trim(),
        );
        await provider.addParticipant(event.id, adminParticipant);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParticipantsScreen(eventId: event.id),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminName = context.watch<AuthService>().currentUser?.displayName
            ?.split(' ')
            .first ??
        'Organizador';

    return Scaffold(
      body: BubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const GiftLoopAppBar(title: 'Criar Dinâmica'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Header ────────────────────────────────────
                        GlassCard(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.pinkGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.celebration_rounded,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Novo Evento',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: AppTheme.deepText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    Text(
                                      'Preencha os dados da dinâmica',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.subText,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Campos do evento ──────────────────────────
                        GiftLoopTextField(
                          label: 'Nome do evento',
                          hint: 'Ex: Amigo Secreto da Família 🎄',
                          controller: _nameCtrl,
                          prefixIcon: Icons.celebration_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Informe o nome do evento'
                              : null,
                        ),

                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: GiftLoopTextField(
                              label: 'Data do evento',
                              hint: 'Toque para selecionar',
                              controller: TextEditingController(
                                text: _selectedDate != null
                                    ? DateFormat(
                                            "dd 'de' MMMM 'de' yyyy", 'pt_BR')
                                        .format(_selectedDate!)
                                    : '',
                              ),
                              prefixIcon: Icons.calendar_today_rounded,
                              readOnly: true,
                            ),
                          ),
                        ),

                        GiftLoopTextField(
                          label: 'Local',
                          hint: 'Ex: Casa da Vovó, Sala de Reuniões...',
                          controller: _locationCtrl,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Informe o local'
                              : null,
                        ),

                        GiftLoopTextField(
                          label: 'Mensagem opcional',
                          hint: 'Uma mensagem especial para os participantes ✨',
                          controller: _messageCtrl,
                          maxLines: 3,
                          prefixIcon: Icons.message_outlined,
                        ),

                        const Divider(color: AppTheme.divider, height: 8),
                        const SizedBox(height: 8),

                        // ── Dados do Admin (Google) ────────────────────
                        // Nome vem automaticamente da conta Google.
                        // Telefone ainda é preenchido manualmente — o Google
                        // não expõe o número do usuário via Sign-In.
                        GlassCard(
                          color: AppTheme.lilac.withValues(alpha: 0.08),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: AppTheme.lilac,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Seus dados (Administrador)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppTheme.deepText,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Nome — somente leitura, vem do Google
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.lilac.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color:
                                          AppTheme.lilac.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_rounded,
                                        color: AppTheme.lilac, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Seu nome',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.subText,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            adminName,
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
                                    const Icon(Icons.verified_rounded,
                                        color: AppTheme.subText, size: 16),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Telefone — preenchimento manual
                              GiftLoopTextField(
                                label: 'Seu telefone (WhatsApp)',
                                hint: '(11) 99999-9999',
                                controller: _adminPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Informe seu telefone';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Opção: admin participa do sorteio ─────────
                        GlassCard(
                          color: _adminJoinsAsDraw
                              ? AppTheme.pinkPastel.withValues(alpha: 0.12)
                              : AppTheme.divider.withValues(alpha: 0.3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(
                              () => _adminJoinsAsDraw = !_adminJoinsAsDraw,
                            ),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _adminJoinsAsDraw,
                                    onChanged: (v) => setState(
                                      () => _adminJoinsAsDraw = v ?? true,
                                    ),
                                    activeColor: AppTheme.lilac,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Quero participar do sorteio',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppTheme.deepText,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      Text(
                                        'Você também será incluído no ciclo do amigo secreto',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.subText,
                                          fontFamily: 'Nunito',
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _adminJoinsAsDraw ? '🎉' : '👀',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        GradientButton(
                          text: 'Avançar para Participantes',
                          gradient: AppTheme.pinkGradient,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _advance,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 32),
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