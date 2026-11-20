platform :ios, '15.0'

target 'LaTeX-Draft' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LaTeX-Draft
  pod 'iosMath'
  pod 'UIColor_Hex_Swift', '~> 5.1.7'

  target 'LaTeX-DraftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LaTeX-DraftUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  # Keep pod targets buildable alongside the app's iOS 15 deployment target.
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
