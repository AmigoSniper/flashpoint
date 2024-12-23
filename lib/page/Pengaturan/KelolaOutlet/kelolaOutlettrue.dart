import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salescheck/Model/Outlet.dart';
import 'package:salescheck/Model/outlets.dart';
import 'package:salescheck/Service/ApiOutlet.dart';
import 'package:salescheck/page/Pengaturan/KelolaOutlet/AddOutlet.dart';
import 'package:salescheck/page/Pengaturan/KelolaOutlet/EditOutlet.dart';
import 'package:toastification/toastification.dart';

import '../../../component/customButtonPrimary.dart';
import '../../../component/customButtonColor.dart';

class Kelolaoutlettrue extends StatefulWidget {
  const Kelolaoutlettrue({super.key});

  @override
  State<Kelolaoutlettrue> createState() => _KelolaoutlettrueState();
}

class _KelolaoutlettrueState extends State<Kelolaoutlettrue> {
  final Apioutlet _apioutlet = new Apioutlet();
  late Future<void> _loadDataFuture;
  List<Outlets> listOutlets = [];

  List<Outlet> listOutlet = [];
  void notif(String title) {
    toastification.show(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 16, left: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        autoCloseDuration: const Duration(seconds: 8),
        progressBarTheme: const ProgressIndicatorThemeData(
            color: Color(0xFFFFFFFF), linearTrackColor: Color(0xFFCDCDCD)),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: const Color(0xFF28A745),
        backgroundColor: Colors.black,
        context: context,
        showProgressBar: false,
        closeOnClick: true,
        closeButtonShowType: CloseButtonShowType.always,
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFFFFFFFF),
        ),
        title: const Text(
          'Berhasil',
          style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w700,
              fontSize: 12),
        ),
        description: Text(
          title,
          style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ));
  }

  Future<void> _readAndPrintPegawaiData() async {
    listOutlets = await _apioutlet.getAllOutletApi();
    setState(() {
      listOutlets = listOutlets;
    });
  }

  void _quickAccesForm(BuildContext context, Outlets outlet) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFFFBFBFB),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 16, right: 16, bottom: 24, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                color: const Color(0xFFE9E9E9),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          fit: BoxFit.fitHeight,
                          imageUrl: _apioutlet.getImage(outlet.image),
                          progressIndicatorBuilder: (context, url, progress) {
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.totalSize != null
                                      ? progress.downloaded /
                                          (progress.totalSize ?? 1)
                                      : null,
                                ),
                                Text(
                                  '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ],
                            ));
                          },
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: 140,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 82,
                              height: 24,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  color: Color(0xFFF0F9FF)),
                              child: const Text(
                                'ID SPO-01',
                                style: TextStyle(
                                    color: Color(0xFF0EA5E9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              outlet.namaOutlet ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              outlet.alamat ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: 'Koordinator : ',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFA3A3A3)),
                                children: [
                                  TextSpan(
                                    text: outlet.nameUser,
                                    style: const TextStyle(
                                        color: Color(0xFF000000)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustombuttonColor(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        alignment: Alignment.center,
                        height: 48,
                        color: const Color(0xFFF6F6F6),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF09090B)),
                        )),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: customButtonPrimary(
                        alignment: Alignment.center,
                        height: 48,
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Editoutlet(
                                        outlet: outlet,
                                      )));

                          if (result != null) {
                            final message = result['message'];
                            final isDeleted = result['isDeleted'];
                            // ignore: use_build_context_synchronously

                            print(message);
                            print(isDeleted);
                            if (isDeleted == true) {
                              notif(message);
                              _refreshData();
                            } else {
                              notif(message);
                              _refreshData();
                            }
                          }
                        },
                        child: const Text(
                          'Kelola Outlet',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFFFFFF)),
                        )),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshData() async {
    // Simulasi delay untuk menunggu data baru
    await Future.delayed(const Duration(seconds: 2));
    listOutlet.clear();
    listOutlets.clear();
    // Perbarui data dan setState untuk memperbarui tampilan
    await _readAndPrintPegawaiData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = _readAndPrintPegawaiData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FutureBuilder(
                future: _loadDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Loading...'),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    if (listOutlets.isEmpty) {
                      return Container(
                          alignment: Alignment.center,
                          height: 375,
                          width: 375,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SvgPicture.asset(
                                'asset/pegawai/Group 33979.svg',
                                width: 105,
                                height: 105,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Text(
                                'Belum ada data outlet tersedia',
                                style: TextStyle(
                                    color: Color(0xFFB1B5C0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ));
                    } else {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        shrinkWrap: true,
                        itemCount: listOutlets.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _quickAccesForm(context, listOutlets[index]);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: double.infinity,
                                      height: 106,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fitWidth,
                                              width: double.infinity,
                                              height: 140,
                                              imageUrl: _apioutlet.getImage(
                                                  listOutlets[index].image),
                                              progressIndicatorBuilder:
                                                  (context, url, progress) {
                                                return Center(
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
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
                                                    if (progress.totalSize !=
                                                        null)
                                                      Text(
                                                        '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                  ],
                                                ));
                                              },
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                          listOutlets[index].posisi ==
                                                  'Toko Utama'
                                              ? Positioned(
                                                  left: 0,
                                                  top: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 12),
                                                    width: 79,
                                                    height: 24,
                                                    decoration: const BoxDecoration(
                                                        color:
                                                            Color(0xFF2E6CE9),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        6))),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                            'asset/kelolaOutlet/shop.svg'),
                                                        const Text(
                                                          'Utama',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFFFFFFF),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                              : const SizedBox.shrink()
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 82,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        color: Color(0xFFF0F9FF)),
                                    child: const Text(
                                      'ID SPO-01',
                                      style: TextStyle(
                                          color: Color(0xFF0EA5E9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    listOutlets[index].namaOutlet ?? '',
                                    style: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    listOutlets[index].alamat ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFFA3A3A3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              )),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Addoutlet()));
                      if (result != null) {
                        // ignore: use_build_context_synchronously

                        notif(result);
                        _refreshData();
                      }
                    },
                    child: Container(
                      height: 48.0,
                      // width: 170,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            offset: const Offset(2, 4),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                        color: const Color(0xFF2E6CE9),
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Color(0xFFFFFFFF),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Tambah Outlet',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ))
      ],
    );
  }
}
