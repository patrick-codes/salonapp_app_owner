// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  late String? shopId;
  late String? shopOwnerId;
  late String? shopName;
  late String? category;
  late List<double?> cordinates = [];
  //late int? ratings;
  late String? openingDays;
  late String? operningTimes;
  late String? location;
  late String? phone;
  late String? whatsapp;
  late String? services;
  late String? profileImg;
  late String? dateJoined;
  late List<String>? workImgs;
  late double distanceToUser;
  late bool isOpen;

  ShopModel({
    this.shopId,
    this.shopOwnerId,
    required this.shopName,
    required this.category,
    required this.cordinates,
    required this.openingDays,
    required this.operningTimes,
    required this.location,
    required this.phone,
    required this.whatsapp,
    required this.services,
    required this.profileImg,
    required this.dateJoined,
    required this.workImgs,
    required this.distanceToUser,
    required this.isOpen,
  });

  Map<String, dynamic> toJson() {
    return {
      "shopId": shopId,
      "ownerID": shopOwnerId,
      "shopName": shopName,
      "category": category,
      "cordinates": List<dynamic>.from(cordinates.map((x) => x)),
      "openingDays": openingDays,
      "operningTimes": operningTimes,
      "location": location,
      "phone": phone,
      "whatsapp": whatsapp,
      "services": services,
      "profileImg": profileImg,
      "dateJoined": dateJoined,
      "workImgs": workImgs,
      "distanceToUser": distanceToUser,
      "isOpened": isOpen,
    };
  }

  ShopModel.defaultModel() {
    shopId = null;
    shopOwnerId = "ownerID";
    shopName = "shopName";
    category = "category";
    cordinates = [];
    openingDays = "openingDays";
    operningTimes = "operningTimes";
    location = "location";
    phone = "phone";
    whatsapp = "whatsapp";
    services = "services";
    profileImg = "profileImg";
    dateJoined = "dateJoined";
    workImgs = [];
    // distanceToUser = 0.0;
  }

  factory ShopModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.exists) {
      final data = document.data()!;
      return ShopModel(
        shopId: document.id,
        shopOwnerId: data["ownerID"] ?? '',
        shopName: data["shopName"] ?? '',
        category: data["category"] ?? '',
        cordinates: data["cordinates"] != null
            ? List<double>.from(data["cordinates"].map((x) => x.toDouble()))
            : [],
        openingDays: data["openingDays"] ?? '',
        operningTimes: data["operningTimes"] ?? '',
        location: data["location"] ?? '',
        phone: data["phone"] ?? '',
        whatsapp: data["whatsapp"] ?? '',
        services: data["services"] ?? '',
        profileImg: data["profileImg"] ?? '',
        dateJoined: data["dateJoined"] ?? '',
        workImgs:
            data["workImgs"] != null ? List<String>.from(data["workImgs"]) : [],
        distanceToUser: data["distanceToUser"] ?? 0,
        isOpen: data['isOpened'] ?? false,
      );
    } else {
      print('Document not found for id: ${document.id}');
      return ShopModel.defaultModel();
    }
  }
}
