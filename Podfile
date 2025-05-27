# Uncomment this line to define a global platform for your project
platform :ios, '13.0' # Explicitly setting a more current platform

target 'On The Map' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for On The Map
  # Firebase has moved to more specific sub-pods.
  # pod 'Firebase' # This meta-pod is often replaced by specific components.
  # pod 'Firebase/Core' # FirebaseAnalytics includes FirebaseCore
  pod 'FirebaseAnalytics', '~> 10.22.0' # Core Firebase features + Analytics
  pod 'FirebaseDatabase', '~> 10.22.0'  # Realtime Database
  pod 'FirebaseAuth', '~> 10.22.0'      # Authentication
  pod 'GoogleSignIn', '~> 7.1.0'        # Google Sign-In

  target 'On The MapTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'On The MapUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
