platform :ios, '13.0'
	
use_frameworks!

def appodeal
    pod 'APDAmazonAdsAdapter', '2.9.1.1'
    pod 'APDAppLovinAdapter', '2.9.1.2'
    pod 'APDBidMachineAdapter', '2.9.1.2'
    pod 'APDFacebookAudienceAdapter', '2.9.1.2'
    pod 'APDGoogleAdMobAdapter', '2.9.1.2'
    pod 'APDInMobiAdapter', '2.9.1.1'
    pod 'APDMyTargetAdapter', '2.9.1.2'
    pod 'APDSmaatoAdapter', '2.9.1.1'
    pod 'APDStartAppAdapter', '2.9.1.2'
    pod 'APDTwitterMoPubAdapter', '2.9.1.1'
    pod 'APDUnityAdapter', '2.9.1.2'
    pod 'APDYandexAdapter', '2.9.1.3'
end

target 'WotMovie' do
    project 'WotMovie.xcodeproj'
    appodeal
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
