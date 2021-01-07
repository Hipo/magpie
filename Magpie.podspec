#
# Be sure to run `pod lib lint Magpie.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'Magpie'
  s.version               = '3.1.2'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/Hipo/magpie'
  s.summary               = 'Standardized & Simplified API layer for iOS'
  s.source                = { :git => 'https://github.com/Hipo/magpie.git', :tag => s.version.to_s }
  s.author                = { 'Hipo' => 'hello@hipolabs.com' }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.15'
  s.swift_version         = '5.0'
  s.default_subspec       = 'Core'

  s.subspec 'Alamofire' do |ss|
    ss.source_files = 'Magpie/Classes/Alamofire/*.swift'

    ss.dependency 'Magpie/Core'
    ss.dependency 'Alamofire', '~> 5.2'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'Magpie/Classes/Core/**/*.swift'

    ss.dependency 'Magpie/HIPUtils'
  end

  s.subspec 'HIPCore' do |ss|
    ss.source_files = 'Magpie/Classes/HIPCore/**/*.swift'

    ss.dependency 'Magpie/Alamofire'
    ss.dependency 'Magpie/HIPExceptions'
    ss.dependency 'Valet', '~> 4.1'
  end

  s.subspec 'HIPExceptions' do |ss|
    ss.source_files = 'Magpie/Classes/HIPExceptions/*.swift'

    ss.dependency 'Magpie/HIPUtils'
  end

  s.subspec 'HIPUtils' do |ss|
    ss.source_files = 'Magpie/Classes/HIPUtils/**/*.swift'
  end
end
