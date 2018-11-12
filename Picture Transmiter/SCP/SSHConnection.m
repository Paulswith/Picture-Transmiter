//
//  SSHConnection.m
//  File Transmiter
//
//  Created by Dobby on 2018/11/10.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "SSHConnection.h"


@interface SSHConnection()

//+ (NMSSHSession *)openConnectionWithHost:(NSString *)host username:(NSString *)username
//                                password:(NSString *)password errorOutput:(NSError * _Nullable __autoreleasing *)error;

@end

@implementation SSHConnection

- (instancetype)initWithConfig:(struct SSHConfig)config {

    NSError *initWithConfigError;
    SSHConnection *conncet = (SSHConnection *)[SSHConnection openConnectionWithSshConfig:config errorOutput:&initWithConfigError];
    if (initWithConfigError) {
        NSLog(@"%s__error:%@", __func__, initWithConfigError);
        return nil;
    }
    return conncet;
}

- (BOOL)sendLocalImageWithpath:(NSString *)localPath toRemotePath:(NSString *)remotePath
{
    BOOL isSuc =  [self.channel uploadFile:localPath to:remotePath];
    [self.channel closeShell];
    return isSuc;
}

+ (BOOL)pushFileWithWithConfig:(struct SSHConfig)config
                          from:(NSString *)localFilePath to:(NSString *)remotePath
                   errorOutput:(NSError * _Nullable __autoreleasing *)error
{
    NMSSHSession *scpSession = [self openConnectionWithSshConfig:config errorOutput:error];
    if (scpSession == nil) {
        [scpSession disconnect];
        return NO;
    }
    // 上传
    BOOL isSuc =  [scpSession.channel uploadFile:localFilePath to:remotePath];
    if (!isSuc) {
        if (error) {
        *error = [NSError errorWithDomain:@"SSHPushException"
                                     code:NMSSHChannelRequestShellError
                                 userInfo:@{ NSLocalizedDescriptionKey : @"远程服务器异常, 无网络或路径不存在."}];
        }
    }
    [scpSession disconnect];
    return isSuc;
}

+ (SSHConnectionType)isRemotePathValid:(NSString *)remotePath WithSshConfig:(struct SSHConfig)config errorOutput:(NSError *__autoreleasing *)error
{
    NMSSHSession *scpSession = [self openConnectionWithSshConfig:config errorOutput:error];
    if (scpSession == nil) {
        [scpSession disconnect];
        return sshConnectionTypeConnectFaild;
    }
    
    NSString *retExec = [scpSession.channel execute:[NSString stringWithFormat:@"ls -al %@",remotePath] error:error timeout:@20];
    NSLog(@"isRemotePathValid: %@",retExec);
    
    if ([retExec isEqualToString:@""]) {
        return sshConnectionTypeErrorPath;
    }
    [scpSession disconnect];
    return sshConnectionTypeSucceed;
}

#pragma mark --- 内置方法

/**
 连接启动器:
 */
+ (NMSSHSession *)openConnectionWithSshConfig:(struct SSHConfig)config errorOutput:(NSError * _Nullable __autoreleasing *)error
{
    NMSSHSession *session = [NMSSHSession connectToHost:config.host withUsername:config.username];
    if (!session.isConnected) {
        if (error) {
            *error = [NSError errorWithDomain:@"SSHConnection"
                                         code:NMSSHChannelAllocationError
                                     userInfo:@{ NSLocalizedDescriptionKey : @"连接失败"}];
        }
        return nil;
    }
    // 密码鉴权
    [session authenticateByPassword:config.password];
    if (!session.isAuthorized) {
        if (error) {
            *error = [NSError errorWithDomain:@"SSHAuthPassword"
                                         code:NMSSHChannelRequestShellError
                                     userInfo:@{ NSLocalizedDescriptionKey : @"密码授权失败"}];
        }
        return nil;
    }
    return session;
}


@end
