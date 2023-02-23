import 'dart:math';

import 'package:buff_lisa/Ads/NativeAdFactoryFeed.dart';
import 'package:buff_lisa/Files/Widgets/custom_if_else.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class CustomNativeAd extends StatefulWidget {
  const CustomNativeAd({super.key});

  @override
  State<StatefulWidget> createState() => CustomNativeAdState();
}

class CustomNativeAdState extends State<CustomNativeAd>  with AutomaticKeepAliveClientMixin<CustomNativeAd>{
  NativeAd? myNative;



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox.square(
          dimension: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: myNative == null ? Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ) : AdWidget(ad: myNative!),
          )
        );
  }

  @override
  void dispose() {
    super.dispose();
    myNative != null ? myNative!.dispose() : "";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addAd();
    });
  }

  Future<void> addAd() async {
    NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'adFactoryExample',
      request: const AdRequest(),
      customOptions: {'brightness': Provider.of<ThemeProvider>(context, listen: false).currentBrightness},
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            myNative = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        }
      )
    ).load();
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

}