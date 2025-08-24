import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salonapp_app_owner/presentation/authentication/components/login_textediting_controllers.dart';
import 'package:toastification/toastification.dart';
import '../../../helpers/config/size_config.dart';
import '../../../helpers/constants/color_constants.dart';
import '../../../helpers/text style/text_style.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool isRememberme = false;
  bool isLoginScreen = true;
  bool isSigninScreen = false;
  bool? isChecked = false;
  bool isLoading = false;
  bool isToggeled = true;
  bool isVisible = true;
  bool isNotSelected = false;
  File? image;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  void _startShake() {
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  Future<void> showLoadingDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8.0),
              bottom: Radius.circular(8),
            ),
          ),
          content: Container(
            height: 190,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SpinKitSpinningLines(
                    lineWidth: 3,
                    size: 60,
                    color: blackColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Logging in...",
                    style: TextStyle(
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          toastification.show(
            showProgressBar: true,
            description: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  state.errorMessage,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            autoCloseDuration: const Duration(seconds: 7),
            style: ToastificationStyle.fillColored,
            type: ToastificationType.error,
          );
        } else if (state is AuthenticatedState) {
          Navigator.pushReplacementNamed(context, '/home');
          toastification.show(
            showProgressBar: false,
            description: Column(
              children: [
                Text(
                  state.message,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            autoCloseDuration: const Duration(seconds: 7),
            style: ToastificationStyle.fillColored,
            type: ToastificationType.success,
          );
        } else if (state is ImagePickSuccesState) {
          image = state.imgUrl;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 10,
                child: SizedBox(
                  height: SizeConfig.screenHeight,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: 80,
                      horizontal: 30,
                    ),
                    child: Center(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/undraw_barber_utly.svg',
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(height: 15),
                            PrimaryText(
                              alignment: TextAlign.center,
                              text: 'Hairvana Shop Management Admin',
                              size: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(height: 12),
                            PrimaryText(
                              text:
                                  'Log into your shop owner acount to manage your hairvana shop',
                              size: 13,
                              color: blackColor,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: LoginController.email,
                              style: TextStyle(fontSize: 14),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  print('Enter Email');
                                  return 'Enter Email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color: iconGrey,
                                ),
                                hintStyle: TextStyle(
                                  color: iconGrey,
                                  fontSize: 14,
                                ),
                                fillColor: whiteColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: whiteColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: LoginController.password,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Password';
                                } else if (LoginController
                                        .password.text.length <
                                    6) {
                                  return 'Password should be at least 6 characters ';
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: iconGrey,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: iconGrey,
                                  size: 20,
                                ),
                                suffixIcon: Icon(
                                  Icons.visibility,
                                  color: barBg,
                                  size: 20,
                                ),
                                fillColor: whiteColor,
                                // contentPadding:
                                //     EdgeInsets.only(left: 10, right: 5),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: whiteColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      sin(_controller.value * pi * 6) *
                                          _animation.value *
                                          1.5,
                                      0),
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();

                                    final email =
                                        LoginController.email.text.trim();
                                    final password =
                                        LoginController.password.text.trim();
                                    context.read<AuthBloc>().add(
                                          LoginEvent(
                                            email: email,
                                            password: password,
                                          ),
                                        );
                                  } else {
                                    _startShake();
                                  }
                                  // showLoadingDialog(context);
                                },
                                child: Container(
                                  height: 50,
                                  width: SizeConfig.screenWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: state is AuthLoadingState
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              PrimaryText(
                                                text: 'Logging into account..',
                                                size: 14,
                                                color: whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              SizedBox(width: 5),
                                              SizedBox(
                                                height: 15,
                                                width: 15,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : PrimaryText(
                                            text: 'Login',
                                            size: 14,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 35),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: PrimaryText(
                                text: 'Not registered? Register now',
                                size: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
