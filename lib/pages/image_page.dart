import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;
  final String title;

  // Constructor to receive both image URL and title
  ImagePage({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Full Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title of the image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Full-size image
            GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                ); // Close the page when the image is tapped
              },
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 400, // Adjust height as needed
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/placeholder.jpg',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 400,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
