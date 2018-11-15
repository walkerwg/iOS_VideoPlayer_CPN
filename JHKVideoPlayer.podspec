#
# Be sure to run `pod lib lint JHKVideoPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JHKVideoPlayer'
  s.version          = '30.0.5'
  s.summary          = 'JHKVideoPlayer - A video player for JHK company.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a video player control written by Swift, which achieved a highly complete function and determined fully interface for user to make self-design.
                       DESC

  s.homepage         = 'https://gitee.com/steven2017/JHKVideoPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luis_gin' => 'hanqing93@gmail.com' }
  s.source           = { :git => 'https://github.com/walkerwg/Spec.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.pod_target_xcconfig = {
      'SWIFT_VERSION' => '4.1',
  }
  s.ios.deployment_target = '9.0'
  # s.source_files = 'JHKVideoPlayer/Classes/**/*'
  
  
  #-----------------------文件分级-------------------#
  s.default_subspec = 'AVPlayer'
  s.subspec 'AVPlayer' do |ss|
      ss.source_files = 'JHKVideoPlayer/Classes/AVPlayer/*.swift'
      ss.dependency 'JHKVideoPlayer/Category'
  end
  s.subspec 'Category' do |ss|
      ss.source_files = 'JHKVideoPlayer/Classes/Category/*.swift'
  end

  #-----------------------文件分级-------------------#
  
  s.resource_bundles = {
    'JHKVideoPlayer' => ['JHKVideoPlayer/Assets/**/*']
}
  # s.dependency 'Alamofire', '4.7.2'

end
