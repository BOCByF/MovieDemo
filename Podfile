# Uncomment the next line to define a global platform for your project
 platform :ios, '16.4'

target 'MovieDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Ignore all warnings from all pods
  inhibit_all_warnings!

  # Pods for MovieDemo
  pod 'Toast-Swift', '~> 5.0.1'

  target 'MovieDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MovieDemoUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
                 end
            end
     end
  end

end
