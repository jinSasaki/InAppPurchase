Pod::Spec.new do |s|
  s.name             = "InAppPurchaseStubs"
  s.version          = "2.8.0"
  s.summary          = "Stub for InAppPurchase, Supporting application tests."
  s.homepage         = "https://github.com/jinSasaki/InAppPurchase"
  s.license          = 'MIT'
  s.author           = "Jin Sasaki"
  s.source           = { :git => "https://github.com/jinSasaki/InAppPurchase.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sasakky_j'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'InAppPurchaseStubs/Stubs'
  s.dependency 'InAppPurchase'
end
