import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/all_presensi_controller.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AllPresensiView extends GetView<AllPresensiController> {
  const AllPresensiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL PRESENSI'),
        centerTitle: true,
      ),
      body: GetBuilder<AllPresensiController>(
        builder: (c) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: controller.getPresence(),
            builder: (context, snapAllPresence) {
              if (snapAllPresence.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapAllPresence.data!.docs.isEmpty ||
                  snapAllPresence.data == null) {
                return SizedBox(
                  height: 150,
                  child: Center(
                    child: Text("Belum Memiliki History Presensi"),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(20),
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: snapAllPresence.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      snapAllPresence.data!.docs[index].data();
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Masuk",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(data['masuk']?['date'] == null
                                  ? "-"
                                  : "${DateFormat.jms().format(DateTime.parse(data['masuk']!['date']))}"),
                              SizedBox(height: 10),
                              Text(
                                "Keluar",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // syncfusion datepicker
          Get.dialog(Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 400,
              child: SfDateRangePicker(
                monthViewSettings:
                    DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                selectionMode: DateRangePickerSelectionMode.range,
                showActionButtons: true,
                onCancel: () => Get.back(),
                onSubmit: (obj) {
                  if (obj != null) {
                    if ((obj as PickerDateRange).endDate != null) {
                      //proses kalau null
                      controller.pickDate(obj.startDate!, obj.endDate!);
                    }
                  }
                },
              ),
            ),
          ));
        },
        child: Icon(Icons.format_list_bulleted_rounded),
      ),
    );
  }
}
