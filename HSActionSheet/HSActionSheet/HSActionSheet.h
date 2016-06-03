//
//  HSActionSheet.h
//  HSActionSheet
//
//  Created by hexiaojian on 16/6/2.
//  Copyright © 2016年 Jerry Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSActionSheetDelegate;


@interface HSActionSheet : UIViewController


- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<HSActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

@property(nonatomic,readonly,getter=isVisible) BOOL visible;

@property(nonatomic,weak) id<HSActionSheetDelegate> delegate;

@property(nonatomic,copy) NSString *title;

//TODO:待添加
//@property(nonatomic, assign) BOOL isFullScaleInLandscape;

- (void)showWithAnimated:(BOOL)animated;
- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end


@protocol HSActionSheetDelegate <NSObject>

@optional
- (void)actionSheet:(HSActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)actionSheetCancel:(HSActionSheet *)actionSheet;
@end