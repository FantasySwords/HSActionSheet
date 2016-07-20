# HSActionSheet 


###说明
================
自定义仿微信ActionSheet,支持屏幕旋转，支持block回调

###更新
================
2016年07月20日更新 支持block回调 

###截图
================
![image](https://raw.githubusercontent.com/cnthinkcode/HSActionSheet/master/screenshot.png)

###使用
================
直接将HSActionSheet.h/m拖拽到项目中即可
####1. 像UIActionSheet一样使用(别忘了添加代理方法)。
```objc
HSActionSheet * actionSheet = [[HSActionSheet alloc] initWithTitle:@"HSActionSheet自定义标题" delegate:self cancelButtonTitle: @"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择",nil];
    
[actionSheet show];
```

####2. 使用Block回调
```objc
HSActionSheet * actionSheet = [[HSActionSheet alloc] initWithTitle:@"使用了Block的HSActionSheet" cancelButtonTitle:@"取消" destructiveButtonTitle:@"小视频" otherButtonTitles:@[@"拍照",@"从手机相册选择"] buttonClickedAtIndex:^(NSInteger buttonIndex, BOOL isCancel) {
        
    if (isCancel) {
        NSLog(@"取消了");
    }else {
        NSLog(@"选择了%ld",buttonIndex);
    }
}];
[actionSheet show];
```
