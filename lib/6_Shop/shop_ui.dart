
import 'package:buff_lisa/6_Shop/shop_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;

class ShopUI extends StatelessUI<ShopPage> {

  const ShopUI({super.key, required widget}) : super(widget: widget);

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
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                items: widget.images
              )
            )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: global.cThird),
                onPressed: widget.copyToClip,
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