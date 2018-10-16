platform :osx, '10.13'
inhibit_all_warnings!

target 'MultiSSH' do
    pod 'NMSSH'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts "#{target.name}"
    end
end