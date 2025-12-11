import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:redraw/bloc/auth/auth_bloc.dart';
import 'package:redraw/bloc/generator/image_generator_bloc.dart';
import 'package:redraw/utils/ui_state.dart';
import 'package:shimmer/shimmer.dart';

class GeneratedImageSection extends StatelessWidget {
  const GeneratedImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final imageGeneratorBloc = context.read<ImageGeneratorBloc>();
    final authBloc = context.read<AuthBloc>();

    return BlocBuilder<ImageGeneratorBloc, ImageGeneratorState>(
      builder: (context, genState) {
        if (genState.originalImageUrl?.isEmpty == true) return SizedBox();

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  ImageSection(
                    original: genState.originalImageFile!,
                    generated: genState.generatedImageUrls,
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FooterSection(
                  generationState: genState.generationState,
                  uploadState: genState.uploadState,
                  onRetry: () {
                    imageGeneratorBloc.add(
                      ImageGeneratorEvent.generate(
                        authBloc.state.user?.uid ?? "",
                      ),
                    );
                  },
                  onRemoveImage: () {
                    imageGeneratorBloc.add(
                      const ImageGeneratorEvent.removeImage(),
                    );
                  },
                  onUpload: () {
                    imageGeneratorBloc.add(
                      ImageGeneratorEvent.upload(
                        authBloc.state.user?.uid ?? "",
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoadingState extends StatelessWidget {
  final String _text;

  const LoadingState({super.key, required String text}) : _text = text;

  @override
  Widget build(BuildContext context) => Shimmer(
    gradient: LinearGradient(colors: [Colors.grey, Colors.white24]),
    child: Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [Icon(Icons.auto_awesome), Text(_text)],
      ),
    ),
  );
}

class ImageSection extends StatelessWidget {
  final File original;
  final List<String> generated;

  const ImageSection({
    super.key,
    required this.original,
    required this.generated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Original'),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(original, fit: BoxFit.cover),
          ),
        ),
        if (generated.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generated Variations'),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: generated.length,
                  itemBuilder: (ctx, i) => AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generated[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class FooterSection extends StatelessWidget {
  final UiState generationState;
  final UiState uploadState;
  final Function() onRemoveImage;
  final Function() onUpload;
  final Function() onRetry;

  const FooterSection({
    super.key,
    required this.onRemoveImage,
    required this.onUpload,
    required this.onRetry,
    required this.generationState,
    required this.uploadState,
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (uploadState == UiState.loading)
        LoadingState(text: 'Uploading')
      else if (generationState == UiState.loading)
        LoadingState(text: 'Generating images')
      else
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FilledButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                onPressed: onRemoveImage,
                label: Text('Discard'),
                icon: Icon(Icons.delete),
              ),
            ),
            if (uploadState == UiState.idle || uploadState == UiState.error)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onUpload,
                  label: Text('Upload'),
                  icon: Icon(Icons.file_upload_outlined),
                ),
              )
            else if (generationState == UiState.error)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onRetry,
                  label: Text('Redraw'),
                  icon: Icon(Icons.auto_awesome),
                ),
              ),
          ],
        ),
    ],
  );
}
