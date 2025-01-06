import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyPostAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final void Function(String message, String? photoUrl) onPost;
  const MyPostAlertBox({
    super.key,
    required this.textController,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedPhotoUrl; // Holds the selected photo's URL

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            maxLength: 10000,
            maxLines: 3,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: "What's on your mind?",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              fillColor: Theme.of(context).colorScheme.secondary,
              filled: true,
              counterStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              // Simulate picking an image from the gallery or camera
              String? photoUrl =
                  await _pickPhoto(context); // Implement _pickPhoto
              if (photoUrl != null) {
                selectedPhotoUrl = photoUrl;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Photo selected successfully!')),
                );
              }
            },
            icon: const Icon(Icons.photo),
            label: const Text("Add Photo"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPost(textController.text.trim(), selectedPhotoUrl);
            textController.clear();
          },
          child: const Text("Post"),
        ),
      ],
    );
  }

  Future<String?> _pickPhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        // Convert the selected image to a File
        File file = File(image.path);

        // Create a unique file name
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload the image to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child("post_images/$fileName");
        UploadTask uploadTask = storageRef.putFile(file);

        // Wait for the upload to complete and get the download URL
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        return downloadUrl; // Return the image URL
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
        return null;
      }
    } else {
      return null; // No image selected
    }
  }
}
