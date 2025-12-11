import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redraw/bloc/generator/image_generator_bloc.dart';

class EmptyStateSection extends StatelessWidget {
  const EmptyStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final imageGeneratorBloc = context.read<ImageGeneratorBloc>();

    return SafeArea(
      child: Column(
        spacing: 16,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                imageGeneratorBloc.add(
                  const ImageGeneratorEvent.pickImage(ImageSource.gallery),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF374151)),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    const Icon(Icons.photo_library),
                    Text('Choose from Gallery'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                imageGeneratorBloc.add(
                  const ImageGeneratorEvent.pickImage(ImageSource.camera),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF374151)),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    const Icon(Icons.photo_camera),
                    Text('Capture with Camera'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
