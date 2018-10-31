# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TwilioFlyover' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'FlyoverKit', '~> 1.0.0'
  # Pods for TwilioFlyover

  target 'TwilioFlyoverTests' do
    inherit! :search_paths
    # Pods for testing
  end
  post_install do |installer|
      # Find bitcode_strip
      bitcode_strip_path = `xcrun -sdk iphoneos --find bitcode_strip`.chop!
      
      # Find path to TwilioVideo dependency
      path = Dir.pwd
      framework_path = "TwilioVideo/TwilioVideo.framework/TwilioVideo"
      
      # Strip Bitcode sections from the framework
      strip_command = "#{bitcode_strip_path} #{framework_path} -m -o #{framework_path}"
      puts "About to strip: #{strip_command}"
      system(strip_command)
  end
  target 'TwilioFlyoverUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
