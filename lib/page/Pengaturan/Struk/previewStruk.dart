import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../component/customButtonPrimary.dart';

class Previewstruk extends StatefulWidget {
  final File? image;
  final bool logo;
  final bool namaToko;
  final bool alamat;
  final bool kontak;
  final bool socialMedia;
  final bool catatan;
  final String imageUrl;
  final String name;
  final String alamattext;
  final String kontaktext;
  final String socialMedia1text;
  final String socialMedia2text;
  final String catatantext;
  const Previewstruk(
      {super.key,
      required this.image,
      required this.logo,
      required this.namaToko,
      required this.alamat,
      required this.kontak,
      required this.socialMedia,
      required this.catatan,
      required this.name,
      required this.alamattext,
      required this.kontaktext,
      required this.socialMedia1text,
      required this.socialMedia2text,
      required this.catatantext,
      required this.imageUrl});

  @override
  State<Previewstruk> createState() => _PreviewstrukState();
}

class _PreviewstrukState extends State<Previewstruk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Preview Struk',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customButtonPrimary(
                    onPressed: () {},
                    height: 48,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('asset/struk/printer.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Coba Print',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 16,
                ),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(
                            width: 1, color: const Color(0xFFAAAAAAAA))),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                !widget.logo
                                    ? const SizedBox.shrink()
                                    : widget.image == null
                                        ? Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                width: 84,
                                                height: 84,
                                                imageUrl: widget.imageUrl,
                                                progressIndicatorBuilder:
                                                    (context, url, progress) {
                                                  return Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        value: progress
                                                                    .totalSize !=
                                                                null
                                                            ? progress
                                                                    .downloaded /
                                                                (progress
                                                                        .totalSize ??
                                                                    1)
                                                            : null,
                                                      ),
                                                      Text(
                                                        '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ));
                                                },
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'asset/image/gallery-add.svg',
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                      const Text(
                                                        'Tambah Foto',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFFA8A8A8)),
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            width: 84,
                                            height: 84,
                                            padding: EdgeInsets.zero,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            alignment: Alignment.centerLeft,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  widget.image!,
                                                  height: 84,
                                                  width: 84,
                                                ))),
                                !widget.namaToko
                                    ? const SizedBox.shrink()
                                    : Text(
                                        widget.name,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF09090B),
                                            fontWeight: FontWeight.w600),
                                      ),
                                !widget.alamat
                                    ? const SizedBox.shrink()
                                    : Text(
                                        widget.alamattext,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF09090B),
                                            fontWeight: FontWeight.w500),
                                      ),
                                !widget.kontak
                                    ? const SizedBox.shrink()
                                    : Text(
                                        'No. Telp ${widget.kontaktext}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF09090B),
                                            fontWeight: FontWeight.w500),
                                      ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No. Order : #0899',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF09090B)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Waktu : 12 Feb 2024, 08.30',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF09090B)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Kasir : Nama Kasir',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF09090B)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Pembayaran : -',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF09090B)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            width: double.infinity,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF09090B)),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Nama Barang',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF09090B)),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Rp 10.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF09090B)),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Nama Barang',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF09090B)),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Rp 10.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const DottedLine(
                            dashColor: Color(0xFFCBD5E1),
                            lineThickness: 1,
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sub Total',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      'Rp 30.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Pajak 10%',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      'Rp 3.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Diskon 8.8',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      '-Rp 13.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      'Rp 20.000',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Kembali',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF09090B)),
                                    ),
                                    Text(
                                      'Rp 2.000',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF09090B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          !widget.socialMedia
                              ? const SizedBox.shrink()
                              : Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.socialMedia1text,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF09090B)),
                                      ),
                                      Text(
                                        widget.socialMedia2text,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF09090B)),
                                      ),
                                    ],
                                  ),
                                ),
                          !widget.catatan
                              ? const SizedBox.shrink()
                              : Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  child: Text(
                                    widget.catatantext,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xFF09090B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                          Container(
                            width: double.infinity,
                            child: const Text(
                              'Powered by Flashpoint POS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF717179),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          )),
    );
  }
}
