import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../repository/appointment service/appointment_service.dart';
import '../repository/data model/appointment_model.dart';

part 'appointment_events.dart';
part 'appointment_states.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  static AppointmentServiceHelper appointmentHelper =
      AppointmentServiceHelper();
  List<AppointmentModel?>? appointment;
  List<AppointmentModel>? appointmentList2;
  StreamSubscription? _appointmentSubscription;

  AppointmentModel? appointmentList;
  List<AppointmentModel>? appointments = [];
  final firebaseUser = FirebaseAuth.instance;
  AppointmentBloc() : super(AppointmentInitial()) {
    on<ViewAppointmentEvent>(_onViewAppointments);
    on<AppointmentsUpdatedEvent>(_onAppointmentsUpdated);
    on<SearchAppointmentEvent>(searchAppointment);
    on<DeleteAppointmentEvent>(deleteAppointment);
  }

  void onSearchChanged(String query) {
    appointmentList2 = appointments!
        .where((service) => service.shopName!
            .trim()
            .toLowerCase()
            .contains(query.trim().toLowerCase()))
        .toList();
  }

  Future<void> _onViewAppointments(
      ViewAppointmentEvent event, Emitter<AppointmentState> emit) async {
    emit(AppointmentsLoadingState());

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _appointmentSubscription?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('seen_appointment_ids') ?? [];

    _appointmentSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .where('ownerID', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      // Calculate unread count
      final unread = appointments.where((a) => !seenIds.contains(a.id)).length;

      add(AppointmentsUpdatedEvent(
        appointmentModel: appointments,
        unreadCount: unread,
      ));

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newAppointment =
              AppointmentModel.fromMap(change.doc.data()!, id: change.doc.id);

          if (!seenIds.contains(newAppointment.id)) {
            _showLocalNotification(newAppointment);
          }
        }
      }
    });
  }

  Future<void> searchAppointment(
      SearchAppointmentEvent event, Emitter<AppointmentState> emit) async {
    try {
      emit(AppointmentsLoadingState());
      if (event.query.isNotEmpty) {
        onSearchChanged(event.query);
        emit(AppointmentsFetchedState(appointmentList2));
      }
    } catch (e) {
      print(e);
    }
  }

  void _onAppointmentsUpdated(
      AppointmentsUpdatedEvent event, Emitter<AppointmentState> emit) {
    emit(AppointmentsFetchedState(event.appointmentModel,
        unreadCount: event.unreadCount));
  }

  void _showLocalNotification(AppointmentModel appointment) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'appointments_channel',
      'Appointments',
      channelDescription: 'Channel for appointment notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      appointment.hashCode,
      'New Appointment Alerts!b!!',
      'Received from ${appointment.phone ?? 'a client'}',
      notificationDetails,
    );
  }

  @override
  Future<void> close() {
    _appointmentSubscription?.cancel();
    return super.close();
  }

  Future<AppointmentModel?> deleteAppointment(
      DeleteAppointmentEvent event, Emitter<AppointmentState> emit) async {
    emit(AppointmentsLoadingState());
    try {
      if (event.id.isNotEmpty) {
        appointmentList =
            await appointmentHelper.deleteSingleAppointment(event.id);
        emit(AppointmentDeletedSuccesState(
            message: 'Appointment deleted succesfully'));
        debugPrint("Appointment deleted succesfully");
        emit(AppointmentsFetchedState(appointment));
      } else if (event.id.isEmpty) {
        emit(AppointmentDeletedFailureState(
            message: 'Deletion error: Appointment Id not found'));
        debugPrint("Deletion error: Appointment Id not found");
      }
    } on FirebaseAuthException catch (error) {
      emit(AppointmentDeletedFailureState(message: error.toString()));
      debugPrint("Deletion error:  ${error.toString()}");
    } catch (error) {
      emit(AppointmentDeletedFailureState(message: error.toString()));
      debugPrint("Deletion error: ${error.toString()}");
    }
    return appointmentList;
  }
}
