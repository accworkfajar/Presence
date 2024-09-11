import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class NewpasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "12345678") {
        try {
          await auth.currentUser!.updatePassword(newPassC.text);
          String email = auth.currentUser!.email!;
          await auth.signOut();
          await auth.signInWithEmailAndPassword(
              email: email, password: newPassC.text);
          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Get.snackbar("Terjadi Kesalahan", "Password Minimal 6 Karakter!");
            print('No user found for that email.');
          }
        } catch (e) {
          Get.snackbar("Terjadi Kesalahan",
              "Tidak Dapat Mengganti Password, Hubungi CS!");
        }
      } else {
        Get.snackbar(
            "Terjadi Kesalahan", "Dilarang Menggunakan Password Default");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Password Tidak Boleh Kosong");
    }
  }
}
