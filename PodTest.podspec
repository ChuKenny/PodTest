Pod::Spec.new do |s|

    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    #  These will help people to find your library, and whilst it
    #  can feel like a chore to fill in it's definitely to your advantage. The
    #  summary should be tweet-length, and the description more in depth.
    #

    s.name         = "PodTest"  # 名字
    s.version      = "0.0.4"  # 版本号
    s.summary      = "iOS 静态列表页面编写的抽象库(Objective-C实现)"  # 简单介绍
    s.homepage     = "https://github.com/zhujunggsddu/PodTest"  # 项目主页，一般是 github 仓库地址即可
    s.license      = "Sogou"  # 版权声明
    s.author       = { "zhuqunye" => "zhuqunye@126.com" }  # 作者信息
    s.platform     = :ios, "7.0"  # 支持的平台及版本
    s.source       = { :git => "https://github.com/zhujunggsddu/PodTest.git", :tag => s.version }  # 项目地址，不支持 ssh
    s.source_files  = "PodTest","PodTest/statistical/SogouPlus/SogouPlus/*.{h,m}"  # 代码源文件位置 
    s.requires_arc = true  # 是否使用 ARC
end
