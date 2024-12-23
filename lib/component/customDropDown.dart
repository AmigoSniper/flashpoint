import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Customdropdown extends StatelessWidget {
  final List<String> data;
  final String? selectValue;
  final void Function(String?)? onChanged;
  final String hintText;
  final double heightItem;
  final double? height;
  final double? width;
  final Color? colorHint;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;
  const Customdropdown(
      {super.key,
      required this.data,
      this.selectValue,
      required this.onChanged,
      required this.hintText,
      required this.heightItem,
      this.height,
      this.colorHint,
      this.width,
      this.padding,
      this.margin,
      this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width ?? double.infinity,
      alignment: alignment,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          iconStyleData: IconStyleData(
            icon: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'asset/image/arrow-down.svg',
                color: const Color(0xFFA8A8A8),
              ),
            ),
          ),
          hint: Text(
            hintText,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: colorHint ?? const Color(0xFFA2A2A2)),
          ),
          isExpanded: true,
          isDense: true,
          selectedItemBuilder: (context) {
            return data.map((String item) {
              return Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF18181B),
                ),
              );
            }).toList();
          },
          items: data.map((String item) {
            return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 12, top: 12),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(width: 1, color: Color(0xFFE1E1E1)))),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF717179),
                    ),
                  ),
                ));
          }).toList(),
          dropdownSearchData: const DropdownSearchData(),
          value: selectValue,
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 0),
            height: 40,
            width: 213,
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            height: heightItem,
          ),
          dropdownStyleData: const DropdownStyleData(
              elevation: 4,
              maxHeight: 160,
              offset: Offset(-12, -7),
              useSafeArea: true,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
