// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/screens/participant/add_gift_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/widgets.dart';
import '../../services/event_provider.dart';
import '../../models/gift.dart';

class AddGiftScreen extends StatefulWidget {
  final String eventId;
  final String participantPhone;

  const AddGiftScreen({
    super.key,
    required this.eventId,
    required this.participantPhone,
  });

  @override
  State<AddGiftScreen> createState() => _AddGiftScreenState();
}

class _AddGiftScreenState extends State<AddGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final gift = Gift(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      await context.read<EventProvider>().addGift(
            widget.eventId,
            widget.participantPhone,
            gift,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presente cadastrado com sucesso! 🎁')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _optOut() async {
    await context.read<EventProvider>().setOptedOut(
          widget.eventId,
          widget.participantPhone,
          true,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferência salva. O grupo saberá que você não cadastrou presentes.'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.events.firstWhere((e) => e.id == widget.eventId);
        final participant = event.participants.firstWhere(
          (p) => p.phone == widget.participantPhone,
        );

        return Scaffold(
          body: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const GiftLoopAppBar(title: 'Cadastrar Presente'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // ── Header ────────────────────────────────
                          GlassCard(
                            color: AppTheme.pinkPastel.withValues(alpha: 0.12),
                            child: const Row(
                              children: [
                                Text('🎀', style: TextStyle(fontSize: 40)),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'O que você quer ganhar?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: AppTheme.deepText,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Ajude seu amigo secreto com ideias!',
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

                          const SizedBox(height: 20),

                          // ── Lista existente ───────────────────────
                          if (participant.wishlist.isNotEmpty) ...[
                            _GiftList(
                              gifts: participant.wishlist,
                              eventId: widget.eventId,
                              participantPhone: widget.participantPhone,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Formulário ────────────────────────────
                          GlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    participant.wishlist.isEmpty
                                        ? 'Adicione seu primeiro presente'
                                        : 'Adicionar mais um presente',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.deepText,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GiftLoopTextField(
                                    label: 'Nome do presente',
                                    hint: 'Ex: Livro, Perfume, Jogo...',
                                    controller: _nameCtrl,
                                    prefixIcon: Icons.card_giftcard_rounded,
                                    validator: (v) => v == null || v.trim().isEmpty
                                        ? 'Informe o nome do presente'
                                        : null,
                                  ),
                                  GiftLoopTextField(
                                    label: 'Observações (opcional)',
                                    hint: 'Tamanho, cor, marca, faixa de preço...',
                                    controller: _notesCtrl,
                                    maxLines: 3,
                                    prefixIcon: Icons.notes_rounded,
                                  ),
                                  GradientButton(
                                    text: 'Salvar presente',
                                    gradient: AppTheme.pinkGradient,
                                    icon: Icons.save_rounded,
                                    onPressed: _save,
                                    isLoading: _isSaving,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Opt-out ───────────────────────────────
                          GlassCard(
                            color: AppTheme.divider.withValues(alpha: 0.5),
                            child: Column(
                              children: [
                                const Text(
                                  'Prefere não cadastrar presentes?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppTheme.deepText,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Isso ficará visível para o grupo (sem revelar seu nome).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.subText,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _optOut,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.subText,
                                    side: const BorderSide(color: AppTheme.divider, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text(
                                    'Não quero cadastrar',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class _GiftList extends StatelessWidget {
  final List<Gift> gifts;
  final String eventId;
  final String participantPhone;

  const _GiftList({
    required this.gifts,
    required this.eventId,
    required this.participantPhone,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seus presentes cadastrados',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.deepText,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          ...gifts.asMap().entries.map((entry) {
            final gift = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.softBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.lilac,
                      fontFamily: 'Nunito',
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
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<EventProvider>().removeGift(
                          eventId,
                          participantPhone,
                          gift.id,
                        ),
                    icon: Icon(Icons.close_rounded,
                        color: AppTheme.pinkPastel.withValues(alpha: 0.7), size: 18),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}