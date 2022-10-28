
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Files/global.dart' as global;

class ShopPage extends StatelessWidget {
  ShopPage({Key? key}) : super(key: key);

  final List<Image> images = [
    const Image(image: AssetImage('images/mona-shop-1.png'),),
    const Image(image: AssetImage('images/mona-shop-2.jpg'),),
    const Image(image: AssetImage('images/tornado-shop-1.jpg'),),
    const Image(image: AssetImage('images/tornado-shop-2.png'),),

  ];

  copyToClip() {
    Clipboard.setData(ClipboardData(text: global.shopUrl));
    Fluttertoast.showToast(
        msg: "Shop URL copied to clipboard",  // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            SizedBox (
              height: MediaQuery.of(context).size.height * 0.75 - global.barHeight,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.75 - global.barHeight - 20,
                    aspectRatio: 16/9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                items: images
              )
            )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: global.cThird),
                onPressed: () {
                  copyToClip();
                },
                child: SizedBox (
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        "PRESS TO COPY SHOP URL TO CLIPBOARD\n\nURL = https://www.etsy.com/de/shop/MonaSticker",
                        textAlign: TextAlign.center,
                      ),
                    ),
                )
            ),

          ],
        ),
      );
  }

}