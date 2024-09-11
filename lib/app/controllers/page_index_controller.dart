import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        print("ABSENSI");
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);

          String address =
              "${placemarks[0].street} . ${placemarks[0].subLocality} . ${placemarks[0].locality}";
          await updatePosition(position, address);

          // cek jarak dibawah 2 pisisi
          double distance = Geolocator.distanceBetween(
              -6.59247, 106.8025621, position.latitude, position.longitude);

          //proses absen
          await presensi(position, address, distance);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("pegawai").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    // print(snapPresence.docs.length);
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    String status = "Diluar area";

    if (distance <= 350) {
      //didalam area
      status = "Didalam area";
    } else {
      //diluar area
    }

    if (snapPresence.docs.length == 0) {
      // belum pernah absen dan set absen masuk
      await Get.defaultDialog(
        title: "Validasi Presensi",
        middleText: "Apakah Kamu Ingin Mengisi Daftar Hadir (Masuk)?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "address": address,
                  "status": status,
                  "distance": distance,
                }
              });
              Get.back();
              Get.snackbar("Success", "Absen Masuk Berhasil");
            },
            child: Text("YES"),
          ),
        ],
      );
    } else {
      // sudah pernah absen -> cek hari ini udah absen masuk/keluar blm?
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        //absen keluar atau sudah absen masuk dan keluar
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?["keluar"] != null) {
          //sudah absen masuk dan keluar
          Get.snackbar("Informasi",
              "Kamu Telah Absen Masuk dan Keluar, silahkan absen dilain hari");
        } else {
          await Get.defaultDialog(
            title: "Validasi Presensi",
            middleText: "Apakah Kamu Ingin Mengisi Daftar Hadir (Keluar)?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).update({
                    "keluar": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    }
                  });
                  Get.back();
                  Get.snackbar("Success", "Absen Keluar Berhasil");
                },
                child: Text("YES"),
              ),
            ],
          );
          //absen keluar
        }
      } else {
        //absen masuk
        await Get.defaultDialog(
          title: "Validasi Presensi",
          middleText: "Apakah Kamu Ingin Mengisi Daftar Hadir (Masuk)?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                await colPresence.doc(todayDocID).set({
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "address": address,
                    "status": status,
                    "distance": distance,
                  }
                });
                Get.back();
                Get.snackbar("Success", "Absen Masuk Berhasil");
              },
              child: Text("YES"),
            ),
          ],
        );
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        "message": "Tidak Dapat Mengambil Lokasi Dari Device Kamu",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message": "Izin Menggunakan GPS di Tolak",
          "error": true,
        };
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          "message":
              "Settingan HP Kamu Tidak Memperbolehkan Untuk Akses GPS, Silahkan Ubah Settingan",
          "error": true,
        };
      }
    }

    // Jika mencapai titik ini, izin diberikan dan kita bisa mendapatkan lokasi
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        "position": position,
        "message": "Berhasil Mendapatkan Lokasi Device",
        "error": false,
      };
    } catch (e) {
      // Jika terjadi error saat mendapatkan lokasi
      return {
        "message": "Terjadi kesalahan saat mencoba mendapatkan lokasi",
        "error": true,
      };
    }
  }
}
