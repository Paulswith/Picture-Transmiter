//
//  SSHConnection.h
//  File Transmiter
//
//  Created by Dobby on 2018/11/10.
//  Copyright © 2018 dobby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>

NS_ASSUME_NONNULL_BEGIN
struct SSHConfig {
    NSString *host;
    NSString *username;
    NSString *password;
};

// 连接SSH状态类型:
typedef NS_ENUM(NSInteger, SSHConnectionType) {
    sshConnectionTypeSucceed,
    sshConnectionTypeConnectFaild,
    sshConnectionTypeErrorPath,
    sshConnectionTypeUnknow
};

@interface SSHConnection : NMSSHSession

- (instancetype)initWithConfig:(struct SSHConfig)config;
- (BOOL)sendLocalImageWithpath:(NSString *)localPath toRemotePath:(NSString *)remotePath;

+ (NMSSHSession *)openConnectionWithSshConfig:(struct SSHConfig)config errorOutput:(NSError * _Nullable __autoreleasing *)error;
+ (BOOL)pushFileWithWithConfig:(struct SSHConfig)config
                        from:(NSString *)localFilePath
                          to:(NSString *)remotePath// 避免覆盖, 自己加个时间的后缀~
                 errorOutput:(NSError *__autoreleasing *)error;
// 检测目录是否存在:
+ (SSHConnectionType)isRemotePathValid:(NSString *)remotePath WithSshConfig:(struct SSHConfig)config errorOutput:(NSError *__autoreleasing *)error;




@end

NS_ASSUME_NONNULL_END
