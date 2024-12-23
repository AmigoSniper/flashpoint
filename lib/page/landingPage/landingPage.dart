import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:salescheck/page/landingPage/homepage.dart';
import 'package:salescheck/page/landingPage/settingpage.dart';
import 'package:salescheck/page/landingPage/stockpage.dart';
import 'package:salescheck/page/landingPage/transaksipage.dart';

class Landingpage extends StatefulWidget {
  final int? idOutlab;
  final int? indexOutlab;
  final bool? boolpermis;
  const Landingpage(
      {super.key, this.idOutlab, this.indexOutlab, this.boolpermis});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  int _selectedIndex = 0;

  List<String> searchBarang = [];
  List<int> searchstock = [];
  List<int> searchnominal = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToStockTab(int indextab) {
    setState(() {
      _selectedIndex = indextab;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      Homepage(
        navigateToStockTab: navigateToStockTab,
        indexOutlab: widget.indexOutlab,
        idOutlab: widget.idOutlab,
      ),
      const Transaksipage(),
      Stockpage(
        ouletidTransaksi: widget.idOutlab ?? null,
      ),
      Settingpage(
        permisOutlet: widget.boolpermis,
      )
    ];
    return Scaffold(
      bottomNavigationBar: Container(
        height: 77,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: 'asset/image/beranda.svg',
              label: 'Beranda',
            ),
            _buildNavItem(
              index: 1,
              icon: 'asset/image/transaksi.svg',
              label: 'Transaksi',
            ),
            _buildNavItem(
              index: 2,
              icon: 'asset/image/box.svg',
              label: 'Inventori',
            ),
            _buildNavItem(
              index: 3,
              icon: 'asset/image/pengaturan.svg',
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF6F8FA),
      body: SafeArea(
          bottom: true,
          child: IndexedStack(
            index: _selectedIndex,
            children: _children,
          )),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              curve: Curves.easeInOut,
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF2E6CE9) : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SvgPicture.asset(
                icon,
                color: isSelected
                    ? const Color(0xFF2E6CE9)
                    : const Color(0xFF9399A7),
                height: 24,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2E6CE9)
                    : const Color(0xFF9399A7),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
