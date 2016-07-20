//
//  ViewController.m
//  HSActionSheet
//
//  Created by Jerry Ho on 16/6/2.
//  Copyright © 2016年 ThinkCode. All rights reserved.
//

#import "ViewController.h"
#import "HSActionSheet.h"


@interface ViewController ()<HSActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)btnAction:(id)sender {
    HSActionSheet * actionSheet = [[HSActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"小视频",@"拍照",@"从手机相册选择",nil];
    
    [actionSheet show];
}

- (IBAction)btn2:(id)sender {
    HSActionSheet * actionSheet = [[HSActionSheet alloc] initWithTitle:@"HSActionSheet自定义标题" delegate:self cancelButtonTitle: @"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择",nil];
    
    [actionSheet show];
}

- (IBAction)btn3:(id)sender {
    
    HSActionSheet * actionSheet = [[HSActionSheet alloc] initWithTitle:@"使用了Block的HSActionSheet" cancelButtonTitle:@"取消" destructiveButtonTitle:@"小视频" otherButtonTitles:@[@"拍照",@"从手机相册选择"] buttonClickedAtIndex:^(NSInteger buttonIndex, BOOL isCancel) {
        
        if (isCancel) {
            NSLog(@"取消了");
        }else {
            NSLog(@"选择了%ld",buttonIndex);
        }
    }];
    [actionSheet show];
}


#pragma mark - HSActionSheetDelegate
- (void)actionSheet:(HSActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"选择了%ld",buttonIndex);
}

- (void)actionSheetCancel:(HSActionSheet *)actionSheet
{
     NSLog(@"取消了");
}



@end
