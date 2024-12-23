import 'package:flutter/material.dart';

class CustombuttonColor extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final AlignmentGeometry? alignment;
  final double? height;
  final double? width;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final LinearGradient? gradient;
  final BoxConstraints? constraints;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  CustombuttonColor(
      {required this.onPressed,
      required this.child,
      this.alignment,
      this.width,
      this.height,
      this.padding,
      this.margin,
      this.decoration,
      this.gradient,
      this.color,
      this.borderRadius,
      this.constraints,
      this.border});
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
          constraints: constraints,
          decoration: BoxDecoration(
            border: border,
            color: color,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          child: child),
    );
  }
}
