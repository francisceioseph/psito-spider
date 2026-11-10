import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

/// A short message on the table that fades away by itself. A new key shows
/// it again.
class TableNote extends StatefulWidget {
  const TableNote({super.key, required this.message, required this.color});

  static const showFor = Duration(milliseconds: 3200);

  final String message;
  final Color color;

  @override
  State<TableNote> createState() => _TableNoteState();
}

class _TableNoteState extends State<TableNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: TableNote.showFor,
  )..forward();

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: FadeTransition(
      opacity: TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 6),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 14),
      ]).animate(_life),
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 10),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.palette.onFelt, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
