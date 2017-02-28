Pod::Spec.new do |s|
  s.name         = 'MOLFCMClient'
  s.version      = '1.2'
  s.platform     = :osx, '10.9'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/google/macops-molfcmclient'
  s.authors      = { 'Google Macops' => 'macops-external@google.com' }
  s.summary      = 'A macOS ObjC client for receiving and acknowledging FCM messages'
  s.source       = { :git => 'https://github.com/google/macops-molfcmclient.git',
                     :tag => "v#{s.version}" }
  s.source_files = 'MOLFCMClient/*.{h,m}'
  s.dependency 'MOLAuthenticatingURLSession', '~> 2.1'
end
