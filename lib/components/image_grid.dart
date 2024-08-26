import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    int imageCount = imageUrls.length;
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: imageCount > 4 ? 4 : imageCount,
      itemBuilder: (context, index) {
        if (index == 3 && imageCount > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(imageUrls[index], fit: BoxFit.cover),
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+${imageCount - 3}',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Image.network(imageUrls[index], fit: BoxFit.cover);
        }
      },
    );
  }
}
