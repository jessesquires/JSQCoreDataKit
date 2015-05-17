Pod::Spec.new do |s|
   s.name = 'JSQCoreDataKit'
   s.version = '1.1.0'
   s.license = 'MIT'

   s.summary = 'A swifter Core Data stack'
   s.homepage = 'https://github.com/jessesquires/JSQCoreDataKit'
   s.documentation_url = 'http://jessesquires.com/JSQCoreDataKit'

   s.social_media_url = 'https://twitter.com/jesse_squires'
   s.authors = { 'Jesse Squires' => 'jesse.squires.developer@gmail.com' }

   s.source = { :git => 'https://github.com/jessesquires/JSQCoreDataKit.git', :tag => s.version }
   s.source_files = 'JSQCoreDataKit/JSQCoreDataKit/*.swift'

   s.platform = :ios, '8.0'
   s.frameworks = 'Foundation', 'CoreData'
   s.requires_arc = true
end
