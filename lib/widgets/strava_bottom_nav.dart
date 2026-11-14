import 'package:flutter/material.dart';

import '../theme/stride_theme.dart';

class StravaBottomNav extends StatelessWidget {
  const StravaBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StravaColors.white,
        border: Border(top: BorderSide(color: StravaColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                children: [
                  _item(0, Icons.home_outlined, Icons.home, 'Home'),
                  _item(1, Icons.map_outlined, Icons.map, 'Maps'),
                  const Expanded(child: SizedBox()),
                  _item(3, Icons.groups_outlined, Icons.groups, 'Groups'),
                  _item(4, Icons.person_outline, Icons.person, 'You'),
                ],
              ),
              Positioned(
                top: -18,
                child: _recordButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData outline, IconData filled, String label) {
    final selected = index == i;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? filled : outline,
              size: 22,
              color: selected ? StravaColors.orange : StravaColors.muted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? StravaColors.orange : StravaColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordButton() {
    final selected = index == 2;
    return GestureDetector(
      onTap: () => onChanged(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: StravaColors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: StravaColors.orange.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: StravaColors.white, width: 3),
            ),
            child: const Icon(Icons.circle, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 2),
          Text(
            'Record',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: selected ? StravaColors.orange : StravaColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
