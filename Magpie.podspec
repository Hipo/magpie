#
# Be sure to run `pod lib lint Magpie.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'Magpie'
  s.version               = '2.1.0'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/hipo/magpie'
  s.summary               = 'Standardized & Simplified API layer for iOS'
  s.source                = { :git => 'https://github.com/Hipo/magpie.git', :tag => s.version.to_s }
  s.author                = { 'Hipo' => 'hello@hipolabs.com' }
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'
  s.swift_version         = '5.0'
  s.default_subspec       = 'Package'

  s.subspec 'Lite' do |lite|
      lite.source_files = 'Magpie/Classes/{Core,Endpoint,Error,Monitoring,Request,Response,Utilities}/*.swift'
  end

  s.subspec 'Package' do |package|
      package.source_files = 'Magpie/Classes/**/*.swift'
      package.dependency 'Alamofire', '~> 5.0.0-rc.2'
  end
end
