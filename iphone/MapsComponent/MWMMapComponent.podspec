#
# Be sure to run `pod lib lint MWMMapComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MWMMapComponent'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MWMMapComponent.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/prebenl/MWMMapComponent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Private', :file => 'LICENSE' }
  s.author           = { 'Preben Ludviksen' => 'prebenl@gmail.com' }
  s.source           = { :git => 'https://github.com/prebenl/MWMMapComponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MapsComponent/**/*.{m,h,mm,hpp,cpp,c}', '../../**/*.{hpp,cpp}'
#  s.libraries = 'map'
  s.vendored_libraries = '/Users/prebenl/tripfinger/omim-iphone-debug-i386/out/debug/libmap.a'
  s.pod_target_xcconfig = {
'HEADER_SEARCH_PATHS' => '/Users/prebenl/tripfinger/tripfinger-mobile/ /Users/prebenl/tripfinger/tripfinger-mobile/3party/boost /Users/prebenl/tripfinger/tripfinger-mobile/3party/glm',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'RELEASE',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }

  # s.resource_bundles = {
  #   'MWMMapComponent' => ['MWMMapComponent/Assets/*.png']
  # }

s.library = 'c++'

 #s.public_header_files = '../../**/*.{h,hpp}'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
