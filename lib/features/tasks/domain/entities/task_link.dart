import 'package:flutter/material.dart';

/// Where a link attached to a task points. Apple Notes and Freeform expose no
/// API, so tasks keep their iCloud share links and hand them to the system.
enum TaskLinkKind { notes, freeform, web }

extension TaskLinkKindX on TaskLinkKind {
  static TaskLinkKind of(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return TaskLinkKind.web;
    final path = uri.path.toLowerCase();
    if (uri.scheme == 'mobilenotes' || path.startsWith('/notes')) {
      return TaskLinkKind.notes;
    }
    if (uri.scheme == 'freeform' || path.startsWith('/freeform')) {
      return TaskLinkKind.freeform;
    }
    return TaskLinkKind.web;
  }

  String get title => switch (this) {
    TaskLinkKind.notes => 'Nota',
    TaskLinkKind.freeform => 'Tablero de Freeform',
    TaskLinkKind.web => 'Enlace',
  };

  IconData get icon => switch (this) {
    TaskLinkKind.notes => Icons.sticky_note_2_outlined,
    TaskLinkKind.freeform => Icons.gesture_rounded,
    TaskLinkKind.web => Icons.link_rounded,
  };
}

/// The item's name when the link carries one: iCloud share links end in
/// `#Title_With_Underscores`.
String? taskLinkName(String url) {
  final fragment = Uri.tryParse(url)?.fragment ?? '';
  if (fragment.isEmpty) return null;
  final String decoded;
  try {
    decoded = Uri.decodeComponent(fragment);
  } on ArgumentError {
    return null;
  }
  final name = decoded.replaceAll('_', ' ').trim();
  return name.isEmpty ? null : name;
}

/// Normalizes user input into a launchable URL, or null if it isn't one.
/// Bare iCloud links like `icloud.com/notes/…` get an https scheme.
String? normalizeTaskLink(String input) {
  var value = input.trim();
  if (value.isEmpty) return null;
  if (!value.contains('://') && !value.startsWith('mobilenotes:')) {
    value = 'https://$value';
  }
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme.isEmpty) return null;
  if ((uri.scheme == 'http' || uri.scheme == 'https') &&
      !uri.host.contains('.')) {
    return null;
  }
  return value;
}
