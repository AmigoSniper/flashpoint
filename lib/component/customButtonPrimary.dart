import 'package:flutter/material.dart';

class customButtonPrimary extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final AlignmentGeometry? alignment;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final LinearGradient? gradient;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const customButtonPrimary({
    super.key,
    required this.onPressed,
    required this.child,
    this.alignment,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.decoration,
    this.gradient,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          alignment: alignment,
          height: height,
          width: width,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xff0241C1),
                Color(0xff175DEC),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child),
    );
  }
}
