part of 'appointment_bloc.dart';

sealed class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentsLoadingState extends AppointmentState {}

class AppointmentsFetchedState extends AppointmentState {
  final List<AppointmentModel?>? appointment;
  final int unreadCount;

  AppointmentsFetchedState(this.appointment, {this.unreadCount = 0});
}

class SingleAppointmentsFetchedState extends AppointmentState {
  final List<AppointmentModel>? appointment;

  SingleAppointmentsFetchedState(this.appointment);
}

class AppointmentsFetchFailureState extends AppointmentState {
  final String errorMessage;

  AppointmentsFetchFailureState({required this.errorMessage});
}

class AppointmentCreatedSuccesState extends AppointmentState {
  final String message;
  final String code;

  AppointmentCreatedSuccesState({
    required this.message,
    required this.code,
  });
}

class AppointmentCodeCreatedSuccesState extends AppointmentState {
  final String code;

  AppointmentCodeCreatedSuccesState({
    required this.code,
  });
}

class AppointmentCreateFailureState extends AppointmentState {
  final String error;

  AppointmentCreateFailureState({required this.error});
}

class AppointmentDeletedSuccesState extends AppointmentState {
  final String message;

  AppointmentDeletedSuccesState({
    required this.message,
  });
}

class AppointmentDeletedFailureState extends AppointmentState {
  final String message;

  AppointmentDeletedFailureState({required this.message});
}

class SearchSuccesState extends AppointmentState {
  final String message;

  SearchSuccesState({required this.message});
}

class SeachFailureState extends AppointmentState {
  final String error;

  SeachFailureState({required this.error});
}

class EmptyAppointmentState extends AppointmentState {
  final String message;

  EmptyAppointmentState({required this.message});
}
