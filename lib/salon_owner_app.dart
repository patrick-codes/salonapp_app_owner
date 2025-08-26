import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salonapp_app_owner/presentation/appointments/pages/appointments_page.dart';
import 'package:salonapp_app_owner/presentation/shops/pages/create_shopservice_page.dart';
import 'package:toastification/toastification.dart';
import 'helpers/constants/color_constants.dart';
import 'presentation/authentication/pages/login_screen.dart';
import 'presentation/authentication/pages/signup_screen.dart';
import 'presentation/home/pages/home.dart';
import 'presentation/intro/pages/splash screen/splash.dart';
import 'presentation/location/bloc/location_bloc.dart';

class SalonAppOwner extends StatelessWidget {
  const SalonAppOwner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (BuildContext context, state) {
        if (state is LocationSucces) {
          context.read<LocationBloc>()..add(LoadLocationEvent());
        }
      },
      builder: (BuildContext context, state) {
        return ToastificationWrapper(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hairvana Shop Manager',
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => HomePage(),
              '/createshop': (context) => const CreateShopPage(),
              '/appointment': (context) => AppointmentsPage(),

              // '/shopinfo': (context) => const ShopInfo(),
              // '/shops': (context) => ShopsPage(),
              // '/appointments': (context) => AppointmentsPage(),
            },
            // onGenerateRoute: (settings) {
            //   if (settings.name == '/createshop') {
            //     final args = settings.arguments as Map<String, dynamic>;
            //     return MaterialPageRoute(
            //       builder: (context) => CreateShopPage(
            //         lat: args['lat'],
            //         long: args['long'],
            //       ),
            //     );
            //   }
            //   // if (settings.name == '/map') {
            //   //   final args = settings.arguments as Map<String, dynamic>;
            //   //   return MaterialPageRoute(
            //   //     builder: (context) => MapDirectionScreen(
            //   //       cordinates: args['latlng'],
            //   //     ),
            //   //   );
            //   // }
            //   // if (settings.name == '/receipt') {
            //   //   final args = settings.arguments as Map<String, dynamic>;
            //   //   return MaterialPageRoute(
            //   //     builder: (context) => ReceiptPage(
            //   //       id: args['id'],
            //   //       name: args['name'],
            //   //       datetime: args['datetime'],
            //   //       amount: args['amount'],
            //   //       receiptId: args['receiptId'],
            //   //       phone: args['phone'],
            //   //       service: args['service'],
            //   //     ),
            //   //   );
            //   // }
            //   return null;
            // },
            theme: ThemeData(
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: primaryBg,
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
          ),
        );
      },
    );
  }
}
