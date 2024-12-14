import 'package:flutter/material.dart';

class PageSlider extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;
  final List<String> images;

  PageSlider({
    required this.pageController,
    required this.currentIndex,
    required this.images,
  });

  static void autoSlide(PageController controller, int currentIndex, void Function(int) setPageIndex) {
    Future.delayed(Duration(seconds: 3), () {
      if (controller.hasClients) {
        int nextPage = currentIndex + 1;
        if (nextPage >= 3) nextPage = 0;
        controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setPageIndex(nextPage);
        autoSlide(controller, nextPage, setPageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: pageController,
        itemCount: images.length,
        onPageChanged: (index) => autoSlide(pageController, index, (pageIndex) {}),
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/${images[index]}',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
