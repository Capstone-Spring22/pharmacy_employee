import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/views/overlay/btn_tag.dart';
import 'package:system_alert_window/system_alert_window.dart';

class OverLayScreen extends StatefulWidget {
  const OverLayScreen({super.key});

  @override
  State<OverLayScreen> createState() => _OverLayScreenState();
}

class _OverLayScreenState extends State<OverLayScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OverLayScreen'),
      ),
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            return Column(
              children: [
                FilledButton(
                  onPressed: () {
                    SystemWindowHeader header = SystemWindowHeader(
                      title: SystemWindowText(
                        text: "Incoming Call",
                        fontSize: 10,
                        textColor: Colors.black45,
                      ),
                      padding: SystemWindowPadding.setSymmetricPadding(12, 12),
                      subTitle: SystemWindowText(
                        text: "9898989899",
                        fontSize: 14,
                        fontWeight: FontWeight.BOLD,
                        textColor: Colors.black87,
                      ),
                      decoration:
                          SystemWindowDecoration(startColor: Colors.grey[100]),
                      button: SystemWindowButton(
                        text: SystemWindowText(
                          text: "Personal",
                          fontSize: 10,
                          textColor: Colors.black45,
                        ),
                        tag: "personal_btn",
                      ),
                      buttonPosition: ButtonPosition.TRAILING,
                    );

                    SystemWindowFooter footer = SystemWindowFooter(
                      buttons: [
                        SystemWindowButton(
                          text: SystemWindowText(
                            text: "Close Overlay",
                            fontSize: 12,
                            textColor: context.theme.primaryColor,
                          ),
                          tag: "$closeBtnTag-0",
                          padding: SystemWindowPadding(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            top: 10,
                          ),
                          width: 0,
                          height: SystemWindowButton.WRAP_CONTENT,
                          decoration: SystemWindowDecoration(
                            startColor: Colors.white,
                            endColor: Colors.white,
                            borderWidth: 0,
                            borderRadius: 0.0,
                          ),
                        ),
                        SystemWindowButton(
                          text: SystemWindowText(
                            text: "Call Customer",
                            fontSize: 12,
                            textColor: Colors.white,
                          ),
                          tag: "$callBtnTag-${appController.p.value}",
                          width: 0,
                          padding: SystemWindowPadding(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            top: 10,
                          ),
                          height: SystemWindowButton.WRAP_CONTENT,
                          decoration: SystemWindowDecoration(
                            startColor: const Color.fromRGBO(250, 139, 97, 1),
                            endColor: const Color.fromRGBO(247, 28, 88, 1),
                            borderWidth: 0,
                            borderRadius: 30.0,
                          ),
                        )
                      ],
                      padding: SystemWindowPadding(
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      decoration:
                          SystemWindowDecoration(startColor: Colors.white),
                      buttonsPosition: ButtonPosition.CENTER,
                    );

                    SystemWindowBody body = SystemWindowBody(
                      rows: [
                        EachRow(
                          columns: [
                            EachColumn(
                              text: SystemWindowText(
                                text: "Some body",
                                fontSize: 12,
                                textColor: Colors.black45,
                              ),
                            ),
                          ],
                          gravity: ContentGravity.CENTER,
                        ),
                      ],
                      padding: SystemWindowPadding(
                        left: 16,
                        right: 16,
                        bottom: 12,
                        top: 12,
                      ),
                    );

                    SystemAlertWindow.showSystemWindow(
                      height: (Get.height * .2).toInt(),
                      header: header,
                      body: body,
                      footer: footer,
                      margin: SystemWindowMargin(
                        left: 8,
                        right: 8,
                        top: 100,
                        bottom: 0,
                      ),
                      gravity: SystemWindowGravity.TOP,
                      notificationTitle: "Incoming Call",
                      notificationBody: "+1 646 980 4741",
                      prefMode: SystemWindowPrefMode.OVERLAY,
                    );
                  },
                  child: const Text("Popup"),
                )
              ],
            );
          },
          future: SystemAlertWindow.checkPermissions(),
        ),
      ),
    );
  }
}
