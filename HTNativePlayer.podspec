

Pod::Spec.new do |s|
  s.name             = 'HTNativePlayer'
  s.version          = '0.1.0'
  s.summary          = 'iOS原生播放器控件，支持本地视频和网络视频'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MrHT/HTNativePlayer.git'
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tao' => 'hantao@afanticat.com' }
  s.source           = { :git => 'https://github.com/MrHT/HTNativePlayer.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '10.0'

  s.source_files = 'HTNativePlayer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HTNativePlayer' => ['HTNativePlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Masonry'
  s.dependency 'MBProgressHUD'
  
  
end
