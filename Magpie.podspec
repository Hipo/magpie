#
# Be sure to run `pod lib lint Magpie.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'Magpie'
  s.version               = '2.4.0'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/Hipo/magpie'
  s.summary               = 'Standardized & Simplified API layer for iOS'
  s.source                = { :git => 'https://github.com/Hipo/magpie.git', :tag => s.version.to_s }
  s.author                = { 'Hipo' => 'hello@hipolabs.com' }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  s.swift_version         = '5.0'
  s.default_subspec       = 'Core'

  s.subspec 'Alamofire' do |ss|
    ss.source_files = 'Magpie/Classes/Alamofire/*.swift'
    ss.dependency 'Alamofire', '~> 5.0.0-rc.3'
  end

  s.subspec 'Core' do |ss|
    ss.subspec 'API' do |sss|
      sss.source_files = 'Magpie/Classes/API/*.swift'
    end

    ss.subspec 'Endpoint' do |sss|
      sss.source_files = 'Magpie/Classes/Endpoint/*.swift'
    end

    ss.subspec 'NetworkMonitoring' do |sss|
      sss.source_files = 'Magpie/Classes/NetworkMonitoring/*.swift'
    end

    ss.subspec 'Request' do |sss|
      sss.source_files = 'Magpie/Classes/Request/*.swift'
    end

    ss.subspec 'Response' do |sss|
      sss.source_files = 'Magpie/Classes/Response/*.swift'
    end

    ss.subspec 'Utils' do |sss|
      sss.subspec 'Extensions' do |ssss|
        ssss.source_files = 'Magpie/Classes/Utils/Extensions/*.swift'
      end

      sss.subspec 'Logging' do |ssss|
        ssss.source_files = 'Magpie/Classes/Utils/Logging/*.swift'
      end

      sss.subspec 'Objects' do |ssss|
        ssss.source_files = 'Magpie/Classes/Utils/Objects/*.swift'
      end

      sss.subspec 'Serializing' do |ssss|
        ssss.source_files = 'Magpie/Classes/Utils/Serializing/*.swift'
      end
    end
  end

  s.subspec 'HIPAuthorization' do |ss|
    ss.source_files = 'Magpie/Classes/HIPAuthorization/*.swift'
    ss.dependency 'Valet', '~> 3.2'
  end

  s.subspec 'HIPExceptions' do |ss|
    ss.source_files = 'Magpie/Classes/HIPExceptions/*.swift'
  end

  s.subspec 'HIPModels' do |ss|
    ss.source_files = 'Magpie/Classes/HIPModels/*.swift'
    ss.dependency 'Magpie/HIPExceptions'
  end
end
