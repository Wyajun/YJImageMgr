#YJImageMgr.podspec
Pod::Spec.new do |s|
  s.name         = "YJImageMgr"
  s.version      = "1.0.0"
  s.summary      = "图片资源管理工具"

  s.homepage     = "https://github.com/Wyajun/YJImageMgr"
  s.license      = 'MIT'
  s.author       = { "YaJun Wang" => "yajunst@163.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/Wyajun/YJImageMgr.git", :tag => s.version}
  s.source_files  = 'UpLoaderImage/YJImageMgr/*.{h,m}'
  s.requires_arc = true
end