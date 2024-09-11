import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/newpassword_controller.dart';

class NewpasswordView extends GetView<NewpasswordController> {
  const NewpasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ganti Password'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.newPassC,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.newPassword();
              },
              child: Text("KONFIRMASI"),
            ),
          ],
        ));
  }
}
