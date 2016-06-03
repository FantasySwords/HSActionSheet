//
//  ViewController.m
//  HSActionSheet
//
//  Created by 东电创新 on 16/6/2.
//  Copyright © 2016年 Jerry Ho. All rights reserved.
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
