import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../notifications/components/local notification/local_notification_service.dart';
import '../components/auth_exception.dart';
import '../repository/create_account_helper.dart';
import '../repository/data model/user_model.dart';
import '../repository/user_helper.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

part 'auth_events.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  final _auth = FirebaseAuth.instance;
  File? _image;
  bool isLoading = false;
  String imageUrl = '';

  AuthBloc() : super(AuthInitial()) {
    on<AppStartedEvent>(onAppStarted);
    on<ToggleCheckboxEvent>(checkBox);
    // on<PickImageEvent>(pickImage);
    // on<PickWorkImagesEvent>(pickWorkImages);
    on<SignupEvent>(registerUser);
    on<LoginEvent>(loginUser);
    on<ForgotPasswordEvent>(resetPassword);
    on<LogoutEvent>(logoutUser);
    // on<LoginWithGoogleEvent>(loginWithGoogle);
  }
  void checkBox(ToggleCheckboxEvent event, Emitter<AuthState> emit) {
    emit(CheckboxState(isChecked: event.isBool));
  }

  Future<void> onAppStarted(
      AppStartedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('managerauthToken');
    debugPrint('Token retrieved on app start: $token');

    if (token != null && token.isNotEmpty) {
      debugPrint('User is logged in with token: $token');

      if (!emit.isDone) {
        emit(AuthenticatedState(message: 'Signup Succesful!!'));
      }
    } else {
      debugPrint('No token found, navigating to login.');
      if (!emit.isDone) {
        emit(UnAuthenticatedState());
      }
    }
  }

  // Future<void> pickImage(PickImageEvent event, Emitter<AuthState> emit) async {
  //   emit(ImageLoadingState());
  //   debugPrint("Image Loading......");

  //   try {
  //     final pickedFile =
  //         await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       emit(ImagePickSuccesState(imgUrl: _image));
  //     } else {
  //       emit(ImagePickFailureState(error: 'No image was selected'));
  //     }
  //   } catch (e) {
  //     ImagePickFailureState(error: e.toString());
  //     debugPrint("Error: $e");
  //   }
  // }

  // Future<void> pickWorkImages(
  //     PickWorkImagesEvent event, Emitter<AuthState> emit) async {
  //   emit(
  //       ImageLoadingState()); // you can reuse your loading state or create WorkImagesLoadingState
  //   debugPrint("Picking multiple images...");

  //   try {
  //     final pickedFiles = await ImagePicker().pickMultiImage();
  //     if (pickedFiles.isEmpty) {
  //       emit(ImagePickFailureState(error: 'No images selected'));
  //       return;
  //     }

  //     final urls = <String>[];
  //     for (final x in pickedFiles) {
  //       final fileId = await uploadImageToGoogleDrive(File(x.path));
  //       if (fileId != null) {
  //         await makeFilePublic(fileId);
  //         urls.add(getPublicImageUrl(fileId));
  //       }
  //     }

  //     if (urls.isEmpty) {
  //       emit(ImagePickFailureState(error: 'Upload failed'));
  //       return;
  //     }

  //     // keep your old success state if you have it…
  //     emit(MultipleImagePickSuccesState(imgUrls: urls));

  //     // …and also emit this new, explicit “uploaded” state with public URLs:
  //     emit(WorkImagesUploadedSuccessState(urls: urls));
  //   } catch (e) {
  //     emit(ImagePickFailureState(error: e.toString()));
  //     debugPrint("Error: $e");
  //   }
  // }

  // Future<AuthClient> getAuthClient() async {
  //   final serviceAccount = await rootBundle.loadString(
  //       'assets/animations/formidable-bank-325022-43d02766ad7a.json');
  //   final credentials =
  //       ServiceAccountCredentials.fromJson(json.decode(serviceAccount));

  //   final client = await clientViaServiceAccount(
  //     credentials,
  //     [drive.DriveApi.driveFileScope],
  //   );

  //   return client;
  // }

  // Future<String?> uploadImageToGoogleDrive(File? imageFile) async {
  //   final client = await getAuthClient();
  //   final driveApi = drive.DriveApi(client);

  //   var fileMetadata = drive.File();
  //   fileMetadata.name = imageFile!.path.split('/').last;
  //   fileMetadata.parents = ["1s7GvjUetBcrdoo0qHffuRRAQDshjiU3n"];

  //   var media = drive.Media(imageFile.openRead(), imageFile.lengthSync());

  //   var response =
  //       await driveApi.files.create(fileMetadata, uploadMedia: media);
  //   client.close();

  //   if (response.id != null) {
  //     print("Uploaded File ID: ${response.id}");
  //     return response.id;
  //   } else {
  //     print("Upload failed");
  //     return null;
  //   }
  // }

  // Future<void> makeFilePublic(String fileId) async {
  //   final client = await getAuthClient();
  //   final driveApi = drive.DriveApi(client);

  //   var permission = drive.Permission();
  //   permission.type = "anyone";
  //   permission.role = "reader";

  //   await driveApi.permissions.create(permission, fileId);
  //   print("File is now public.");
  //   client.close();
  // }

  // String getPublicImageUrl(String fileId) {
  //   return "https://drive.google.com/uc?id=$fileId";
  // }

  Future<void> registerUser(SignupEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());

      await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // if (_image != null) {
      //   String? fileId = await uploadImageToGoogleDrive(_image!);
      //   if (fileId != null) {
      //     await makeFilePublic(fileId);
      //     imageUrl = getPublicImageUrl(fileId);
      //     emit(ImageUrlSuccesState(imgUrl: imageUrl));
      //     debugPrint("Image URL: $imageUrl");
      //   }
      // }
      final user = UserModel(
        id: UserHelper.firebaseUser!.uid,
        fullname: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        profilePhoto: imageUrl ?? '',
      );

      await AccountHelper.createUser(user);

      emit(AuthenticatedState(message: 'Account Created Successfully!!'));
      debugPrint('Account Created Successfully!!');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Created Shop Owner Account",
        body: "Account Created Successfully!!",
        payload: "/appointments",
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('managerauthToken', _auth.currentUser!.uid);

      debugPrint('managerauthToken saved locally.');
      debugPrint('managerauthToken saved: ${_auth.currentUser!.uid}');
    } on FirebaseAuthException catch (error) {
      final exception =
          SignUpWithEmailAndPasswordFailure(error.message.toString());
      emit(AuthFailureState(errorMessage: exception.message));
      debugPrint(exception.message);
    } catch (e) {
      emit(AuthFailureState(errorMessage: 'Error: ${e.toString()}'));
      debugPrint('Error:${e.toString()}');
    }
  }

  Future<void> loginUser(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());

      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthenticatedState(message: 'Login Succesful!!'));
      debugPrint('Login Succesful!!');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('managerauthToken', _auth.currentUser!.uid);

      debugPrint('managerauthToken saved locally.');
      debugPrint('managerauthToken saved: ${_auth.currentUser!.uid}');
    } on FirebaseAuthException catch (error) {
      final exception = SignUpWithEmailAndPasswordFailure(error.code);
      emit(AuthFailureState(errorMessage: exception.message));
      debugPrint("Firebase auth exception ${exception.message}");
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
      debugPrint('Error:${e.toString()}');
    }
  }

  Future<void> resetPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {}

  Future<void> logoutUser(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());

      await _auth.signOut();
      // await GoogleSignIn().signOut();

      emit(AuthLogoutSuccesState(message: 'User Logged out Succesfuly!!'));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('managerauthToken');
      debugPrint('User Logged out Succesfuly!!');
      debugPrint('managerauthToken removed !!');
    } on FirebaseAuthException catch (e) {
      emit(AuthLogoutFailureState(error: e.message.toString()));
      debugPrint('Logout Failed:${e.message}');
      throw e.message!;
    } on FormatException catch (e) {
      emit(AuthLogoutFailureState(error: e.message));
      debugPrint('Logout Failed:${e.message}');
      throw e.message;
    } catch (e) {
      emit(AuthLogoutFailureState(error: e.toString()));
      debugPrint('Logout Failed:$e');
      throw 'Unable to Logout. Try again';
    }
  }

  // Future<UserCredential> loginWithGoogle(
  //     LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
  //   try {
  //     emit(AuthLoadingState());

  //     // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     // final GoogleSignInAuthentication? googleAuth =
  //     //     await googleUser?.authentication;

  //     // final credential = GoogleAuthProvider.credential(
  //     //   accessToken: googleAuth?.accessToken,
  //     //   idToken: googleAuth?.idToken,
  //     // );

  //     emit(AuthLoadingState());
  //     // final auth = await FirebaseAuth.instance.signInWithCredential(credential);
  //     emit(AuthenticatedState(message: 'Login Succesful'));
  //     debugPrint('Login Succesful');
  //     // return auth;
  //   } on FirebaseAuthException catch (error) {
  //     final ex = Exception(error.code);
  //     emit(AuthFailureState(errorMessage: ex.toString()));
  //     debugPrint('Error: $ex');
  //     throw ex;
  //   } catch (_) {
  //     const excep = FirebaseAuthException;
  //     emit(AuthFailureState(errorMessage: excep.toString()));
  //     debugPrint('Exception $excep');
  //     throw excep;
  //   }
  // }
}
