// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';

class AppointmentModel {
  late String? id;
  late double? amount;
  late String? userId;
  late String? ownerID;
  late String? shopName;
  late String? category;
  late TimeOfDay? appointmentTime;
  late DateTime? appointmentDate;
  late String? phone;
  late String? servicesType;
  late String? bookingCode;
  late String? imgUrl;
  late String? location;

  AppointmentModel({
    this.id,
    this.amount,
    this.userId,
    this.ownerID,
    this.shopName,
    this.category,
    this.appointmentTime,
    this.appointmentDate,
    this.phone,
    this.servicesType,
    this.bookingCode,
    this.imgUrl,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "userId": userId,
      "ownerID": ownerID,
      "shopName": shopName,
      "category": category,
      "appointmentTime": appointmentTime,
      "appointmentDate": appointmentDate,
      "phone": phone,
      "servicesType": servicesType,
      "bookingCode": bookingCode,
      "imgUrl": imgUrl,
      "location": location,
    };
  }

  AppointmentModel.defaultModel() {
    id = null;
    amount = 0.0;
    userId = "userId";
    ownerID = "ownerID";
    shopName = "shopName";
    category = "category";
    appointmentTime =
        Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
    appointmentDate = DateTime.now();
    phone = "phone";
    servicesType = "servicesType";
    bookingCode = "bookingCode";
    imgUrl = "imgUrl";
    location = "location";
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return AppointmentModel(
      id: id,
      amount: data["amount"] ?? 0.0,
      userId: data["userId"] ?? '',
      ownerID: data["ownerID"] ?? '',
      shopName: data["shopName"] ?? '',
      category: data["category"] ?? '',
      appointmentTime: parseTimeOfDay(data["appointmentTime"]),
      appointmentDate: (data["appointmentDate"] as Timestamp?)?.toDate(),
      phone: data["phone"] ?? '',
      servicesType: data["servicesType"] ?? '',
      bookingCode: data["bookingCode"] ?? '',
      imgUrl: data["imgUrl"] ?? '',
      location: data["location"] ?? '',
    );
  }

  factory AppointmentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.exists) {
      final data = document.data()!;
      return AppointmentModel(
        id: document.id,
        amount: data["amount"] ?? 0.0,
        userId: data["userId"] ?? '',
        ownerID: data["ownerID"] ?? '',
        shopName: data["shopName"] ?? '',
        category: data["category"] ?? '',
        appointmentTime: parseTimeOfDay(data["appointmentTime"]),
        appointmentDate: (data["appointmentDate"] as Timestamp?)?.toDate(),
        phone: data["phone"] ?? '',
        servicesType: data["servicesType"] ?? '',
        bookingCode: data["bookingCode"] ?? '',
        imgUrl: data["imgUrl"] ?? '',
        location: data["location"] ?? '',
      );
    } else {
      print('Document not found for id: ${document.id}');
      return AppointmentModel.defaultModel();
    }
  }
}

TimeOfDay? parseTimeOfDay(dynamic value) {
  if (value == null || value is! String) return null;
  final parts = value.split(":");
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}
