import 'package:flutter/material.dart';

class Filterchip extends StatelessWidget {
  final bool selected;
  final Function(bool) onSelected;
  final Widget child;
  const Filterchip(
      {super.key,
      required this.selected,
      required this.child,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      backgroundColor: const Color(0xFFFFFFFF),
      selectedColor: const Color(0xFF2E6CE9),
      side: BorderSide.none,
      showCheckmark: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100))),
      label: Container(alignment: Alignment.center, height: 18, child: child),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
