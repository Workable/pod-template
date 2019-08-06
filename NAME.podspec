Pod::Spec.new do |s|
  s.name             = '${POD_NAME}'
  s.version          = '0.1.0'
  s.summary          = 'Module named ${POD_NAME} for use in Workable iOS.'
  s.homepage         = 'https://github.com/Workable/'
  s.author           = { '${USER_NAME}' => '${USER_EMAIL}' }
  s.source           = { :git => 'https://github.com/Workable/workable-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  test_sources = '${POD_NAME}/Tests/**/*'

  s.source_files = '${POD_NAME}/Main/**/*'
  # s.exclude_files = test_sources

  s.script_phase = {
    :name => 'R Swift',
    :script => '"$PODS_ROOT/R.swift/rswift" generate --accessLevel public "$PODS_TARGET_SRCROOT/${POD_NAME}/Main/Sources/Autogenerated/R.generated.swift"',
    :input_files => ['$TEMP_DIR/rswift-lastrun'],
    :output_files => ['$PODS_TARGET_SRCROOT/${POD_NAME}/Main/Sources/Autogenerated/R.generated.swift'],
    :execution_position => :before_compile
  }

  s.script_phase = {}
  
  s.resources = ['${POD_NAME}/**/*.{xib,storyboard,xcassets}']

  s.test_spec 'Tests' do |test_spec|
    test_spec.ios.deployment_target = '11.0'
    test_spec.source_files = test_sources
    test_spec.requires_app_host = true
    test_spec.dependency 'Quick'
    test_spec.dependency 'Nimble'
    test_spec.dependency 'Nimble-Snapshots'
  end
end
