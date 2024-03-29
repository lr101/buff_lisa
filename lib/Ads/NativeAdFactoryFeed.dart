import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {

  /// Test-id: ca-app-pub-3940256099942544/6300978111
  /// My id: ca-app-pub-6127949856398876/8680349496
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6127949856398876/8680349496';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// Test-id android: ca-app-pub-3940256099942544/2247696110
  /// Test-id ios: ca-app-pub-3940256099942544/3986624511
  /// My id android: ca-app-pub-6127949856398876/6756823923
  /// My id ios: ca-app-pub-6127949856398876/9475880203
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6127949856398876/6756823923';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6127949856398876/9475880203';
    }
    throw UnsupportedError("Unsupported platform");
  }
}

class CustomAdWidget extends StatefulWidget {
  const CustomAdWidget({super.key});

  @override
  State<StatefulWidget> createState() => CustomAdWidgetState();
}

class CustomAdWidgetState extends State<CustomAdWidget>  with AutomaticKeepAliveClientMixin<CustomAdWidget>{
  BannerAd? ad;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Padding(
      padding: const EdgeInsets.all(10),
        child:getFiller()
      )
    );
  }

  Widget getFiller() {
    if (ad != null) {
      return Container(
        width: ad!.size.width.toDouble(),
        height: 100.0,
        alignment: Alignment.center,
        child: AdWidget(ad: ad!),
      );
    } else {
      return const Center(
        child: SizedBox(
          width: 100.0,
          height: 100.0,
          child: CircularProgressIndicator(),
        )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {addAd();});
  }

  Future<void> addAd() {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            this.ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  @override
  bool get wantKeepAlive => true;

}
