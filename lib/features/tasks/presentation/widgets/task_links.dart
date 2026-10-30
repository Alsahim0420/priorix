import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/task_link.dart';
import '../task_actions.dart';

/// Linked Notes, Freeform boards and web pages. Tapping a row opens it; with
/// [onRemove] each row also gets a remove button (editor mode).
class TaskLinkList extends StatelessWidget {
  const TaskLinkList({super.key, required this.links, this.onRemove});

  final List<String> links;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          for (final (i, url) in links.indexed) ...[
            if (i > 0) const Divider(indent: 58),
            _LinkRow(
              url: url,
              onRemove: onRemove == null ? null : () => onRemove!(url),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.url, this.onRemove});

  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final kind = TaskLinkKindX.of(url);
    final uri = Uri.tryParse(url);
    final host = uri == null || uri.host.isEmpty ? url : uri.host;
    final name = taskLinkName(url);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => openTaskLink(context, url),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(kind.icon, size: 19, color: p.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? kind.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name == null ? host : kind.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: 'Quitar enlace',
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded, color: p.textTertiary),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: p.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact pill for task cards that opens a task's links without going
/// through the detail page: one link opens straight away, several show a menu.
class TaskLinkButton extends StatelessWidget {
  const TaskLinkButton({super.key, required this.links, this.dense = false});

  final List<String> links;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final single = links.length == 1;
    final kind = single ? TaskLinkKindX.of(links.first) : null;
    final label = single
        ? taskLinkName(links.first) ?? kind!.title
        : '${links.length} enlaces';
    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            kind?.icon ?? Icons.link_rounded,
            size: dense ? 11 : 13,
            color: p.accent,
          ),
          SizedBox(width: dense ? 4 : 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.accent,
                fontSize: dense ? 10.5 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: dense ? 2 : 3),
          Icon(
            single ? Icons.north_east_rounded : Icons.expand_more_rounded,
            size: dense ? 10 : 12,
            color: p.accent,
          ),
        ],
      ),
    );

    if (single) {
      return Semantics(
        button: true,
        label: 'Abrir $label',
        child: Pressable(
          onTap: () {
            HapticFeedback.selectionClick();
            openTaskLink(context, links.first);
          },
          child: pill,
        ),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Abrir enlace',
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      color: p.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.hairline),
      ),
      onOpened: HapticFeedback.selectionClick,
      onSelected: (url) => openTaskLink(context, url),
      itemBuilder: (_) => [
        for (final url in links)
          PopupMenuItem(
            value: url,
            child: Row(
              children: [
                Icon(TaskLinkKindX.of(url).icon, size: 18, color: p.accent),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    taskLinkName(url) ?? TaskLinkKindX.of(url).title,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: pill,
    );
  }
}

/// Inline composer for adding a link: collapsed it's a single row; open it
/// recognizes Notes / Freeform / web links live as the user pastes.
class TaskLinkComposer extends StatefulWidget {
  const TaskLinkComposer({
    super.key,
    required this.onAdd,
    this.existing = const [],
  });

  final ValueChanged<String> onAdd;
  final List<String> existing;

  @override
  State<TaskLinkComposer> createState() => _TaskLinkComposerState();
}

class _TaskLinkComposerState extends State<TaskLinkComposer> {
  final _url = TextEditingController();
  final _focus = FocusNode();
  bool _open = false;
  bool _showError = false;

  @override
  void dispose() {
    _url.dispose();
    _focus.dispose();
    super.dispose();
  }

  String? get _value => normalizeTaskLink(_url.text);

  bool get _duplicate => widget.existing.contains(_value);

  Future<void> _start() async {
    HapticFeedback.selectionClick();
    setState(() => _open = true);
    await _paste(silent: true);
    _focus.requestFocus();
  }

  Future<void> _paste({bool silent = false}) async {
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clip?.text?.trim() ?? '';
    if (!mounted || (silent && normalizeTaskLink(text) == null)) return;
    if (!silent) HapticFeedback.selectionClick();
    setState(() {
      _url.text = text;
      _url.selection = TextSelection.collapsed(offset: text.length);
      _showError = false;
    });
  }

  void _close() {
    _focus.unfocus();
    setState(() {
      _open = false;
      _showError = false;
      _url.clear();
    });
  }

  void _submit() {
    final value = _value;
    if (value == null || _duplicate) {
      HapticFeedback.heavyImpact();
      setState(() => _showError = true);
      return;
    }
    HapticFeedback.lightImpact();
    widget.onAdd(value);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _open ? _buildOpen(context) : _buildClosed(context),
      ),
    );
  }

  Widget _buildClosed(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      key: const ValueKey('closed'),
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: _start,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_link_rounded, size: 19, color: p.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vincular nota o tablero', style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Notas, Freeform o cualquier página web.',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.add_rounded, color: p.textTertiary),
        ],
      ),
    );
  }

  Widget _buildOpen(BuildContext context) {
    final p = context.palette;
    return ValueListenableBuilder(
      key: const ValueKey('open'),
      valueListenable: _url,
      builder: (context, _, _) {
        final value = _value;
        final kind = value == null ? null : TaskLinkKindX.of(value);
        final name = value == null ? null : taskLinkName(value);
        final error = !_showError
            ? null
            : value == null
            ? 'Eso no parece un enlace.'
            : _duplicate
            ? 'Este enlace ya está vinculado.'
            : null;

        return SurfaceCard(
          radius: 20,
          tint: p.accent,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kind == null
                          ? p.surfaceHigh
                          : p.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        kind?.icon ?? Icons.link_rounded,
                        key: ValueKey(kind),
                        size: 21,
                        color: kind == null ? p.textTertiary : p.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? kind?.title ?? 'Pega el enlace',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kind == null
                              ? 'Compartir → Copiar enlace en Notas o Freeform'
                              : name == null
                              ? 'Listo para vincular'
                              : kind.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancelar',
                    onPressed: _close,
                    icon: Icon(Icons.close_rounded, color: p.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
                decoration: BoxDecoration(
                  color: p.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: error != null
                        ? AppColors.danger.withValues(alpha: 0.6)
                        : p.hairline,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _url,
                        focusNode: _focus,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_showError) setState(() => _showError = false);
                        },
                        onSubmitted: (_) => _submit(),
                        style: context.text.bodyMedium?.copyWith(
                          color: p.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'icloud.com/freeform/…',
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    _Pill(
                      icon: Icons.content_paste_rounded,
                      label: 'Pegar',
                      onTap: _paste,
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: error == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          error,
                          style: context.text.bodySmall?.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final option in TaskLinkKind.values) ...[
                    _KindTag(kind: option, active: option == kind),
                    const SizedBox(width: 6),
                  ],
                  const Spacer(),
                  PButton(
                    label: 'Vincular',
                    icon: Icons.check_rounded,
                    compact: true,
                    expanded: false,
                    onPressed: value == null ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: p.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: p.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.text.labelMedium?.copyWith(color: p.accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lights up the source the pasted link was recognized as.
class _KindTag extends StatelessWidget {
  const _KindTag({required this.kind, required this.active});

  final TaskLinkKind kind;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: kind.title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? p.accent.withValues(alpha: 0.6) : p.hairline,
          ),
        ),
        child: Icon(
          kind.icon,
          size: 15,
          color: active ? p.accent : p.textTertiary,
        ),
      ),
    );
  }
}
