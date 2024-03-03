# TranslationService
沉浸式翻译本地大模型临时解决方案

## 1. 直接使用命令行
从源码编译后直接在命令行使用`/path/to/TranslationService`,或者从仓库的release下载编译后的二进制文件



## 2. 使用`launchctl`长期使用

1. 新建`TranslationService.plist`,并写入

    ```xml
       <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd
    ">
    <plist version="1.0">
        <dict>
            <key>KeepAlive</key>
            <dict>
                <key>SuccessfulExit</key>
                <false/>
            </dict>
            <key>Label</key>
            <string>TranslationService</string>
            <key>ProgramArguments</key>
            <array>
                <string>/Users/tinuv/Developer/Apple/TranslationService/TranslationService/TranslationService</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
        </dict>
    </plist>
    ```

    其中`/Users/tinuv/Developer/Apple/TranslationService/TranslationService/TranslationService`替换为自己的TranslationService路径

2. 将文件移动到`/Library/LaunchDaemons/`,`sudo mv /path/to/TranslationService.plist /Library/LaunchDaemons/TranslationService.plist`

3. 开机自启`sudo launchctl load -w  /Library/LaunchDaemons/TranslationService.plist`

4. 卸载自启动`sudo launchctl unload -w  /Library/LaunchDaemons/TranslationService.plist` 或直接删除此文件
