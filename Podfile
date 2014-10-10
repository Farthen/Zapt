source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
pod 'CocoaLumberjack'
#pod 'TUSafariActivity', '~> 1.0.0'
pod 'AFNetworking'
pod 'NSDate-Extensions'
pod 'TMCache', :head
pod 'NHCalendarActivity'
pod 'VTAcknowledgementsViewController', '~> 0.12'
pod 'UICKeyChainStore'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'Zapt/Support/Pods-acknowledgements.plist', :remove_destination => true)
end

