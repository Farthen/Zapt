platform :ios, '7.0'
pod 'CocoaLumberjack'
pod 'TUSafariActivity'
pod 'AFNetworking'
pod 'NSDate-Extensions'
pod 'TMCache', :head
pod 'NHCalendarActivity'
pod 'VTAcknowledgementsViewController'
pod 'UICKeyChainStore'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'Zapt/Support/Pods-acknowledgements.plist', :remove_destination => true)
end

