import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redraw/bloc/auth/auth_bloc.dart';
import 'package:redraw/bloc/generator/image_generator_bloc.dart';
import 'package:redraw/bloc/navigation/navigation_bloc.dart';
import 'package:redraw/repository/auth_repository.dart';
import 'package:redraw/repository/image_repository.dart';

final locator = GetIt.instance;

void inject() {
  initServices();
  initRepository();
  initBloc();
}

void initServices() {
  locator.registerSingleton(FirebaseAuth.instance);
  locator.registerSingleton(FirebaseFirestore.instance);
  locator.registerSingleton(FirebaseStorage.instance);
  locator.registerSingleton(FirebaseFunctions.instance);

  locator.registerFactory(() => ImagePicker());
}

void initRepository() {
  locator.registerSingleton<ImageRepository>(
    DefaultImageRepository(
      firestore: locator(),
      functions: locator(),
      storage: locator(),
    ),
  );
  locator.registerSingleton<AuthRepository>(
    DefaultAuthRepository(auth: locator()),
  );
}

void initBloc() {
  locator.registerFactory(() => AuthBloc(authRepository: locator()));
  locator.registerFactory(
    () => ImageGeneratorBloc(imagePicker: locator(), repository: locator()),
  );
  locator.registerFactory(() => NavigationBloc());
}
