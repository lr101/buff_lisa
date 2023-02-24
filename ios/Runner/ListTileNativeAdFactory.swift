// TODO: Import google_mobile_ads
import google_mobile_ads

// TODO: Implement ListTileNativeAdFactory
class ListTileNativeAdFactory : FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView

        (nativeAdView.headlineView as! UILabel).text = nativeAd.headline

        (nativeAdView.bodyView as! UILabel).text = nativeAd.body
        nativeAdView.bodyView!.isHidden = nativeAd.body == nil

        (nativeAdView.iconView as! UIImageView).image = nativeAd.icon?.image
        nativeAdView.iconView!.isHidden = nativeAd.icon == nil

        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        
        let brightness = customOptions?["brightness"]
        let color = brightness as! Bool ? UIColor(red: 1, green: 1, blue: 1, alpha: 1): UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        (nativeAdView.headlineView as! UILabel).textColor = color
        (nativeAdView.bodyView as! UILabel).textColor = color
        (nativeAdView.storeView as? UILabel)?.textColor = color
        (nativeAdView.priceView as? UILabel)?.textColor = color
        (nativeAdView.advertiserView as? UILabel)?.textColor = color
        
        
        nativeAdView.nativeAd = nativeAd

        return nativeAdView
    }
}
