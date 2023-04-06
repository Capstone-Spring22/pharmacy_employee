import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/service/app_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Better Health',
      logoTag: 'logoTag',
      logo: const AssetImage('assets/icon.png'),
      onLogin: (loginData) async {
        return await AppService().loginUser(loginData.name, loginData.password);
      },
      userType: LoginUserType.name,
      userValidator: (value) =>
          value!.length < 3 ? 'Username must be at least 3 characters' : null,
      theme: LoginTheme(
        primaryColor: context.theme.primaryColor,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
      ),
      hideForgotPasswordButton: true,
      onSubmitAnimationCompleted: () {
        Get.toNamed('/home');
      },
      onRecoverPassword: (v) {
        return null;
      },
    );
  }
}
