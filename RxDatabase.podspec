Pod::Spec.new do |s|
  s.name             = 'RxDatabase'
  s.version          = '0.1.0'
  s.summary          = 'Wrapper for YapDatabase using RxSwift'


  s.description      = <<-DESC
  Wrapper for YapDatabase using RxSwift.
                       DESC

  s.homepage         = 'https://github.com/hungdv136/rx.database'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hung Dinh' => 'hungdv136@gmail.com' }
  s.source           = { :git => 'https://github.com/hungdv136/rx.database.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hungdv136'

  s.ios.deployment_target = '9.0'

  s.source_files = '**.swift'

  s.dependency 'RxSwift', '~> 3.5.0'
  s.dependency 'RxCocoa', '~> 3.5.0'
  s.dependency 'YapDatabase', '~> 3.0'
end
