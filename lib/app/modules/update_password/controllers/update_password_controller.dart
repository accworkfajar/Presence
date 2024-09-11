import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController currC = TextEditingController();
  TextEditingController newC = TextEditingController();
  TextEditingController confirmC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void updatePass() async {
    if (currC.text.isNotEmpty &&
        newC.text.isNotEmpty &&
        confirmC.text.isNotEmpty) {
      if (newC.text == confirmC.text) {
        isLoading.value = true;
        try {
          String emailUser = auth.currentUser!.email!;

          await auth.signInWithEmailAndPassword(
              email: emailUser, password: currC.text);

          await auth.currentUser!.updatePassword(newC.text);

          Get.back();
          Get.snackbar("Berhasil", "Password Telah Direset");
        } on FirebaseAuthException catch (e) {
          if (e.code == "wrong-password") {
            Get.snackbar("Terjadi Kesalahan", "Password Lama Tidak Sesuai");
          } else {
            Get.snackbar("Terjadi Kesalahan", e.code.toLowerCase());
          }
          Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Reset Password");
        } catch (e) {
          Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Reset Password");
        } finally {
          isLoading.value = false;
        }
      } else {
        Get.snackbar("Terjadi Kesalahan", "Password Baru Tidak Sesuai");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Form Tidak Boleh Kosong");
    }
  }
}
