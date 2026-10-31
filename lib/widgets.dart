import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Responsive-Helfer (Punkt 12).
class R {
  /// Wie viele Slides nebeneinander passen (Portrait → 1).
  static int columnsFor(double width, {double tile = 560, int max = 3}) =>
      math.max(1, math.min(max, width ~/ tile));

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 760;
}

/// Horizontale Scroll-Leiste für die breiten Tabellen (Punkt 3).
/// Die Tabelle selbst reagiert NICHT auf horizontale Wischgesten –
/// nur das Ziehen/Tippen dieser Leiste verschiebt sie. Dadurch führt
/// horizontales Wischen auf der Tabelle weiter zum PageView (andere Screens).
class HorizontalScroller extends StatefulWidget {
  final ScrollController controller;
  const HorizontalScroller({super.key, required this.controller});

  @override
  State<HorizontalScroller> createState() => _HorizontalScrollerState();
}

class _HorizontalScrollerState extends State<HorizontalScroller> {
  static const _trackH = 22.0;

  @override
  void initState() {
    super.initState();
    // Nach dem ersten Frame noch einmal bewerten – die Scroll-Metriken
    // kommen je nach Timing erst später an.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  /// Crash-sichere Metriken: In manchen Flutter-Versionen sind die Getter
  /// zwar non-nullable typisiert, werfen VOR dem ersten Layout aber selbst
  /// eine Null-Check-Exception (genau der Absturz, den wir gesehen haben).
  /// Deshalb: komplett hinter try/catch – im Zweifel Balken verstecken.
  ({double max, double viewport, double pixels})? _metrics() {
    final c = widget.controller;
    if (!c.hasClients) return null;
    try {
      return (
        max: c.position.maxScrollExtent,
        viewport: c.position.viewportDimension,
        pixels: c.position.pixels,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final m = _metrics();
        if (m == null || !(m.max > 0) || !(m.viewport > 0)) {
          return const SizedBox(height: 8);
        }
        final max = m.max;
        final viewport = m.viewport;
        final cur = m.pixels;
        return LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth - 32;
          if (!(w > 44)) return const SizedBox(height: 8);
          final content = viewport + max;
          final thumbW = math.max(44.0, w * viewport / content);
          final frac = (cur / max).clamp(0.0, 1.0);
          final thumbX = frac * (w - thumbW);

          void dragTo(double globalDx) {
            if (!widget.controller.hasClients) return;
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(Offset(globalDx, 0)).dx - 16;
            var t = (local - thumbW / 2) / (w - thumbW);
            if (!t.isFinite) return;
            t = t.clamp(0.0, 1.0);
            try {
              widget.controller.jumpTo(t * max);
            } catch (_) {}
          }

          return SizedBox(
            height: 30,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) => dragTo(d.globalPosition.dx),
              onHorizontalDragUpdate: (d) => dragTo(d.globalPosition.dx),
              onTapDown: (d) => dragTo(d.globalPosition.dx),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Stack(children: [
                  Positioned.fill(
                    top: (_trackH - 6) / 2,
                    bottom: (_trackH - 6) / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbX,
                    top: 0,
                    bottom: 0,
                    width: thumbW,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
      },
    );
  }
}