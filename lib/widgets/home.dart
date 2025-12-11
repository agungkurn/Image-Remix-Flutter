import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:redraw/bloc/auth/auth_bloc.dart';
import 'package:redraw/bloc/generator/image_generator_bloc.dart';
import 'package:redraw/bloc/navigation/navigation_bloc.dart';
import 'package:redraw/utils/ui_state.dart';
import 'package:redraw/widgets/empty_state_section.dart';
import 'package:redraw/widgets/generated_image_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redraw'), centerTitle: true),
      body: BlocConsumer<ImageGeneratorBloc, ImageGeneratorState>(
        listener: (_, state) {
          final navBloc = context.read<NavigationBloc>();
          final authBloc = context.read<AuthBloc>();

          final originalFile = state.originalImageFile;
          final originalUrl = state.originalImageUrl ?? "";

          if (originalUrl.isEmpty && originalFile == null) {
            navBloc.add(NavigationEvent.toImagePicker());
          } else {
            navBloc.add(NavigationEvent.toImageGenerator());
          }

          SnackBar? snackbar;
          final event = state.uploadState == UiState.error
              ? ImageGeneratorEvent.upload(authBloc.state.user?.uid ?? '')
              : state.generationState == UiState.error
              ? ImageGeneratorEvent.generate(authBloc.state.user?.uid ?? '')
              : null;

          if (event != null) {
            snackbar = SnackBar(
              content: Text(
                state.errorMessage ?? 'An error occurred',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              showCloseIcon: true,
            );
          }

          final scaffoldMessenger = ScaffoldMessenger.of(context);
          if (snackbar != null) {
            scaffoldMessenger.showSnackBar(snackbar);
          } else {
            scaffoldMessenger.clearSnackBars();
          }
        },
        builder: (_, state) => BlocBuilder<NavigationBloc, NavigationState>(
          builder: (_, navState) {
            switch (navState) {
              case ImagePickerNavigationState():
                return EmptyStateSection();
              case ImageGeneratorNavigationState():
                return GeneratedImageSection();
              default:
                return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
