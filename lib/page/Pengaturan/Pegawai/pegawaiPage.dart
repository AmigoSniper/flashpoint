import 'package:avatar_plus/avatar_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salescheck/Model/Pegawai.dart';
import 'package:salescheck/Service/ApiPegawai.dart';
import 'package:salescheck/component/customButtonColor.dart';
import 'package:salescheck/component/notifError.dart';
import 'package:salescheck/component/notifSucces.dart';
import 'package:salescheck/component/searchBar.dart';
import 'package:salescheck/page/Pengaturan/Pegawai/addPegawai.dart';
import 'package:salescheck/page/Pengaturan/Pegawai/editPegawai.dart';
import 'package:toastification/toastification.dart';

import '../../../Model/User.dart';
import '../../../component/customButtonPrimary.dart';

class pegawaiPage extends StatefulWidget {
  const pegawaiPage({super.key});

  @override
  State<pegawaiPage> createState() => _pegawaiPageState();
}

class _pegawaiPageState extends State<pegawaiPage> {
  final Apipegawai _apipegawai = Apipegawai();
  TextEditingController search = new TextEditingController();
  String searchQuery = '';
  List<Pegawai> listPegawai = [];
  List<Pegawai> listPegawaisearch = [];
  List<User> listUser = [];
  List<User> listUsersearch = [];
  late Future<void> _loadDataFuture;
  Future<void> _readAndPrintPegawaiData() async {
    listUser = await _apipegawai.getPegawaiApi();
    if (_apipegawai.statusCode == 200 || _apipegawai.statusCode == 201) {
      setState(() {
        listUsersearch = listUser;
      });
    } else {
      Notiferror.showNotif(context: context, description: _apipegawai.message);
    }
  }

  Future<void> _refreshData() async {
    // Simulasi delay untuk menunggu data baru
    await Future.delayed(const Duration(seconds: 2));
    listPegawai.clear();
    listUser.clear();
    // Perbarui data dan setState untuk memperbarui tampilan
    _readAndPrintPegawaiData();
    setState(() {
      search.clear();
      searchQuery = '';
    });
  }

  void searchfunction() {
    if (searchQuery.isNotEmpty) {
      listUsersearch = listUser;
      setState(() {
        listUsersearch = listUsersearch
            .where((item) =>
                item.name.toLowerCase().startsWith(searchQuery.toLowerCase()))
            .toList();
      });
      print(listPegawai.length);
    } else {
      listUsersearch = listUser;
    }
  }

  Color getRoleColorBackground(String role, bool status) {
    if (status) {
      switch (role.toLowerCase()) {
        case 'admin':
          return const Color(0xFFF0F9FF);
        case 'manager':
          return const Color(0xFFECFDF5);
        case 'kasir':
          return const Color(0xFFFFFBEB);
        case 'nonaktif':
          return const Color(0xFFFFF1F2);
        default:
          return const Color(0xFFF0F9FF);
      }
    } else {
      return const Color(0xFFFFF1F2);
    }
  }

  Color getRoleColorFont(String role, bool active) {
    if (active == true) {
      switch (role.toLowerCase()) {
        case 'admin':
          return const Color(0xFF0EA5E9);
        case 'manager':
          return const Color(0xFF10B981);
        case 'kasir':
          return const Color(0xFFF59E0B);
        case 'nonaktif':
          return const Color(0xFFF43F5E);
        default:
          return Colors.grey;
      }
    } else {
      return const Color(0xFFF43F5E);
    }
  }

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

  void _quickAccesForm(BuildContext context, User user, bool status) {
    showModalBottomSheet(
      isDismissible: false,
      backgroundColor: const Color(0xFFFFFFFF),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        bool imageNull = user.image == null;
        print(_apipegawai.getImage(user.image ?? ''));
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            bool close = true;
            return Padding(
              padding: const EdgeInsets.only(
                  top: 16, right: 16, bottom: 24, left: 16),
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
                  status
                      ? const SizedBox.shrink()
                      : Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFF1F2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SvgPicture.asset(
                                'asset/image/info-circle.svg',
                                color: const Color(0xFFF43F5E),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                'Status pengguna ini tidak aktif',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFFF43F5E)),
                              ),
                            ],
                          ),
                        ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.transparent,
                          ),
                          child: imageNull
                              ? AvatarPlus(
                                  user.name,
                                  fit: BoxFit.contain,
                                )
                              : ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        _apipegawai.getImage(user.image ?? ''),
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
                                            value: progress.totalSize != null
                                                ? progress.downloaded /
                                                    (progress.totalSize ?? 1)
                                                : null,
                                          ),
                                          if (progress.totalSize != null)
                                            Text(
                                              '${(progress.downloaded / 1000000).toStringAsFixed(2)} / ${(progress.totalSize! / 1000000).toStringAsFixed(2)} MB',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                        ],
                                      ));
                                    },
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                        ),
                        Container(
                          width: 187,
                          height: 160,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 24,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100)),
                                        color: getRoleColorBackground(
                                            user.role, status)),
                                    child: Text(
                                      status ? user.role : 'Nonaktif',
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: getRoleColorFont(
                                              user.role, status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                user.name,
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
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFFA3A3A3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF6F6F6),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text(
                                      'Aktif',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF303030)),
                                    ),
                                    SizedBox(
                                        width: 44,
                                        height: 24,
                                        child: CupertinoSwitch(
                                          activeColor: const Color(0xFF10B981),
                                          trackColor: const Color(0xFFE2E8F0),
                                          thumbColor: const Color(0xFFFFFFFF),
                                          value: status,
                                          onChanged: (value) async {
                                            setModalState(() {
                                              status = value;
                                              close = false;
                                            });
                                            await _apipegawai
                                                .quickeditPegawaitApi(
                                                    idPegawai: user.id,
                                                    status: status);
                                            await _refreshData();
                                            setModalState(() {
                                              close = true;
                                            });
                                          },
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (user.tokenLogin!.isNotEmpty) {
                        Clipboard.setData(
                            ClipboardData(text: user.tokenLogin!));
                        Notifsucces.showNotif(
                            context: context,
                            description: 'Token telah disalin');
                      } else {}
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            'ID Token',
                            style: TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color(0xFFF6F6F6)),
                            child: (user.tokenLogin != null &&
                                    user.tokenLogin!.isNotEmpty)
                                ? Text(
                                    user.tokenLogin!,
                                    style: const TextStyle(
                                      color: Color(0xFF09090B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : const Text(
                                    'ID Token belum tersedia',
                                    style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          child: CustombuttonColor(
                              color: const Color(0xFFF6F6F6),
                              alignment: Alignment.center,
                              height: 48,
                              onPressed: () {
                                if (close == true) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                'Kembali',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF09090B)),
                              ))),
                      const SizedBox(
                        width: 15,
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
                                      builder: (context) => Editpegawai(
                                            user: user,
                                          )));

                              if (result != null) {
                                final message = result['message'];
                                final isDeleted = result['isDeleted'];
                                // ignore: use_build_context_synchronously

                                print(message);
                                print(isDeleted);
                                if (isDeleted == true) {
                                  notif(message);
                                } else {
                                  notif(message);
                                }
                                _refreshData();
                              }
                            },
                            child: const Text(
                              'Edit Pengguna',
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
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = _readAndPrintPegawaiData();
  }

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
            'Pegawai',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFF121212)),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Searchbar(
                      hintText: 'Cari Pegawai',
                      onChanged: (p0) {
                        print('cari');
                        setState(() {
                          searchQuery = search.text;
                        });
                        searchfunction();
                        print('hasil');
                      },
                      controller: search)),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _refreshData,
                      child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: FutureBuilder<void>(
                            future: _loadDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else {
                                if (listUsersearch.isEmpty) {
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
                                            'Belum ada data pegawai tersedia',
                                            style: TextStyle(
                                                color: Color(0xFFB1B5C0),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ));
                                } else {
                                  return MasonryGridView.count(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemCount: listUsersearch.length,
                                    itemBuilder: (context, index) {
                                      bool statusPegawai =
                                          listUsersearch[index].status ==
                                                  'Active'
                                              ? true
                                              : false;
                                      bool imageNull =
                                          listUsersearch[index].image == null;

                                      return GestureDetector(
                                        onTap: () {
                                          _quickAccesForm(
                                              context,
                                              listUsersearch[index],
                                              statusPegawai);
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16),
                                            decoration: BoxDecoration(
                                                color: statusPegawai
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color(0xFFEAEAED),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(0))),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    height: 75,
                                                    width: 75,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        imageNull
                                                            ? AvatarPlus(
                                                                listUsersearch[
                                                                        index]
                                                                    .name,
                                                                fit: BoxFit
                                                                    .contain,
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            100)),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 75,
                                                                  height: 75,
                                                                  imageUrl: _apipegawai
                                                                      .getImage(
                                                                          listUsersearch[index].image ??
                                                                              ''),
                                                                  progressIndicatorBuilder:
                                                                      (context,
                                                                          url,
                                                                          progress) {
                                                                    return Center(
                                                                        child:
                                                                            Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        CircularProgressIndicator(
                                                                          value: progress.totalSize != null
                                                                              ? progress.downloaded / (progress.totalSize ?? 1)
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
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .error),
                                                                ),
                                                              ),
                                                        Positioned(
                                                          bottom: 0,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 24,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        12),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            100)),
                                                                color: getRoleColorBackground(
                                                                    listUsersearch[
                                                                            index]
                                                                        .role,
                                                                    statusPegawai)),
                                                            child: Text(
                                                              statusPegawai
                                                                  ? listUsersearch[
                                                                          index]
                                                                      .role
                                                                  : 'Nonaktif',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: TextStyle(
                                                                  color: getRoleColorFont(
                                                                      listUsersearch[
                                                                              index]
                                                                          .role,
                                                                      statusPegawai),
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        listUsersearch[index]
                                                            .name,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF0B0C17),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                        listUsersearch[index]
                                                            .email,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFFA3A3A3),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
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
                                          builder: (context) =>
                                              const Addpegawai()));
                                  if (result != null) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        'Tambah Pegawai',
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
                ),
              )
            ],
          ),
        ));
  }
}
