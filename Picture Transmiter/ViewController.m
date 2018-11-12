//
//  ViewController.m
//  File Transmiter
//
//  Created by dobby on 2018/11/9.
//  Copyright © 2018 dobby. All rights reserved.
//

// 超时逻辑需要做 - 测试连接成功时候需要保存1-2-3-4, 进入App需要清理图片:


#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "SSHConnection.h"
#import "FTCollectionViewCell.h"
#import "FTDataModel.h"
#import "FTInfoShower.h"
#import "MBProgressHUD.h"
#import "FTConfigSaver.h"

static NSString *CellIndentify = @"FTCollectionViewCell";
static NSString *connectString = @"Connect Suc!";
static NSString *tryConnect = @"tryConnect";
static NSInteger IMG_MAX = 9;

@interface ViewController ()<CTAssetsPickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *collectionViewHolder; // collection占位, 用来计算cell_item长宽
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
/* textFieds */
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *remotePathDirectory;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@property (assign) BOOL isConnectionSuc;
@property (assign) ActionSheetChooseType actionSheetType;
@property (strong, nonatomic) NSMutableArray<FTDataModel *> *imageDataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteItemFromNotification:)
                                                 name:NOTIFICATION_MARK object:nil];
    
    [_photosCollectionView registerClass:[FTCollectionViewCell class] forCellWithReuseIdentifier:CellIndentify];
    _photosCollectionView.dataSource = self;
    _photosCollectionView.delegate = self;
    // 隐藏键盘:
    [self customKeyBoardHidden];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 连接按钮长按事件:
    UILongPressGestureRecognizer *longPressgst = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reeditConfigs:)];
    longPressgst.minimumPressDuration = 1.2;
    [_connectBtn addGestureRecognizer:longPressgst];
    
    // 获取上次缓存数据:
    [self cacheWithLastConfig];
}

- (IBAction)selectPictureWithAlbum:(id)sender
{
    __weak typeof(self) weakself = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return; // 未授权
        dispatch_async(dispatch_get_main_queue(), ^{
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
            picker.showsSelectionIndex = YES;
            // 相册类型:
            picker.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                               @(PHAssetCollectionSubtypeAny),
                                               @(PHAssetCollectionSubtypeAlbumRegular)];
            picker.showsEmptyAlbums = NO;
            [weakself presentViewController:picker animated:YES completion:nil];
        });
        
    }];
}
- (IBAction)testConnect:(UIButton *)sender {
    // 连接成功, 拒绝编辑:
    if ([sender.titleLabel.text isEqualToString:connectString]) return;
    struct SSHConfig config = {[_ipTextField.text mutableCopy], [_usernameTextField.text mutableCopy], [_passwdTextField.text mutableCopy]};
    
#pragma mark - 需要封装下;block回调
    __weak typeof(self) weakself = self;
    NSString *dirText = _remotePathDirectory.text;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = NSLocalizedString(@"Connecting...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        for (float i=0.1; hud.progress< 1.0f; i += 0.05) {
            usleep(50000);
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.progress += 0.05f;
            });
        }
        SSHConnectionType retType = [SSHConnection isRemotePathValid:dirText WithSshConfig:config errorOutput:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            //
            NSString *showText;
            switch (retType) {
                case sshConnectionTypeSucceed:
                    showText = @"Connect Suc!";
                    [sender setTitle:connectString forState:UIControlStateNormal]; // 修改title
                    [weakself changeConfigEditable:NO]; // 让textField 不可编辑
                    [weakself dismissKeyBoard]; // 隐藏键盘
                    weakself.isConnectionSuc = YES; // 设置连接状态
                    [weakself saveSucConfig]; //存储连接成功的数据
                    
                    break;
                case sshConnectionTypeConnectFaild:
                    showText = @"Connect Faild! check server config";
                    break;
                case sshConnectionTypeErrorPath:
                    showText = @"Connect Faild! check remote path";
                    break;
                default:
                    showText = @"Connect Faild! Unknow Error!!";
                    break;
            }
            [FTInfoShower showToastWithMsg:showText inView:weakself.view];
        });
    });
}

- (IBAction)selectPictureWithCamera:(UIButton *)sender
{
    // 模拟器不支持打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"不支持摄像模式");
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setDelegate:self];
    [picker setAllowsEditing:YES]; // 允许编辑
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)sendSelectPictures:(UIButton *)sender
{
// 需要一个全局标志位控制是否成连接了配置:
    if (!_isConnectionSuc) {
        [FTInfoShower showToastWithMsg:@"You should test connect first!" inView:self.view];
        return;
    }
    if (self.imageDataArray.count <= 0) {
        [FTInfoShower showToastWithMsg:@"choose photo or take a picture!" inView:self.view];
        return;
    }
    
    struct SSHConfig config = {[_ipTextField.text mutableCopy], [_usernameTextField.text mutableCopy], [_passwdTextField.text mutableCopy]};
    NMSSHSession *sshSession = [SSHConnection openConnectionWithSshConfig:config errorOutput:nil];
    if (!sshSession) {
        [FTInfoShower showToastWithMsg:@"Connect server error!" inView:self.view];
        return;
    }
    
    // hud 处理:
    __weak typeof(self) weakself = self;
    __block NSInteger sucPushCout = 0, faildPushCount=0;
    NSMutableArray<FTDataModel *> *delArray = [NSMutableArray arrayWithCapacity:self.imageDataArray.count];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Uploading...";
    hud.detailsLabel.text = [NSString stringWithFormat:@"It has %ld photo should be upload",(unsigned long)self.imageDataArray.count];

    // 动画跟随展示:
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        for (NSInteger i=0; i < weakself.imageDataArray.count; i++) {

            FTDataModel *dModel = [weakself.imageDataArray objectAtIndex:i];
            NSString *localPath = dModel.imgPath;
            NSString *remoteName = [NSString stringWithFormat:@"%@.png", [weakself generateUniqueTimeFromat]];
            NSString *remotePath = [[weakself.remotePathDirectory.text mutableCopy] stringByAppendingPathComponent:remoteName];
            
            if (!localPath || [localPath isEqualToString:@""] || !remotePath || [remotePath isEqualToString:@""]) continue;
            BOOL isSuc = [sshSession.channel uploadFile:localPath to:remotePath];
            if (isSuc) {
                NSLog(@"发送图片成功, 删除元素: %@", remotePath);
                [delArray addObject:dModel];
                sucPushCout ++;
            } else {
                NSLog(@"发送图片失败.");
                faildPushCount ++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            for (FTDataModel *delModel in delArray) {
                for (NSInteger i=0; i < weakself.imageDataArray.count; i++) {
                    FTDataModel *orgModel = [weakself.imageDataArray objectAtIndex:i];
                    if ([orgModel isEqual:delModel]) {
                        [weakself.imageDataArray removeObject:orgModel];
                    }
                }
            }
            
            [sshSession disconnect];
            // 刷新:
            [weakself.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            [FTInfoShower showToastWithMsg:[NSString stringWithFormat:@"Succeed:%ld\nFaild:%ld", sucPushCout, faildPushCount] inView:weakself.view];
            [delArray removeAllObjects];
        });
    });
}

#pragma mark - ********** PICKER-Camera-DELEGATE **********
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSLog(@"info: %@", info);
    __weak typeof(self) weakself = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        // 发布:
        UIImage *imgPicker = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!imgPicker) return;
        [self appendDataArrayAndsaveImage:imgPicker localPath:nil];
        [weakself.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}

#pragma mark - ********** Photos-DELEGATE **********
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = IMG_MAX - _imageDataArray.count;
    if (picker.selectedAssets.count >= max){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                 message:[NSString stringWithFormat:@"最多选择%ld张",(unsigned long)IMG_MAX]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:nil]];
        [picker presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"assets.count: %ld", (unsigned long)assets.count);
    __weak typeof(self) weakself = self;
    for (NSInteger i=0; i < assets.count; i++) {
        // 图片预设置属性:
        CGFloat scale = [UIScreen mainScreen].scale;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        PHAsset *assetPhoto = [assets objectAtIndex:i];
        CGSize photoSize = CGSizeMake(assetPhoto.pixelWidth/scale, assetPhoto.pixelHeight/scale);
        // 获取图片:
        [[PHImageManager defaultManager] requestImageForAsset:assetPhoto targetSize:photoSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                NSString *filePath = [(NSURL *)[info objectForKey:@"PHImageFileURLKey"] path];
                [weakself appendDataArrayAndsaveImage:result localPath:filePath];
            }
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakself.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}


#pragma mark - ********** CollectonView-DATASOURCE **********
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageDataArray.count;
}

- (FTCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentify forIndexPath:indexPath];
    FTDataModel *dModel = [self.imageDataArray objectAtIndex:indexPath.row];
    NSLog(@"load data!");
    if (!cell) cell = [[FTCollectionViewCell alloc] init];
    // 每次都需要更新image 和 tag.
    [cell setDataImage:dModel.image andDeleteTag:indexPath.row];
    return cell;
}

#pragma mark - ********** CollectonView-LAYOUT **********
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 适配x转屏
    CGFloat width;
    CGFloat height;
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (currentOrientation == UIDeviceOrientationLandscapeRight || currentOrientation == UIDeviceOrientationLandscapeLeft) {
        width = (_collectionViewHolder.frame.size.width - IMG_MAX) / 9;
        height = _collectionViewHolder.frame.size.height;
    } else {
        width = (_collectionViewHolder.frame.size.width - IMG_MAX) / 3;
        height = (_collectionViewHolder.frame.size.height - IMG_MAX) / 3;
    }
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    //
    if (currentOrientation == UIDeviceOrientationLandscapeRight || currentOrientation == UIDeviceOrientationLandscapeLeft) {
        return IMG_MAX;
    }
    return IMG_MAX/3.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    // layout 间距
    return UIEdgeInsetsMake(1, 1, 2, 1);
}


#pragma mark - localFunc
- (NSMutableArray<FTDataModel *> *)imageDataArray {
    if (!_imageDataArray)
         _imageDataArray = [NSMutableArray arrayWithCapacity:IMG_MAX];
    return _imageDataArray;
}

/**
 接收通知, 删除照片
 */
- (void)deleteItemFromNotification:(id)info{
    NSNumber *tag = [[info userInfo] objectForKey:@"tag"];
//    NSLog(@"%s: %ld", __func__, [tag integerValue]);
    NSUInteger ntag = (NSUInteger)[tag integerValue];
    [_imageDataArray removeObjectAtIndex:ntag];
    [_photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

/**
 自定义键盘隐藏按钮
 */
- (void)customKeyBoardHidden {
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(2, 5, 100, 25)];
    [btn addTarget:self action:@selector(dismissKeyBoard) forControlEvents:UIControlEventTouchDown];
    [btn setImage:[UIImage imageNamed:@"packup"] forState:UIControlStateNormal];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    NSArray *btnArray = [NSArray arrayWithObjects:btnSpace, doneBtn, nil];
    [topView setItems:btnArray];
    [_ipTextField setInputAccessoryView:topView];
    [_usernameTextField setInputAccessoryView:topView];
    [_passwdTextField setInputAccessoryView:topView];
    [_remotePathDirectory setInputAccessoryView:topView];
}
/**
 隐藏键盘
 */
- (void)dismissKeyBoard {
    [_ipTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwdTextField resignFirstResponder];
    [_remotePathDirectory resignFirstResponder];
}

/**
 批量修改长按textField编辑能力
 */
- (void)changeConfigEditable:(BOOL)editable {
    for (UITextField *edit in @[_ipTextField, _usernameTextField, _passwdTextField, _remotePathDirectory]) {
        [edit setEnabled:editable];
    }
}

/**
 长按连接按钮, 修改textField可编辑
 */
- (void)reeditConfigs:(UIButton *)sender {
    [self changeConfigEditable:YES];
    _isConnectionSuc = NO;
    [_connectBtn setTitle:tryConnect forState:UIControlStateNormal];
}

- (NSString *)generateUniqueTimeFromat {
    NSDateFormatter *tFormat = [[NSDateFormatter alloc] init];
    [tFormat setDateFormat:@"yyyyMMdd_HHmmss_SS"];
    return [tFormat stringFromDate:[NSDate date]];
}


/**
 添加到图片数组, 存储到本地
 */
- (void)appendDataArrayAndsaveImage:(UIImage *)image localPath:(nullable NSString*)localPath {
    // 有路径的直接写入:
    if (localPath) {
        [self.imageDataArray addObject:[FTDataModel dataModelWith:image imageLocalPath:localPath]];
        return;
    }
    // 无路径的保存到沙盒, 记得清理:
    NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]; //
    NSString *saveFilePath = [documentpath stringByAppendingPathComponent:[self generateUniqueTimeFromat]];
    // !!曾转JPEG_Data再写入, 系统抛出失败通知.
    BOOL isWriteSuc = [UIImagePNGRepresentation(image) writeToFile:saveFilePath atomically:YES];
    if (isWriteSuc) {
        NSLog(@"写入图片成功: %@", saveFilePath);
        // 添加到数组:
        if (self.imageDataArray.count < IMG_MAX) {
            [self.imageDataArray addObject:[FTDataModel dataModelWith:image imageLocalPath:saveFilePath]];
        }
    } else {
        NSLog(@"写入图片失败");
    }
}

#pragma mark - 配置存储和查询
- (void)saveSucConfig {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [FTConfigSaver storeConfigSaveKey:remote_ip withValue:[self.ipTextField.text mutableCopy]];
        [FTConfigSaver storeConfigSaveKey:remote_username withValue:[self.usernameTextField.text mutableCopy]];
        [FTConfigSaver storeConfigSaveKey:remote_password withValue:[self.passwdTextField.text mutableCopy]];
        [FTConfigSaver storeConfigSaveKey:remote_remoteDirectory withValue:[self.remotePathDirectory.text mutableCopy]];
    });
}

- (void)cacheWithLastConfig {
    [self.ipTextField setText:[FTConfigSaver queryValueWithKey:remote_ip]];
    [self.usernameTextField setText:[FTConfigSaver queryValueWithKey:remote_username]];
    [self.passwdTextField setText:[FTConfigSaver queryValueWithKey:remote_password]];
    [self.remotePathDirectory setText:[FTConfigSaver queryValueWithKey:remote_remoteDirectory]];
}


@end
