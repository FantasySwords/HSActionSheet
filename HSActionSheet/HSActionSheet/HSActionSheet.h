//
//  HSActionSheet.h
//  HSActionSheet
//
//  Created by Jerry Ho on 16/6/2.
//  Copyright © 2016年 ThinkCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSActionSheetDelegate;


@interface HSActionSheet : UIViewController


- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<HSActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

/**
 *  HSActionSheet block调用方式
 *  Warning:使用此方法delegate将无效
 *
 *  @param buttonClickedAtIndex   点击某行或者取消选择后调用，buttonIndex:选择的行index， isCancel是否取消选择
 */
- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
           buttonClickedAtIndex:(void (^)(NSInteger buttonIndex, BOOL isCancel)) buttonClickedAtIndex;

@property(nonatomic,readonly,getter=isVisible) BOOL visible;

@property(nonatomic,weak) id<HSActionSheetDelegate> delegate;

@property(nonatomic,copy) NSString *title;

@property(nonatomic,assign) NSInteger tag;

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