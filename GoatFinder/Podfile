# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

use_frameworks!

target 'GoatFinder' do
    pod 'RealmSwift'
    pod 'RealmMapView'

    pod 'Alamofire'
    pod 'SwiftyJSON'
end

post_install do |installer|
    `rm -rf Pods/Headers`
end


