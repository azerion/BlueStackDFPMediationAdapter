Pod::Spec.new do |s|

s.name = 'BlueStackDFPMediationAdapter'
s.version = '1.0.0'
s.static_framework = true
s.license = 'MIT'
s.summary = 'BlueStack Mediation adapter of Google Mobile Ads SDK'
s.homepage = 'https://developers.bluestack.app/'
s.authors = { 'Azerion' => 'https://www.azerion.com/contact/' }
s.source = { :git => 'https://github.com/azerion/BlueStackDFPMediationAdapter.git', :tag => "#{s.version}" }
s.source_files = 'BlueStackDFPMediationAdapter.xcframework/*/*/Headers/*.{h}'
s.documentation_url = 'https://developers.bluestack.app/ios/mediation-adapters/dfp-adapter-ios'
s.swift_version = '5'
s.ios.deployment_target = '13.0'
s.vendored_frameworks = 'BlueStackDFPMediationAdapter.xcframework'
s.dependency 'Google-Mobile-Ads-SDK', '10.10.0'
s.dependency 'BlueStack-SDK', '4.3.0'