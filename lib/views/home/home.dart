import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: Get.height * .9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: Get.width * .9,
                  height: Get.height * .07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: "logoTag",
                        child: GestureDetector(
                          // onTap: () {
                          //   Get.log(
                          //       appController.pharmacist.value.token.toString());
                          // },
                          onTap: () {},
                          child: Image.asset(
                            'assets/icon.png',
                            height: Get.height * .15,
                            width: Get.height * .15,
                          ),
                        ),
                      ),
                      AnimatedTextKit(
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            "Better Health",
                            textStyle: TextStyle(
                              fontFamily: 'Quicksand',
                              letterSpacing: 4,
                              fontSize: 25,
                              color: context.theme.primaryColor,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed("/lookup"),
                  child: Container(
                    width: Get.width * 0.6,
                    height: Get.height * 0.2,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[200],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(
                          Icons.search,
                          size: 50,
                          color: Colors.white,
                        ),
                        Text(
                          "Tìm Sản Phẩm",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed("/order_view"),
                  child: Container(
                      width: Get.width * 0.6,
                      height: Get.height * 0.2,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.shopping_cart,
                            size: 50,
                            color: Colors.white,
                          ),
                          Text(
                            "Đơn Hàng",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
                ),
                InkWell(
                  onTap: () => Get.toNamed('/user'),
                  child: Container(
                      width: Get.width * 0.6,
                      height: Get.height * 0.2,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                          Text(
                            "Nhân Viên",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
