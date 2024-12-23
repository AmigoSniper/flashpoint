import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salescheck/Model/eWalletModel.dart';
import 'package:salescheck/Service/ApiEwallet.dart';
import 'package:salescheck/page/Pengaturan/Pembayaran/eWallet/addEwallet.dart';
import 'package:salescheck/page/Pengaturan/Pembayaran/eWallet/editWallet.dart';

import '../../../../component/customButtonPrimary.dart';
import '../../../../component/notifError.dart';
import '../../../../component/notifSucces.dart';

class Ewallet extends StatefulWidget {
  const Ewallet({super.key});

  @override
  State<Ewallet> createState() => _EwalletState();
}

class _EwalletState extends State<Ewallet> {
  final Apiewallet _apiewallet = Apiewallet();
  late Future<void> _loadDataFuture;
  // List<eWallet> eWalletlist = [];
  List<Ewalletmodel> eWalletlist = [];
  Future<void> _refreshData() async {
    // Simulasi waktu loading
    eWalletlist.clear();

    _loadDataFuture = getEwalet();
    ;
  }

  Future<void> getEwalet() async {
    eWalletlist = await _apiewallet.getEwallet();
    if (_apiewallet.statusCode == 200 || _apiewallet.statusCode == 201) {
      setState(() {
        eWalletlist = eWalletlist;
      });
    } else {
      Notiferror.showNotif(context: context, description: _apiewallet.message);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = getEwalet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8FA),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'eWallet',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFF121212)),
          ),
        ),
        body: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customButtonPrimary(
                    alignment: Alignment.center,
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 16),
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Addewallet(),
                          ));
                      if (result != null) {
                        Notifsucces.showNotif(
                            context: context, description: result);
                        _refreshData();
                      }
                    },
                    child: const Text(
                      'Tambah E-Wallet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF)),
                    )),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset(
                        'asset/image/info-circle.svg',
                        color: const Color(0xFF0EA5E9),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Flexible(
                        child: Text(
                          'Daftar eWallet dibawah adalah eWallet aktif yang dapat digunakan saat pembayaran',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF0EA5E9)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: FutureBuilder(
                              future: _loadDataFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                      alignment: Alignment.center,
                                      height: 375,
                                      width: 375,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            'Belum ada data barang tersedia',
                                            style: TextStyle(
                                                color: Color(0xFFB1B5C0),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ));
                                } else {
                                  if (eWalletlist.isEmpty) {
                                    return Container(
                                        alignment: Alignment.center,
                                        height: 375,
                                        width: 375,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                              'Belum ada daftar eWallet untuk toko anda',
                                              style: TextStyle(
                                                  color: Color(0xFFB1B5C0),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ));
                                  } else {
                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                          bottom: 16, top: 0),
                                      shrinkWrap: true,
                                      itemCount: eWalletlist.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              padding: const EdgeInsets.only(
                                                  top: 16,
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 16),
                                              decoration: const BoxDecoration(
                                                  color: Color(0xFFFFFFFF),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    eWalletlist[index]
                                                            .namaEwallet ??
                                                        '',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF303030),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                    onPressed: () async {
                                                      final result = await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Editwallet(
                                                                      ewalletmodel:
                                                                          eWalletlist[
                                                                              index])));
                                                      if (result != null) {
                                                        final message =
                                                            result['message'];
                                                        final isDeleted =
                                                            result['isDeleted'];
                                                        // ignore: use_build_context_synchronously

                                                        if (isDeleted == true) {
                                                          setState(() {
                                                            _refreshData();
                                                          });

                                                          Notifsucces.showNotif(
                                                              context: context,
                                                              description:
                                                                  message);
                                                        } else {
                                                          Notifsucces.showNotif(
                                                              context: context,
                                                              description:
                                                                  message);
                                                          _refreshData();
                                                        }
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF2E6CE9),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        SvgPicture.asset(
                                                          'asset/image/edit.svg',
                                                          width: 16,
                                                          height: 16,
                                                          color: const Color(
                                                              0xFF2E6CE9),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                            ))))
              ],
            )));
  }
}
