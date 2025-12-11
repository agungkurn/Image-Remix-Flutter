import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redraw/bloc/auth/auth_bloc.dart';
import 'package:redraw/bloc/generator/image_generator_bloc.dart';
import 'package:redraw/bloc/navigation/navigation_bloc.dart';
import 'package:redraw/firebase_options.dart';
import 'package:redraw/injection.dart';
import 'package:redraw/theme/colors.dart';
import 'package:redraw/widgets/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  inject();
  await locator.allReady();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(
        value: locator.get<AuthBloc>()..add(AuthEvent.signInAnonymously()),
      ),
      BlocProvider.value(value: locator.get<ImageGeneratorBloc>()),
      BlocProvider.value(value: locator.get<NavigationBloc>()),
    ],
    child: MaterialApp(
      title: 'Redraw',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: accentPrimary,
          onPrimary: textOnAccent,
          secondary: accentSecondary,
          onSecondary: textOnAccent,
          error: errorColor,
          onError: onErrorColor,
          surface: backgroundPrimary,
          onSurface: textPrimary,
          tertiary: surfaceContainer,
          onTertiary: textPrimary,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state.user != null) {
            return HomePage();
          } else if (state.errorMessage?.isNotEmpty == true) {
            return Center(child: Text(state.errorMessage!));
          } else {
            return SizedBox();
          }
        },
      ),
    ),
  );
}
