# Picture-Transmiter
Using scp, remote copy pictures from mobileDevice to other machine whose machine has scp listening.


### depens
- `NMSSH`  using to scp, the core third-part.  before i found this, i have been compile the `libssh2` with arm64 arch, but it's too hard.
- `CTAssetsPickerController` using to select photo
- `MBProgressHUD` famous project to show tip message.
#### Usage:
just run `pod install` in project directory

### capability
1. copy image/video from iPhone/iPad to other machine which can listen scp(like mac, should go forward `Sharing->Remote Login` open it.)
2. can be select picture from system photos-Library or take a picture.
3. more capability will up...

### what's it like
![](profile/images/profile.png)
