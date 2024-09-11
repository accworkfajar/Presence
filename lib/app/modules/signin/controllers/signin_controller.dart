import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class SigninController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        print(credential);

        if (credential.user != null) {
          if (credential.user!.emailVerified == true) {
            isLoading.value = false;

            if (passC.text == "12345678") {
              Get.offAllNamed(Routes.NEWPASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
              title: "Belum Verifikasi",
              middleText: "Lakukan Verifikasi Terlebih Dahulu",
              actions: [
                OutlinedButton(
                  onPressed: () {
                    isLoading.value = false;
                    Get.back();
                  },
                  child: Text("BACK"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await credential.user!.sendEmailVerification();
                      Get.back();
                      Get.snackbar(
                          "Behasil", "Email Verifikasi Telah Dikirim Ulang.");
                      isLoading.value = false;
                    } catch (e) {
                      isLoading.value = false;
                      Get.back();
                      Get.snackbar("Terjadi Kesalahan",
                          "Tidak Dapat Mengirim Email Verifikasi, Hubungi CS.");
                    }
                  },
                  child: Text("Kirim Ulang"),
                ),
              ],
            );
          }
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          Get.snackbar("Terjadi Kesalahan", "Email Tidak Terdaftar!");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Terjadi Kesalahan", "Password Salah!");
        } else {
          Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Login!");
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Terjadi Kesalahan", "Terdapat Masalah!");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Form Wajib Diisi!");
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:presence/app/routes/app_pages.dart';

// class SigninController extends GetxController {
//   TextEditingController emailC = TextEditingController();
//   TextEditingController passC = TextEditingController();

//   FirebaseAuth auth = FirebaseAuth.instance;

//   void login() async {
//     if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
//       try {
//         final credential = await auth.signInWithEmailAndPassword(
//           email: emailC.text,
//           password: passC.text,
//         );

//         print(credential);

//         if (credential.user != null) {
//           if (credential.user!.emailVerified == true) {
//             if (passC.text == "12345678") {
//               Get.offAllNamed(Routes.NEWPASSWORD);
//             } else {
//               Get.offAllNamed(Routes.HOME);
//             }
//           } else {
//             Get.defaultDialog(
//               title: "Belum Verifikasi",
//               middleText: "Lakukan Verifikasi Terlebih Dahulu",
//               actions: [
//                 OutlinedButton(
//                   onPressed: () => Get.back(),
//                   child: Text("BACK"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       await credential.user!.sendEmailVerification();
//                       Get.back();
//                       Get.snackbar(
//                           "Berhasil", "Email Verifikasi Telah Dikirim Ulang.");
//                     } catch (e) {
//                       Get.back();
//                       Get.snackbar("Terjadi Kesalahan",
//                           "Tidak Dapat Mengirim Email Verifikasi, Hubungi CS.");
//                     }
//                   },
//                   child: Text("Kirim Ulang"),
//                 ),
//               ],
//             );
//           }
//         }
//       } on FirebaseAuthException catch (e) {
//         // Periksa kode kesalahan untuk menampilkan pesan yang tepat
//         if (e.code == 'user-not-found') {
//           Get.snackbar("Terjadi Kesalahan", "Email Tidak Terdaftar!");
//         } else if (e.code == 'wrong-password') {
//           Get.snackbar("Terjadi Kesalahan", "Password Salah!");
//         } else {
//           Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Login!");
//         }
//       } catch (e) {
//         Get.snackbar("Terjadi Kesalahan", "Tidak Dapat Login!");
//       }
//     } else {
//       Get.snackbar("Terjadi Kesalahan", "Form Wajib Diisi!");
//     }
//   }
// }

