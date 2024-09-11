import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController jobC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    isLoadingAddPegawai.value = true;
    if (passAdminC.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential credentialAdmin = await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );
        UserCredential pegawaiCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "12345678",
        );

        if (pegawaiCredential.user != null) {
          String uid = pegawaiCredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "job": jobC.text,
            "uid": uid,
            "role": "pegawai",
            "created_at": DateTime.now().toIso8601String(),
          });

          await pegawaiCredential.user!.sendEmailVerification();

          await auth.signOut();

          UserCredential credentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back();
          Get.back();

          Get.snackbar("Success", "Berhasil Menambahkan Pegawai");
        }
        isLoadingAddPegawai.value = false;
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;

        if (e.code == 'weak-password') {
          Get.snackbar("Terjadi Kesalahan", "Password Terlalu Singkat");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi Kesalahan", "Email Sudah Terdaftar");
        } else if (e.code == 'wrong-password') {
          Get.snackbar(
              "Terjadi Kesalahan", "Admin Tidak Dapat Login, Password Salah");
        } else {
          Get.snackbar("Terjadi Kesalahan", e.code);
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;

        Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Menambahkan Pegawai");
      }
    } else {
      isLoading.value = false;
      Get.snackbar("Terjadi Kesalahan", "Password Wajib Diisi");
    }
  }

  Future<void> addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        jobC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("Masukkan Password Untuk Validasi Admin"),
            SizedBox(height: 10),
            TextField(
              controller: passAdminC,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              isLoading.value = false;
              Get.back();
            },
            child: Text("Back"),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoadingAddPegawai.isFalse) {
                  await prosesAddPegawai();
                }
                isLoading.value = false;
              },
              child: Text(isLoadingAddPegawai.isFalse ? "OK" : "LOADING...."),
            ),
          ),
        ],
      );
    } else {
      Get.snackbar("Terjadi Kesalahan", "Form Harus Diisi Dengan Lengkap");
    }
  }
}
