//
//  DFPDemoViewController.m
//  DFPAdapter
//
//  Created by MacBook Pro on 01/10/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "DFPDemoViewController.h"
#import <BlueStackDFPMediationAdapter/BlueStackDFPMediationAdapter.h>
#import "GAdNativeAdBluestack.h"
#import <CoreLocation/CoreLocation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <BlueStackSDK/BlueStackSDK.h>

#define BANNER_AD_ADUNIT @"/40369895/71333//FR_DEMO_MNG_ADS_IOS_BANNER_TESTYIELD_IOS_V2"
#define INTERSTITIEL_AD_ADUNIT @"/40369895/71333//FR_DEMO_MNG_ADS_IOS_INTERTITIAL_TESTYIELD_IOS_V2"
#define SQUARE_AD_ADUNIT @"/40369895/71333//FR_DEMO_MNG_ADS_IOS_SQUARE_TESTYIELD_IOS_V2"
#define NATIVE_AD_ADUNIT @"/40369895/71333//FR_DEMO_MNG_ADS_iOS_native_testYieldiOS"
#define REWARD_AD_ADUNIT @"/40369895/71333//FR_DEMO_MNG_ADS_IOS_VIDEO_REWARD_testYieldIOS"

@interface DFPDemoViewController ()<MNGAdsSDKFactoryDelegate, CLLocationManagerDelegate,GADFullScreenContentDelegate,GADBannerViewDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate,GADNativeAdDelegate>
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property(nonatomic, strong) GADInterstitialAd *interstitial;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *squareView;
@property(nonatomic, strong) GADRewardedAd *rewardedAd;



@end
@implementation DFPDemoViewController{
    GADAdLoader* adLoader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"592345403c65df760b765678d0951151",@"EF48B4E6-93C3-446C-8684-7912C67EB3DB" ];
    // Do any additional setup after loading the view from its nib.
    self.nativeAdPlaceholder.hidden = YES;
    if (@available(iOS 14, *)) {
        if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusAuthorized) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [MNGAdsSDKFactory setDebugModeEnabled:YES];
                [MNGAdsSDKFactory setDelegate:self];
                [MNGAdsSDKFactory initWithAppId:@"3180317"];
            }];
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)requestInterstitial {
     [self resetAds];

    [BlueStackCustomEvent setViewController:self];
    
    GADRequest* request = [GADRequest request];
    BlueStackCustomEventMediationExtras *extras = [[BlueStackCustomEventMediationExtras alloc] initWithKeywords:@"target=mngadsdemo;version=4.0.0" customTargetingBlueStack:@{@"age" :@"25"}];
    [request registerAdNetworkExtras:extras];

    [GADInterstitialAd loadWithAdUnitID:INTERSTITIEL_AD_ADUNIT
                                 request:request
                      completionHandler:^(GADInterstitialAd *interstitialAd, NSError *error) {
        if (error) {
          NSLog(@"Failed to load an interstitial ad with error: %@", error.localizedDescription);
          return;
        }

            self.interstitial = interstitialAd;
            self.interstitial.fullScreenContentDelegate = self;
            if (self.interstitial != nil && [self.interstitial canPresentFromRootViewController:self error:nil]) {
                [self.interstitialButton setTitle:@"Show Interstitial" forState:UIControlStateNormal];
            }else{
                [self.interstitialButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
            }
       
    }];

   
}

#pragma mark -Create Interstitiel

- (IBAction)createInterstitial:(UIButton *)sender {
    self.nativeAdPlaceholder.hidden = YES;

    if (self.interstitial != nil && [self.interstitial canPresentFromRootViewController:self error:nil]) {
        [self.interstitial presentFromRootViewController:self];
    } else {
        [self requestInterstitial];
    }
    
}

#pragma mark GADInterstitialDelegate implementation


/// Tells the delegate that an impression has been recorded for the ad.
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad{
    
}

/// Tells the delegate that a click has been recorded for the ad.
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad{
    NSLog(@"NativeAd  GADFullScreenPresentingAd");

}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad{
    if ([ad isKindOfClass:GADInterstitialAd.class]) {
        self.interstitial = nil;
        [_interstitialButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
    }else if ([ad isKindOfClass:GADRewardedAd.class]) {
        self.rewardedAd = nil;
        [_rewardBtn setTitle:@"Load RewardVideo" forState:UIControlStateNormal];
    }else {
        NSLog(@"Not implemented: %@", ad);
    }
    
}


#pragma mark -Create Banner

- (void)resetAds {
    self.nativeAdPlaceholder.hidden = YES;
//    _bannerView = nil;
//    _squareView = nil;
    self.interstitial = nil;
}

- (IBAction)createBanner:(UIButton *)sender {
    //hide Native View
    [self resetAds];
    NSLog(@"createBanner");
    [self requestBanner];
    
}

- (GADRequest *)setupRequestBannerSquare {

    //  create Dfp Request
    GADRequest* request = [GADRequest request];
    BlueStackCustomEventMediationExtras *extras = [[BlueStackCustomEventMediationExtras alloc] initWithKeywords:@"target=mngadsdemo;version=4.0.0" customTargetingBlueStack:@{ @"age" :@"25",@"consent" :@"test",@"gender" :@"test2"}];
    [request registerAdNetworkExtras:extras];
    
    return request;
}

- (void)requestBanner {
    GADRequest * request = [self setupRequestBannerSquare] ;
    //create banner
    
    _bannerView.adUnitID = BANNER_AD_ADUNIT;
    _bannerView.delegate = self;
    _bannerView.rootViewController = self;
    _bannerView.adSize = GADAdSizeBanner;
    [_bannerView loadRequest:request];
}
- (IBAction)createSquare:(id)sender {
    GADRequest * request = [self setupRequestBannerSquare] ;
    //create Sqaure
    NSLog(@"createSquare");

    _squareView.adUnitID = SQUARE_AD_ADUNIT;
    _squareView.delegate = self;
    _squareView.rootViewController = self;
    _squareView.adSize = GADAdSizeMediumRectangle;
    [_squareView loadRequest:request];
}

/// Tells the delegate that a click has been recorded for the ad.
- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView{
    NSLog(@"NativeAd  bannerViewDidRecordClick");
}

#pragma mark - GADCustomEventBannerDelegate Delegate Methods


- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView{
    
    if (GADAdSizeEqualToSize(bannerView.adSize,GADAdSizeMediumRectangle)) {
        _squareView = bannerView;
    }else{
        _bannerView = bannerView;
    }
   
   
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)bannerView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull NSError *)error{
  
}

/// Tells the delegate that an impression has been recorded for an ad.
- (void)bannerViewDidRecordImpression:(nonnull GADBannerView *)bannerView{
    
}

#pragma mark Click-Time Lifecycle Notifications

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView{
   
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView{
    
}

/// Tells the delegate that the full screen view has been dismissed. The delegate should restart
/// anything paused while handling bannerViewWillPresentScreen:.
- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView{
    
}
- (void)adViewDidReceiveAd:(nonnull GADBannerView *)bannerView{
    
}



#pragma mark -Create NativeAd
- (IBAction)createNativeAd:(UIButton *)sender {
    [self resetAds];

    [BlueStackCustomEvent setViewController:self];
    GADNativeAdImageAdLoaderOptions *adViewOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    adViewOptions.shouldRequestMultipleImages = NO;
    adViewOptions.disableImageLoading = NO;

    adLoader = [[GADAdLoader alloc] initWithAdUnitID: NATIVE_AD_ADUNIT rootViewController:self adTypes:@[GADAdLoaderAdTypeNative] options:@[adViewOptions]];
    adLoader.delegate = self;

    GADRequest* request = [GADRequest request];

    BlueStackCustomEventMediationExtras * extras = [[BlueStackCustomEventMediationExtras alloc] initWithKeywords:@"target=mngadsdemo;version=4.0.0" customTargetingBlueStack:@{ @"age" :@"25"}];
    [request registerAdNetworkExtras:extras];
    [adLoader loadRequest:request];
    
}

- (void)replaceNativeAdView:(UIView *)nativeAdView inPlaceholder:(UIView *)placeholder {
  // Remove anything currently in the placeholder.
  NSArray *currentSubviews = [placeholder.subviews copy];
  for (UIView *subview in currentSubviews) {
    [subview removeFromSuperview];
  }

  if (!nativeAdView) {
    return;
  }

  // Add new ad view and set constraints to fill its container.
  [placeholder addSubview:nativeAdView];
  nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;

  NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(nativeAdView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
}
#pragma mark - Native Ad Delegates
/// Called when adLoader fails to load an ad.
- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didFailToReceiveAdWithError:(nonnull NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.nativeAdPlaceholder.hidden = YES;

}
/// Called after adL-oader has finished loading.
- (void)adLoaderDidFinishLoading:(nonnull GADAdLoader *)adLoader{

}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd{
    self.nativeAdPlaceholder.hidden = NO;
    // Create and place ad in view hierarchy.
    GAdNativeAdBluestack *nativeAdView =
        [[NSBundle mainBundle] loadNibNamed:@"GAdNativeAdBluestack" owner:nil options:nil]
            .firstObject;

    nativeAdView.nativeAd = nativeAd;
    UIView *placeholder = self.nativeAdPlaceholder;
    ;

    [self replaceNativeAdView:nativeAdView inPlaceholder:placeholder];
    nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    nativeAdView.mediaView.hidden = NO;
    [nativeAdView.mediaView setMediaContent:nativeAd.mediaContent];
    // Populate the native ad view with the native ad assets.
    // Some assets are guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                                 forState:UIControlStateNormal];

    // These assets are not guaranteed to be present, and should be checked first.
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    if (nativeAd.icon != nil) {
      nativeAdView.iconView.hidden = NO;
    } else {
      nativeAdView.iconView.hidden = YES;
    }
    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
    if (nativeAd.starRating) {
      nativeAdView.starRatingView.hidden = NO;
    } else {
      nativeAdView.starRatingView.hidden = YES;
    }

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    if (nativeAd.store) {
      nativeAdView.storeView.hidden = NO;
    } else {
      nativeAdView.storeView.hidden = YES;
    }

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    if (nativeAd.price) {
      nativeAdView.priceView.hidden = NO;
    } else {
      nativeAdView.priceView.hidden = YES;
    }

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    if (nativeAd.advertiser) {
      nativeAdView.advertiserView.hidden = NO;
    } else {
      nativeAdView.advertiserView.hidden = YES;
    }

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;
}
/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = numberOfStars.doubleValue;
  if (starRating >= 5) {
    return [UIImage imageNamed:@"stars_5"];
  } else if (starRating >= 4.5) {
    return [UIImage imageNamed:@"stars_4_5"];
  } else if (starRating >= 4) {
    return [UIImage imageNamed:@"stars_4"];
  } else if (starRating >= 3.5) {
    return [UIImage imageNamed:@"stars_3_5"];
  } else {
    return nil;
  }
}
/// Called when an impression is recorded for an ad. Only called for Google ads and is not supported
/// for mediated ads.
- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd{
    
}

/// Called when a click is recorded for an ad. Only called for Google ads and is not supported for
/// mediated ads.
- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd{

}

#pragma mark - Click-Time Lifecycle Notifications

/// Called before presenting the user a full screen view in response to an ad action. Use this
/// opportunity to stop animations, time sensitive interactions, etc.
///
/// Normally the user looks at the ad, dismisses it, and control returns to your application with
/// the nativeAdDidDismissScreen: message. However, if the user hits the Home button or clicks on an
/// App Store link, your application will be backgrounded. The next method called will be the
/// applicationWillResignActive: of your UIApplicationDelegate object.
- (void)nativeAdWillPresentScreen:(nonnull GADNativeAd *)nativeAd{
    
}

#pragma mark - Rewarded video

- (void)requestRewarded {
    [self resetAds];
    [BlueStackCustomEvent setViewController:self];
    GADRequest* request = [GADRequest request];
    BlueStackCustomEventMediationExtras * extras = [[BlueStackCustomEventMediationExtras alloc] initWithKeywords: @"target=mngadsdemo;version=4.0.0" customTargetingBlueStack:@{@"age" :@"25"}];
    [request registerAdNetworkExtras:extras];
    
    [GADRewardedAd
     loadWithAdUnitID:REWARD_AD_ADUNIT
     request:request
     completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            // Handle ad failed to load case.
            NSLog(@"Rewarded ad failed to load with error: %@", error.localizedDescription);
            return;
        }
        // Ad successfully loaded.
        NSLog(@"Rewarded ad loaded.");
        self.rewardedAd = ad;
        self.rewardedAd.fullScreenContentDelegate = self;
        if (self.rewardedAd != nil && [self.rewardedAd canPresentFromRootViewController:self error:nil]) {
            [self.rewardBtn setTitle:@"Show RewardVideo" forState:UIControlStateNormal];
        }else{
            [self.rewardBtn setTitle:@"Load RewardVideo" forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)createRewardedVideo:(id)sender {

    if (self.rewardedAd != nil && [self.rewardedAd canPresentFromRootViewController:self error:nil]) {
      [self.rewardedAd presentFromRootViewController:self
                            userDidEarnRewardHandler:^{
        GADAdReward *reward = self.rewardedAd.adReward;
        NSString *rewardMessage =
            [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
                                       [reward.amount doubleValue]];
        NSLog(@"%@", rewardMessage);
      }];
    } else {
      NSLog(@"Ad wasn't ready");
      [self requestRewarded];
    }
}
#pragma mark GADFullScreenContentDelegate implementation

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {

    NSLog(@"Ad failed to present full screen content with error %@.", [error localizedDescription]);
 
    
    NSString *fullScreenAdType = @"Full screen ad";;
      if ([ad isKindOfClass:[GADInterstitialAd class]]) {
          fullScreenAdType =  @"Interstitial ad";
              if (self.interstitial != nil && [self.interstitial canPresentFromRootViewController:self error:nil] ) {
                  [_interstitialButton setTitle:@"Show Interstitial" forState:UIControlStateNormal];
              }else{
                  [_interstitialButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
              }
          
      }
      if ([ad isKindOfClass:[GADRewardedAd class]]) {
              if (self.rewardedAd != nil && [self.rewardedAd canPresentFromRootViewController:self error:nil] ) {
                  [_rewardBtn setTitle:@"Show RewardVideo" forState:UIControlStateNormal];
              }else{
                  [_rewardBtn setTitle:@"Load RewardVideo" forState:UIControlStateNormal];
              }
      }
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSString *fullScreenAdType = [self getFullScreenAdType:ad];
  NSLog(@"%@ will present full screen content.", fullScreenAdType);
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSString *fullScreenAdType = @"Full screen ad";;
    if ([ad isKindOfClass:[GADInterstitialAd class]]) {
        fullScreenAdType =  @"Interstitial ad";
        self.interstitial = nil;
        [_interstitialButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
    }
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        fullScreenAdType =  @"Rewarded ad";
        self.rewardedAd = nil;
        [_rewardBtn setTitle:@"Load Reward Video" forState:UIControlStateNormal];
    }
}

- (NSString *)getFullScreenAdType:(nonnull id<GADFullScreenPresentingAd>)ad {
  if ([ad isKindOfClass:[GADInterstitialAd class]]) {
    return @"Interstitial ad";
  }
  if ([ad isKindOfClass:[GADRewardedAd class]]) {
    return @"Rewarded ad";
  }
  return @"Full screen ad";
}

#pragma mark MNGAdsSDKFactoryDelegate
-(void)MNGAdsSDKFactoryDidFinishInitializing{
    NSLog(@"MNGAds sucess initialization");

}


-(void)MNGAdsSDKFactoryDidFinishAdaptersInitializing:(BlueStackInitializationStatus *)blueStackInitializationStatus{
    for (BlueStackAdapterStatus* blueStackAdapterStatus in blueStackInitializationStatus.adaptersStatus) {
        NSString* message = [NSString  stringWithFormat:@"adapter name %@ has this status %lu with description %@ ", blueStackAdapterStatus.provider , (unsigned long)blueStackAdapterStatus.state, blueStackAdapterStatus.descriptionStatus] ;
        NSLog(@"%@", message);
    }
}

-(void)MNGAdsSDKFactoryDidFailInitializationWithError:(NSError *)error {
    NSLog(@"MNGAds failed initialization");

}
@end
