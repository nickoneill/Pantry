Pod::Spec.new do |s|
  s.name = 'Storage'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Opinionated serialization for structs'
  s.homepage = 'https://github.com/nickoneill/Storage'
  s.social_media_url = 'https://twitter.com/objctoswift'
  s.authors = { "Nick O'Neill" => 'nick.oneill@gmail.com' }
  s.source = { :git => 'https://github.com/nickoneill/Storage.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Storage/*.swift'

  s.requires_arc = true
end
