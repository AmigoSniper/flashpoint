import 'package:flutter/material.dart';

class Searchbar extends StatelessWidget {
  final String? hintText;
  final EdgeInsets? margin;
  final double? height;
  final Function(String) onChanged;
  final TextEditingController controller;
  final FocusNode? focus;
  const Searchbar(
      {super.key,
      required this.onChanged,
      required this.controller,
      this.hintText,
      this.margin,
      this.height,
      this.focus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFFA2A2A2),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF09090B)),
              controller: controller,
              focusNode: focus,
              onTapOutside: (event) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFFA2A2A2)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0)),
            ),
          ),
        ],
      ),
    );
  }
}
