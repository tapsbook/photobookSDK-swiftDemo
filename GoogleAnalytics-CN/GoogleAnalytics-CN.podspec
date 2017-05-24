
Pod::Spec.new do |s|
  s.name     = 'GoogleAnalytics-CN' 
  s.version  = '3.14.0' 
  s.license  = "MIT"
  s.summary  = 'Google Analytics - measure your app performance'
  s.description = 'Google Analytics lets you track application events you care about and gain insights from discovery and installation to conversion and engagement'
  s.homepage = 'https://github.com/CaryGo/GoogleAnalytics-CN'
  s.authors      = { 'Cary' => 'guojiashuang@live.com' } 
  s.source   = { :git => 'https://github.com/CaryGo/GoogleAnalytics-CN.git', :tag => s.version.to_s }
  s.platform = :ios 
  s.source_files = 'GoogleAnalytics/Headers/Public/*.h'
  s.public_header_files = 'GoogleAnalytics/Headers/Public/*.h'
  s.vendored_libraries = "GoogleAnalytics/Libraries/libGoogleAnalytics.a"
  s.libraries = "sqlite3","z"
  s.frameworks = "CoreData","SystemConfiguration"
  s.requires_arc = true
end