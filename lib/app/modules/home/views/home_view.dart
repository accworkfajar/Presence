import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/controllers/page_index_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomeView extends GetView<HomeController> {
  final pageC = Get.find<PageIndexController>();
  HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData) {
              Map<String, dynamic> user = snapshot.data!.data()!;
              String defaultImage =
                  "https://ui-avatars.com/api/?name=${user['name']}";
              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  //
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          height: 75,
                          width: 75,
                          child: Image.network(
                            user["profile"] != null
                                ? user["profile"]
                                : defaultImage,
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[200],
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 200,
                            child: Text(
                              user["address"] != null
                                  ? "${user['address']}"
                                  : "Lokasi Tidak Terdeteksi",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user["job"]}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "${user["nip"]}",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${user["name"]}",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: controller.streamTodayPresence(),
                            builder: (context, snapToday) {
                              if (snapToday.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              Map<String, dynamic>? dataToday =
                                  snapToday.data?.data();
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text("Masuk"),
                                      Text(dataToday?["masuk"] == null
                                          ? "-"
                                          : "${DateFormat.jms().format(DateTime.parse(dataToday!['masuk']["date"]))}"),
                                    ],
                                  ),
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                                  Column(
                                    children: [
                                      Text("Keluar"),
                                      Text(dataToday?["keluar"] == null
                                          ? "-"
                                          : "${DateFormat.jms().format(DateTime.parse(dataToday!['keluar']["date"]))}"),
                                    ],
                                  ),
                                ],
                              );
                            }),
                  ),
                  SizedBox(height: 10),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Last 5 Days",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                          onPressed: () => Get.toNamed(Routes.ALL_PRESENSI),
                          child: Text("See more")),
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: controller.streamLastPresence(),
                      builder: (context, snapPresence) {
                        if (snapPresence.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapPresence.data!.docs.isEmpty ||
                            snapPresence.data == null) {
                          return SizedBox(
                            height: 150,
                            child: Center(
                              child: Text("Belum Memiliki History Presensi"),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapPresence.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                snapPresence.data!.docs[index].data();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Material(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () => Get.toNamed(
                                    Routes.DETAIL_PRESENSI,
                                    arguments: data,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Masuk",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text(data['masuk']?['date'] == null
                                            ? "-"
                                            : "${DateFormat.jms().format(DateTime.parse(data['masuk']!['date']))}"),
                                        SizedBox(height: 10),
                                        Text(
                                          "Keluar",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(data['keluar']?['date'] == null
                                            ? "-"
                                            : "${DateFormat.jms().format(DateTime.parse(data['keluar']!['date']))}"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                ],
              );
            } else {
              return Center(
                child: Text("Tidak Dapat Memuat Data"),
              );
            }
          }),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.map, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
