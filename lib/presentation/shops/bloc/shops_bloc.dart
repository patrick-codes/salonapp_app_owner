import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import '../../location/bloc/location_bloc.dart';
import '../repository/data rmodel/service_model.dart';
import '../repository/salonservices helper/fetch_services_helper.dart';
import 'package:googleapis/drive/v3.dart' as drive;

part 'shops_events.dart';
part 'shops_state.dart';

class ShopsBloc extends Bloc<ShopsEvent, ShopsState> {
  List<ShopModel>? serviceman;
  ShopModel? singleServiceMan;
  ShopModel? singleService;
  final LocationBloc locationBloc;
  List<ShopModel>? serviceman2 = [];
  List<ShopModel>? serviceman3 = [];
  static SalonServiceHelper salonHelper = SalonServiceHelper();
  int serviceNum = 0;
  int num = 0;
  int total = 0;
  File? _image;
  bool isLoading = false;
  String imageUrl = '';

  ShopsBloc(this.locationBloc) : super(ShopInitial()) {
    on<ViewShopsEvent>(fetchShops);
    on<SearchShopEvent>(searchShops);
    on<CreateShopEvent>(createShop);
    on<ViewSingleShopEvent>(fetchSingleShop);
    on<PickImageEvent>(pickImage);
    on<PickWorkImagesEvent>(pickWorkImages);
  }

  Future<void> pickImage(PickImageEvent event, Emitter<ShopsState> emit) async {
    emit(ImageLoadingState());
    debugPrint("Image Loading......");

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        emit(ImagePickSuccesState(imgUrl: _image));
        debugPrint("Image picked: $_image");
      } else {
        emit(ImagePickFailureState(error: 'No image was selected'));
        debugPrint("error: No image was selected");
      }
    } catch (e) {
      ImagePickFailureState(error: e.toString());
      debugPrint("Error: $e");
    }
  }

  Future<void> pickWorkImages(
      PickWorkImagesEvent event, Emitter<ShopsState> emit) async {
    emit(
        ImageLoadingState()); // you can reuse your loading state or create WorkImagesLoadingState
    debugPrint("Picking multiple images...");

    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isEmpty) {
        emit(ImagePickFailureState(error: 'No images selected'));
        return;
      }

      final urls = <String>[];
      for (final x in pickedFiles) {
        final fileId = await uploadImageToGoogleDrive(File(x.path));
        if (fileId != null) {
          await makeFilePublic(fileId);
          urls.add(getPublicImageUrl(fileId));
        }
      }

      if (urls.isEmpty) {
        emit(ImagePickFailureState(error: 'Upload failed'));
        return;
      }

      // keep your old success state if you have it…
      emit(MultipleImagePickSuccesState(imgUrls: urls));

      // …and also emit this new, explicit “uploaded” state with public URLs:
      emit(WorkImagesUploadedSuccessState(urls: urls));
    } catch (e) {
      emit(ImagePickFailureState(error: e.toString()));
      debugPrint("Error: $e");
    }
  }

  Future<AuthClient> getAuthClient() async {
    final serviceAccount = await rootBundle.loadString(
        'assets/animations/formidable-bank-325022-43d02766ad7a.json');
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(serviceAccount));

    final client = await clientViaServiceAccount(
      credentials,
      [drive.DriveApi.driveFileScope],
    );

    return client;
  }

  Future<String?> uploadImageToGoogleDrive(File? imageFile) async {
    final client = await getAuthClient();
    final driveApi = drive.DriveApi(client);

    var fileMetadata = drive.File();
    fileMetadata.name = imageFile!.path.split('/').last;
    fileMetadata.parents = ["1s7GvjUetBcrdoo0qHffuRRAQDshjiU3n"];

    var media = drive.Media(imageFile.openRead(), imageFile.lengthSync());

    var response =
        await driveApi.files.create(fileMetadata, uploadMedia: media);
    client.close();

    if (response.id != null) {
      print("Uploaded File ID: ${response.id}");
      return response.id;
    } else {
      print("Upload failed");
      return null;
    }
  }

  Future<void> makeFilePublic(String fileId) async {
    final client = await getAuthClient();
    final driveApi = drive.DriveApi(client);

    var permission = drive.Permission();
    permission.type = "anyone";
    permission.role = "reader";

    await driveApi.permissions.create(permission, fileId);
    print("File is now public.");
    client.close();
  }

  String getPublicImageUrl(String fileId) {
    return "https://drive.google.com/uc?id=$fileId";
  }

  void onSearchChanged(String query) {
    serviceman = serviceman2!
        .where((servicemen) => servicemen.shopName!
            .trim()
            .toLowerCase()
            .contains(query.trim().toLowerCase()))
        .toList();
  }

  Future<void> searchShops(
      SearchShopEvent event, Emitter<ShopsState> emit) async {
    try {
      emit(ShopsLoadingState());
      if (event.query.isNotEmpty) {
        onSearchChanged(event.query);
        emit(ShopsFetchedState(shop: serviceman!));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createShop(
      CreateShopEvent event, Emitter<ShopsState> emit) async {
    try {
      emit(ShopsLoadingState());
      debugPrint("Creating shop service......");
      final shop = ShopModel(
        shopOwnerId: event.shopOwnerId,
        shopName: event.shopName,
        category: event.category,
        openingDays: event.openingDays,
        operningTimes: event.operningTimes,
        location: event.location,
        phone: event.phone,
        whatsapp: event.whatsapp,
        services: event.services,
        profileImg: event.profileImg,
        dateJoined: event.dateJoined,
        workImgs: event.workImgs,
        cordinates: event.cordinates,
        distanceToUser: event.distanceToUser,
        isOpen: event.isOpen,
      );
      salonHelper.createService(shop);
      emit(
          ShopCreatedSuccesState(message: 'Shop service created succesfuly!!'));
      debugPrint("Shop service created succesfuly!!");
    } catch (e) {
      emit(ShopCreateFailureState(error: e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<List<ShopModel>?> fetchShops(
      ViewShopsEvent event, Emitter<ShopsState> emit) async {
    emit(ShopsLoadingState());
    try {
      final locationState = locationBloc.state;
      debugPrint("LocationBloc State: $locationState");

      if (locationState is LocationFetchedState) {
        double? userLatitude = locationState.latitude;
        double? userLongitude = locationState.longitude;
        debugPrint("✅ Location Fetched: $userLatitude, $userLongitude");

        serviceman =
            await salonHelper.fetchAllSalonShops(userLatitude, userLongitude);
        num = serviceman?.length ?? 0;
        serviceman2 = serviceman;
        serviceman3 = serviceman2;
        total = num;

        debugPrint("✅ Total Nearby Shops: $num");
        emit(ShopsFetchedState(shop: serviceman));

        if (userLatitude == null || userLongitude == null) {
          debugPrint("Error: Latitude or Longitude is null!");
          emit(ShopsFetchFailureState(
              errorMessage: "User location not available."));
        }
      } else {
        debugPrint("❌ Error: User location not available.");
        emit(ShopsFetchFailureState(
            errorMessage: "User location not available."));
      }
    } on FirebaseAuthException catch (error) {
      debugPrint("❌ Firebase Error: $error");
      emit(ShopsFetchFailureState(errorMessage: error.toString()));
    } catch (error) {
      debugPrint("❌ Error: $error");
      emit(ShopsFetchFailureState(errorMessage: error.toString()));
    }
    return serviceman;
  }

  Future<ShopModel?> fetchSingleShop(
      ViewSingleShopEvent event, Emitter<ShopsState> emit) async {
    try {
      String? userId = event.id;
      emit(ShopsLoadingState());
      singleServiceMan = await salonHelper.fetchSinglesalonshops(userId);

      if (singleServiceMan != null) {
        singleService = singleServiceMan;
        emit(SingleShopsFetchedState(shop: singleService));
        debugPrint("Single Shop: $singleService");
        total = serviceNum;
      } else {
        emit(ShopsFetchFailureState(errorMessage: "Shop not found"));
        debugPrint("Single Shop not found");
      }
      //}
      print(total);
    } on FirebaseAuthException catch (error) {
      emit(ShopsFetchFailureState(errorMessage: error.toString()));
      debugPrint(error.toString());
    } catch (error) {
      emit(ShopsFetchFailureState(errorMessage: error.toString()));
      debugPrint('Error:${error.toString()}');
    }

    return singleService;
  }
}
