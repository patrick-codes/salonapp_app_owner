// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'appointment_bloc.dart';

sealed class AppointmentEvent {}

class CreateAppointmentEvent extends AppointmentEvent {
  final double? amount;
  final String? userId;
  final String? shopName;
  final String? category;
  final TimeOfDay? appointmentTime;
  final DateTime? appointmentDate;
  final String? phone;
  final String? servicesType;
  final String? bookingCode;
  final String? img;
  final String? location;

  CreateAppointmentEvent({
    required this.amount,
    this.userId,
    required this.shopName,
    required this.category,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.phone,
    required this.servicesType,
    this.bookingCode,
    required this.img,
    this.location,
  });
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String id;
  DeleteAppointmentEvent({
    required this.id,
  });
}

class ViewAppointmentEvent extends AppointmentEvent {}

class ViewSingleAppointmentEvent extends AppointmentEvent {
  final String? id;

  ViewSingleAppointmentEvent(this.id);
}

class SearchAppointmentEvent extends AppointmentEvent {
  final String query;

  SearchAppointmentEvent({required this.query});
}

class AppointmentsUpdatedEvent extends AppointmentEvent {
  final List<AppointmentModel> appointmentModel;
  final int unreadCount;

  AppointmentsUpdatedEvent(
      {required this.appointmentModel, required this.unreadCount});
}

class MarkAppointmentsAsSeenEvent extends AppointmentEvent {}
