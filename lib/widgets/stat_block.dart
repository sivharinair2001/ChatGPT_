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
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : align == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: StrideColors.stone,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: align,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
        ),
      ],
    );
  }
}
