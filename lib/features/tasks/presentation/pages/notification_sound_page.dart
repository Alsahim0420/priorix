import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../cubit/task_cubit.dart';

class NotificationSoundPage extends StatefulWidget {
  const NotificationSoundPage({super.key});

  @override
  State<NotificationSoundPage> createState() => _NotificationSoundPageState();
}

class _NotificationSoundPageState extends State<NotificationSoundPage> {
  final _player = AudioPlayer();
  NotificationSound? _playing;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _select(NotificationSound sound) async {
    HapticFeedback.selectionClick();
    final settingsCubit = context.read<SettingsCubit>();
    final taskCubit = context.read<TaskCubit>();
    await _preview(sound);
    if (settingsCubit.state.settings.notificationSound == sound) return;
    await settingsCubit.setNotificationSound(sound);
    // Pending alerts were scheduled with the previous sound.
    await taskCubit.syncAllReminders();
  }

  Future<void> _preview(NotificationSound sound) async {
    await _player.stop();
    final asset = sound.assetPath;
    if (asset == null) {
      setState(() => _playing = null);
      return;
    }
    setState(() => _playing = sound);
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {
      if (mounted) setState(() => _playing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final settings = state.settings;
              final sounds = NotificationSound.values;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Volver',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const PageHeader(
                        overline: 'Notificaciones',
                        title: 'Sonido de alerta',
                        subtitle:
                            'Toca un sonido para escucharlo. Se aplica a todas tus alertas.',
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            children: [
                              for (var i = 0; i < sounds.length; i++) ...[
                                _SoundTile(
                                  sound: sounds[i],
                                  selected:
                                      sounds[i] == settings.notificationSound,
                                  playing: sounds[i] == _playing,
                                  onTap: () => _select(sounds[i]),
                                ),
                                if (i != sounds.length - 1)
                                  const Divider(indent: 66, endIndent: 0),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PButton(
                        label: 'Probar notificación',
                        icon: Icons.notifications_active_outlined,
                        variant: PButtonVariant.secondary,
                        onPressed: settings.notificationsEnabled
                            ? () => context
                                  .read<SettingsCubit>()
                                  .sendTestNotification()
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                        child: Text(
                          settings.notificationsEnabled
                              ? 'Envía una alerta real ahora para oírla como llegará. Si el dispositivo está en silencio no sonará.'
                              : 'Activa las alertas de vencimiento para enviar una prueba.',
                          style: context.text.bodySmall?.copyWith(
                            color: context.palette.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.sound,
    required this.selected,
    required this.playing,
    required this.onTap,
  });

  final NotificationSound sound;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isSystem = sound == NotificationSound.system;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: playing ? p.accent : p.surfaceHigh,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isSystem
                      ? Icons.smartphone_rounded
                      : playing
                      ? Icons.graphic_eq_rounded
                      : Icons.play_arrow_rounded,
                  size: 18,
                  color: playing ? p.onAccent : p.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sound.label, style: context.text.titleSmall),
                    if (isSystem) ...[
                      const SizedBox(height: 2),
                      Text(
                        'El tono configurado en tu dispositivo',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1 : 0,
                child: Icon(Icons.check_rounded, color: p.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
