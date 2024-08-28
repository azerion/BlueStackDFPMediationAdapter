# BlueStackDFPMediationAdapter

In this repository there are two sample apps. The sample app in `SampleApp-using-spm` folder uses Swift Package Manager to integrate `BlueStackDFPMediationAdapter` and another sample app in `SampleApp-using-cocoapods` folder uses Cocoapods. Both projects have two targets, one of them is Swift and another one is Objective-C example.


To integrate `BlueStackDFPMediationAdapter` follow the instructions [here](https://developers.bluestack.app/ios/mediation-adapters/gam-adapter-ios).

## Supported ad formats
- Banners
- Interstitials
- Native Ads
- Rewarded Video
## Requirements
- Use Xcode 13 or higher
- Target iOS 12.2 or higher

## Running the SampleApp using SPM

- Go to the `SampleApp-using-spm` folder and open BlueStackDFPMediationDemo.xcodeproj.
- Select project file --> Package Dependencies --> Add(+) --> Search for https://github.com/azerion/BlueStackDFPMediationAdapter.
- Add `BlueStackDFPMediationAdapter` package to the target you want to run.

## Running the SampleApp using Cocoapdos
- Open terminal app.
- Go to the `BlueStackDFPMediationDemo` folder in your terminal.
- Execute `pod install --repo-update`.
- Open BlueStackDFPMediationDemo.xcworkspace and build the target.