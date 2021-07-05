Pod::Spec.new do |s|
   s.name = 'JSQCoreDataKit'
   s.version = '9.0.3'
   s.license = 'MIT'

   s.summary = 'A swifter Core Data stack'
   s.homepage = 'https://github.com/jessesquires/JSQCoreDataKit'
   s.documentation_url = 'https://jessesquires.github.io/JSQCoreDataKit'
   s.social_media_url = 'https://twitter.com/jesse_squires'
   s.author = 'Jesse Squires'

   s.source = { :git => 'https://github.com/jessesquires/JSQCoreDataKit.git', :tag => s.version }
   s.source_files = 'Sources/*.swift'

   s.swift_version = '5.4'

   s.ios.deployment_target = '14.0'
   s.tvos.deployment_target = '14.0'
   s.watchos.deployment_target = '6.0'
   s.osx.deployment_target = '10.14'

   s.frameworks = 'CoreData'
   s.requires_arc = true
end
