MN Notes: 2022-12-07

1. run pod install

2. sudo chmod a+w '/Library/Input Methods'

3. Open .xcworkspace (not .xcproject)

4. To mark this directory as deletable by the build system, run `xattr -w com.apple.xcode.CreatedByBuildSystem true '/Library/Input Methods'` when it is created.

5. Remove lPod-Fire in General->Frameworks, Libraries and Embedded Content

6. Build and the Fire.app will be installed in /Library/Input Methods

