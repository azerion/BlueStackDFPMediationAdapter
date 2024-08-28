import UIKit
import BlueStackSDK
import GoogleMobileAds
import AppTrackingTransparency
import BlueStackDFPMediationAdapter


class DFPDemoViewController: UIViewController, GADBannerViewDelegate, GADNativeAdDelegate, GADNativeAdLoaderDelegate, GADFullScreenContentDelegate {
    
    @IBOutlet weak var interButton: UIButton!
    @IBOutlet weak var squareView: GADBannerView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var rewardBtn: UIButton!
    
    var interstitial : GADInterstitialAd?
    var rewardedAd : GADRewardedAd?
    var adloader : GADAdLoader?
    
    @IBOutlet weak var nativeAdPlaceholder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the view controller
        BlueStackCustomEvent.viewController = self
        
        self.nativeAdPlaceholder.isHidden = true
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "YOUR_DEVICE_IDENTIFIER" ]
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        self.initializeBlueStackSDK()
                    }
                }
            })
        } else {
            self.initializeBlueStackSDK()
        }
    }
    
    private func initializeBlueStackSDK() {
        MNGAdsSDKFactory.setDebugModeEnabled(true)
        MNGAdsSDKFactory.setDelegate(self)
        MNGAdsSDKFactory.initWithAppId(Constants.appID)
    }
    // MARK: - reset ads
    func resetAds(){
        self.nativeAdPlaceholder.isHidden = true
        self.interstitial = nil
    }
    
    //MARK: - Prepare request
    func prepareRequest() -> GADRequest {
        
        let request = GADRequest()
        let keyword = "target=mngadsdemo;version=4.3.0"
        let json = ["age" :"25",
                    "consent" :"test",
                    "gender" :"testGender"]
        let extras  = BlueStackCustomEventMediationExtras(keywords: keyword, customTargetingBlueStack: json)
        request.register(extras)
        return request
        
    }
    // MARK: - Banner/Square
    @IBAction func createBanner(_ sender: UIButton) {
        
        self.resetAds()
        
        let request = self.prepareRequest()
        
        
        bannerView.adUnitID = Constants.Placements.BANNER_AD_ADUNIT
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.adSize = GADAdSizeBanner
        bannerView.load(request)
    }
    
    @IBAction func createSquare(_ sender: UIButton) {
        self.resetAds()
        
        let request = self.prepareRequest()
        
        squareView.adUnitID = Constants.Placements.SQUARE_AD_ADUNIT
        squareView.delegate = self
        squareView.rootViewController = self
        squareView.adSize = GADAdSizeBanner
        squareView.load(request)
        
    }
    
    // MARK: - GADBannerViewDelegate
    // Called when an ad request loaded an ad.
      func adViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("bannerViewDidReceiveAd")
          if GADAdSizeEqualToSize(bannerView.adSize, GADAdSizeMediumRectangle ) {
              self.squareView = bannerView
          } else {
              self.bannerView = bannerView
          }
      }

      // Called when an ad request failed.
    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
          print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
      }
    
    
    // MARK: - Native Ad
    @IBAction func createNativeAd(_ sender: UIButton) {
        
        self.resetAds()
        
        BlueStackCustomEvent.viewController = self
        let adViewOptions = GADNativeAdImageAdLoaderOptions()
        adViewOptions.shouldRequestMultipleImages = false
        adViewOptions.disableImageLoading = false;
        adloader = GADAdLoader(adUnitID:Constants.Placements.NATIVE_AD_ADUNIT , rootViewController: self, adTypes: [.native], options: [adViewOptions])
        
        let request = self.prepareRequest()
        adloader?.delegate = self
        adloader?.load(request)
        
    }
    
    func replaceNativeAdView(_ nativeAdView: UIView?, inPlaceholder placeholder: UIView) {
        // Remove anything currently in the placeholder.
        let currentSubviews = placeholder.subviews
        for subview in currentSubviews {
            subview.removeFromSuperview()
        }

        guard let nativeAdView = nativeAdView else {
            return
        }

        // Add new ad view and set constraints to fill its container.
        placeholder.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false

        let views: [String: UIView] = ["nativeAdView": nativeAdView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nativeAdView]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nativeAdView]|", options: [], metrics: nil, views: views))
    }

    
    // MARK: - GADnativeAdloader delegate
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAdPlaceholder.isHidden = false
        // Create and place ad in view hierarchy.
        guard let nativeAdView = Bundle.main.loadNibNamed("GAdNativeAdBluestack", owner: nil, options: nil)?.first as? GAdNativeAdBluestack else {
            return
        }
        
        nativeAdView.nativeAd = nativeAd
        
        self.replaceNativeAdView(nativeAdView, inPlaceholder: self.nativeAdPlaceholder)
        nativeAdView.mediaView?.contentMode = .scaleAspectFill
        nativeAdView.mediaView?.isHidden = false
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        // Populate the native ad view with the native ad assets.
        // Some assets are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        // These assets are not guaranteed to be present, and should be checked first.
        if let iconView = nativeAdView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
            iconView.isHidden = nativeAd.icon == nil
        }
        
        if let starRatingView = nativeAdView.starRatingView as? UIImageView {
            starRatingView.image = self.imageForStars(nativeAd.starRating)
            starRatingView.isHidden = nativeAd.starRating == nil
        }
        
        if let storeView = nativeAdView.storeView as? UILabel {
            storeView.text = nativeAd.store
            storeView.isHidden = nativeAd.store == nil
        }
        
        if let priceView = nativeAdView.priceView as? UILabel {
            priceView.text = nativeAd.price
            priceView.isHidden = nativeAd.price == nil
        }
        
        if let advertiserView = nativeAdView.advertiserView as? UILabel {
            advertiserView.text = nativeAd.advertiser
            advertiserView.isHidden = nativeAd.advertiser == nil
        }
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
    func imageForStars(_ numberOfStars: NSDecimalNumber?) -> UIImage? {
        guard let numberOfStars = numberOfStars else { return nil }
        let starRating = numberOfStars.doubleValue
        
        switch starRating {
        case 5:
            return UIImage(named: "stars_5")
        case 4.5..<5:
            return UIImage(named: "stars_4_5")
        case 4..<4.5:
            return UIImage(named: "stars_4")
        case 3.5..<4:
            return UIImage(named: "stars_3_5")
        default:
            return nil
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        NSLog("Native Ad did fail")
    }
    
    
    // MARK: - Interstitial
    @IBAction func createInterstitial(_ sender: UIButton) {
        if interstitial != nil {
            interstitial!.present(fromRootViewController:self)
        } else {
            self.requestInter()
        }
    }
    
    
    func requestInter() {
        self.resetAds()
        
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID:Constants.Placements.INTERSTITIEL_AD_ADUNIT,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial!.fullScreenContentDelegate = self
            self.interButton.setTitle("Show Interstitial", for: .normal)
        })
    }
    
  // MARK: - Interstitial : GADInterstitialDelegate  delegate
                               
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad.isKind(of: GADInterstitialAd.self) {
            interstitial = nil
            self.interButton.setTitle("Load Interstitial", for: .normal)
        } else if ad.isKind(of: GADRewardedAd.self) {
            rewardedAd = nil
            self.rewardBtn.setTitle("Load RewardVideo", for: .normal)
        }else {
            print("Not implemented: \(ad)")
        }
        
    }
    
    private func requestRewarded() {
        self.resetAds()
        BlueStackCustomEvent.viewController = self
        let request = self.prepareRequest()
        
        GADRewardedAd.load(withAdUnitID: Constants.Placements.REWARD_AD_ADUNIT, request: request) { ad, error in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            }else {
                print("Rewarded ad loaded.")
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                do {
                    try self.rewardedAd?.canPresent(fromRootViewController: self)
                    self.rewardBtn.setTitle("Show RewardVideo", for: .normal)
                }catch {
                    self.rewardBtn.setTitle("Load RewardVideo", for: .normal)
                }
            }
        }
    }
    
    @IBAction func createRewardedVideo(_ sender: UIButton) {
        if let rewardedAd = self.rewardedAd {
            do {
                try rewardedAd.canPresent(fromRootViewController: self)
                rewardedAd.present(fromRootViewController: self) {
                    let reward = rewardedAd.adReward
                    print("Reward received with currency \(reward.type) , amount \(reward.amount.doubleValue)")
                }
            }catch {
                print("Ad wasn't ready")
                self.requestRewarded()
            }
        }else {
            print("Ad wasn't ready")
            self.requestRewarded()
        }
    }
    
}


extension DFPDemoViewController: MNGAdsSDKFactoryDelegate {
    func mngAdsSDKFactoryDidFinishInitializing() {
        print("MNGAds sucess initialization");
    }
    
    func mngAdsSDKFactoryDidFinishAdaptersInitializing(_ blueStackInitializationStatus: BlueStackInitializationStatus!) {
        print("MNGAds Adapters sucess Initializing");
        for eachAdaptersStatus in blueStackInitializationStatus.adaptersStatus {
            print("adapter name \(String(describing: eachAdaptersStatus.provider)) has this state \(eachAdaptersStatus.state) with Description \(String(describing: eachAdaptersStatus.descriptionStatus))")
        }
    }

    func mngAdsSDKFactoryDidFailInitializationWithError(_ error:Error) {
        print("MNGAds failed initialization");
    }
}
