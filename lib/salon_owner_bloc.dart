import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/appointments/bloc/appointment_bloc.dart';
import 'presentation/authentication/bloc/auth_bloc.dart';
import 'presentation/location/bloc/location_bloc.dart';
import 'presentation/shops/bloc/shops_bloc.dart';
import 'salon_owner_app.dart';

class SalonAppOwnerBlocs extends StatelessWidget {
  const SalonAppOwnerBlocs({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(AppStartedEvent()),
        ),
        BlocProvider(
          create: (context) => LocationBloc()..add(LoadLocationEvent()),
        ),
        BlocProvider(
          create: (context) => AppointmentBloc()..add(ViewAppointmentEvent()),
        ),
        BlocProvider(
          create: (context) =>
              ShopsBloc(context.read<LocationBloc>())..add(ViewShopsEvent()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppointmentBloc()..add(ViewAppointmentEvent()),
          ),
        ],
        child: SalonAppOwner(),
      ),
    );
  }
}
