Pod::Spec.new do |s|
  s.name = 'MetaWear'
  s.version = '4.0.0'
  s.summary = 'MetaWear iOS SDK for sensor fusion and BLE communication'
  s.description = 'Official MetaWear iOS SDK providing sensor fusion, BLE communication, and device management capabilities'
  s.homepage = 'https://mbientlab.com/developers/metawear/ios/'
  s.license = { :type => 'Commercial', :file => 'LICENSE' }
  s.author = { 'MetaWear' => 'support@mbientlab.com' }
  s.source = { :path => '.' }
  
  s.platform = :ios, '14.0'
  s.swift_version = '5.1'
  
  # Framework files
  s.vendored_frameworks = 'MetaWear.framework'
  
  # Source files (if you have access to source)
  # s.source_files = 'MetaWear.framework/Headers/*.h'
  
  # Required system frameworks
  s.frameworks = 'CoreBluetooth', 'CoreMotion', 'Foundation'
  
  # Required system libraries
  s.libraries = 'c++'
  
  # Build settings
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/MetaWear',
    'OTHER_LDFLAGS' => '$(inherited) -framework MetaWear'
  }
  
  # Ensure the framework is properly linked
  s.preserve_paths = 'MetaWear.framework'
  
  # Module map for Swift integration
  s.module_map = 'MetaWear.framework/Modules/module.modulemap'
end 