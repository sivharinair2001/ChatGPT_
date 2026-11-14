import 'package:flutter/material.dart';

import '../theme/stride_theme.dart';

class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.align = TextAlign.left,
  });

  final String label;
  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final cross = align == TextAlign.right
        ? CrossAxisAlignment.end
        : align == TextAlign.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: StravaColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: align,
          style: const TextStyle(
            color: StravaColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
