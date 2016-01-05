# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

target 'Tripfinger' do
use_frameworks!

#pod 'ScoutMaps-iOS-SDK'
pod "MDCSwipeToChoose"
pod 'Alamofire', '3.1.4'
pod 'RealmSwift', '0.97.0'
pod 'BrightFutures'

end

target 'TripfingerTests' do

end


post_install do |installer|
  puts("Update debug pod settings to speed up build time")
  Dir.glob(File.join("Pods", "**", "Pods*{debug,Private}.xcconfig")).each do |file|
    File.open(file, 'a') { |f| f.puts "\nDEBUG_INFORMATION_FORMAT = dwarf" }
  end
end
