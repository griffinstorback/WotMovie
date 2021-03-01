platform :ios, '13.0'
	
use_frameworks!

def appodeal
    pod 'APDAmazonAdsAdapter', '2.8.1.1' 
    pod 'APDAppLovinAdapter', '2.8.1.1' 
    pod 'APDBidMachineAdapter', '2.8.1.2' 
    pod 'APDChartboostAdapter', '2.8.1.1' 
    pod 'APDFacebookAudienceAdapter', '2.8.1.2' 
    pod 'APDGoogleAdMobAdapter', '2.8.1.1' 
    pod 'APDInMobiAdapter', '2.8.1.1' 
    pod 'APDIronSourceAdapter', '2.8.1.1' 
    pod 'APDMintegralAdapter', '2.8.1.1' 
    pod 'APDMyTargetAdapter', '2.8.1.1' 
    pod 'APDOguryAdapter', '2.8.1.1' 
    pod 'APDSmaatoAdapter', '2.8.1.1' 
    pod 'APDStartAppAdapter', '2.8.1.1' 
    pod 'APDTapjoyAdapter', '2.8.1.1' 
    pod 'APDTwitterMoPubAdapter', '2.8.1.1' 
    pod 'APDUnityAdapter', '2.8.1.1' 
    pod 'APDYandexAdapter', '2.8.1.1' 
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
