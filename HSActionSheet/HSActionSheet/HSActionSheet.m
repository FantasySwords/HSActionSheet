//
//  HSActionSheet.m
//  HSActionSheet
//
//  Created by Jerry Ho on 16/6/2.
//  Copyright © 2016年 ThinkCode. All rights reserved.
//

#import "HSActionSheet.h"

#define SCREEN_SIZE ([UIScreen mainScreen].bounds.size)
#define ACTION_SHEET_WIDTH (MIN(SCREEN_SIZE.width, SCREEN_SIZE.height))

//字体
#define TITLE_LABEL_FONT ([UIFont systemFontOfSize:13.f])
#define SHEET_BUTTON_FONT ([UIFont systemFontOfSize:17.f])

//距离
#define CANCLE_BUTTON_TOP_MARGIN 5.f

#define SHEET_BUTTON_HEIGHT     48.f

#define TITLE_LABEL_TOP_PADDING  10.f
#define TITLE_LABEL_MIN_HEIGHT  SHEET_BUTTON_HEIGHT

//颜色
#define TITLE_LABEL_TEXT_COLOR [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1.00]

#define SHEET_BUTTON_COLOR_NORMAL [UIColor blackColor]

#define DESTRUCTIVE_BUTTON_COLOR_NORMAL [UIColor redColor]

//动画时间
#define SHOW_ANIMATION_DURATION 0.25
#define DISMISS_ANIMATION_DURATION 0.25

#pragma mark - HSActionSheet
@interface HSActionSheet ()

//Title String

@property (nonatomic, copy) NSString * titleString;

@property (nonatomic, copy) NSString * cancleButtonTitle;

@property (nonatomic, copy) NSString * destructiveButtonTitle;

@property (nonatomic, strong) NSMutableArray * otherButtonTitles;

//View
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIView * bottomSheetView;

@property (nonatomic, strong) UIView * backgroundView;

//Window
@property (nonatomic, strong) UIWindow * alertWindow;

//buttonClickedAction
@property (nonatomic, copy) void (^buttonClickedAction)(NSInteger buttonIndex, BOOL isCancel);

@end


@implementation HSActionSheet
{
    CGFloat _bottomSheetViewHeight;
    CGFloat _bottomSheetViewWidth;
    CGFloat _titleLabelHeight;
    NSInteger _cancleBtnIndex;
    NSString  * _title;
}

@dynamic title;


- (instancetype)initWithTitle:( NSString *)title
                     delegate:(id<HSActionSheetDelegate>)delegate
            cancelButtonTitle:( NSString *)cancelButtonTitle
       destructiveButtonTitle:( NSString *)destructiveButtonTitle
            otherButtonTitles:( NSString *)otherButtonTitles, ...
{
    
    if (self = [super init]) {
        
        self.title = (title && title.length) ?title :nil;
        _delegate = delegate;
        _cancleButtonTitle = (cancelButtonTitle && cancelButtonTitle.length) ?cancelButtonTitle :nil;
        _destructiveButtonTitle = (destructiveButtonTitle && destructiveButtonTitle.length) ?destructiveButtonTitle :nil;
       
        //获取其他按钮title
        if (otherButtonTitles) {
             _otherButtonTitles = [NSMutableArray array];
            va_list params;
            id otherTitle = NULL;
            va_start(params, otherButtonTitles);
        
            [_otherButtonTitles addObject:otherButtonTitles];
          
            while ((otherTitle = va_arg(params, id))) {
                [_otherButtonTitles addObject:otherTitle];
            }
            va_end(params);
        }

    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
         buttonClickedAtIndex:(void (^)(NSInteger buttonIndex, BOOL isCancel)) buttonClickedAtIndex
{
    if (self = [super init]) {
        
        self.title = (title && title.length) ?title :nil;
        
        _cancleButtonTitle = (cancelButtonTitle && cancelButtonTitle.length) ?cancelButtonTitle :nil;
        _destructiveButtonTitle = (destructiveButtonTitle && destructiveButtonTitle.length) ?destructiveButtonTitle :nil;
        
        //获取其他按钮title
        if (otherButtonTitles && ![otherButtonTitles isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"参数错误" reason:@"otherButtonTitles必须是数组类型" userInfo:nil];
        }
        
        _otherButtonTitles = otherButtonTitles ?[otherButtonTitles mutableCopy] :[NSMutableArray array];
        _buttonClickedAction = buttonClickedAtIndex;
    }
    
    return self;
}

- (void)setupActionSheetUI
{
    //self.frame = [UIScreen mainScreen].bounds;
    
    CGFloat screenHeight = SCREEN_SIZE.height;
    CGFloat screenWidth = SCREEN_SIZE.width;
    
    CGFloat relativeHeight = 0; //相对高度
    
    CGFloat sheetHeight = [self calcBottomSheetViewSize];
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_backgroundView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapAction:)];
    [_backgroundView addGestureRecognizer:tap];
    
    _bottomSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, sheetHeight)];
    _bottomSheetView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.93 alpha:1.00];
    [self.view addSubview:_bottomSheetView];
    
    if (self.title) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, _titleLabelHeight)];
        _titleLabel.font = TITLE_LABEL_FONT;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1.00];
        _titleLabel.text = self.title;
        [_bottomSheetView addSubview:_titleLabel];
        
        relativeHeight = _titleLabelHeight;
    }
    
    NSMutableArray * btnTitleArray = [self.otherButtonTitles mutableCopy];
    
    if (self.destructiveButtonTitle) {
        [btnTitleArray insertObject:self.destructiveButtonTitle atIndex:0];
    }
    
    for (int i = 0; i < btnTitleArray.count; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, relativeHeight + i * SHEET_BUTTON_HEIGHT, screenWidth, SHEET_BUTTON_HEIGHT);
        
        //设置颜色
        if (i == 0 && self.destructiveButtonTitle ) {
            [btn setTitleColor:DESTRUCTIVE_BUTTON_COLOR_NORMAL forState:UIControlStateNormal];
            [btn setTitleColor:DESTRUCTIVE_BUTTON_COLOR_NORMAL forState:UIControlStateHighlighted];
        }else {
            [btn setTitleColor:SHEET_BUTTON_COLOR_NORMAL forState:UIControlStateNormal];
            [btn setTitleColor:SHEET_BUTTON_COLOR_NORMAL forState:UIControlStateHighlighted];
        }
        btn.titleLabel.font = SHEET_BUTTON_FONT;
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:btnTitleArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + i;
        
        [_bottomSheetView addSubview:btn];
        
        //划线
        
        if (!(i == 0 && !self.title)) {
            UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
            lineView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00];
            lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [btn addSubview:lineView];
        }

    }
    
    relativeHeight += btnTitleArray.count * SHEET_BUTTON_HEIGHT;
    
    if (self.cancleButtonTitle) {
        relativeHeight += CANCLE_BUTTON_TOP_MARGIN;
        
        UIButton * cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleBtn.frame = CGRectMake(0, relativeHeight, screenWidth, SHEET_BUTTON_HEIGHT);
        [cancleBtn setTitleColor:SHEET_BUTTON_COLOR_NORMAL forState:UIControlStateNormal];
        [cancleBtn setTitleColor:SHEET_BUTTON_COLOR_NORMAL forState:UIControlStateHighlighted];
        cancleBtn.backgroundColor = [UIColor whiteColor];
        cancleBtn.tag = 100 + btnTitleArray.count;
        [cancleBtn setTitle:self.cancleButtonTitle forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(cancleButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomSheetView addSubview:cancleBtn];
        
        _cancleBtnIndex = btnTitleArray.count;
    }else {
        _cancleBtnIndex = -1;
    }
    
    for (UIView * sub in _bottomSheetView.subviews) {
        sub.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}
#pragma mark - Event Action

- (void)backgroundViewTapAction:(UITapGestureRecognizer *)tap
{
    [self dismissWithAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    }
    
    [self actionSheetCancel];
}

- (void)buttonClickedAction:(UIButton *)btn
{
    [self clickedButtonAtIndex:btn.tag - 100];
    [self dismissWithAnimated:YES];
}

- (void)cancleButtonClickedAction:(UIButton *)btn
{
    [self dismissWithAnimated:YES];
    [self actionSheetCancel];
}

- (UIWindow *)alertWindow
{
    if (_alertWindow == nil) {
        
        _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _alertWindow.windowLevel       = UIWindowLevelStatusBar;
        _alertWindow.backgroundColor   = [UIColor clearColor];
        _alertWindow.hidden = NO;
        _alertWindow.rootViewController = self;
        
    }
    
    return _alertWindow;
}


- (CGFloat)calcBottomSheetViewSize
{
    if (self.title) {
        _titleLabelHeight = [self textSize:self.title WithFont:TITLE_LABEL_FONT lineBreakMode:NSLineBreakByWordWrapping maxWidth:SCREEN_SIZE.width - TITLE_LABEL_TOP_PADDING] + 2 * TITLE_LABEL_TOP_PADDING;
        
        _titleLabelHeight = MAX(TITLE_LABEL_MIN_HEIGHT, _titleLabelHeight);
    }else {
        _titleLabelHeight = 0;
    }
   
    
    CGFloat sheetButtonHeight = (self.destructiveButtonTitle ?SHEET_BUTTON_HEIGHT :0) + (self.cancleButtonTitle ?SHEET_BUTTON_HEIGHT :0) + self.otherButtonTitles.count * SHEET_BUTTON_HEIGHT;
    
    _bottomSheetViewHeight = _titleLabelHeight + sheetButtonHeight +  (self.cancleButtonTitle ?CANCLE_BUTTON_TOP_MARGIN :0);
    
    return _bottomSheetViewHeight;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
   _bottomSheetView.frame = CGRectMake(0, SCREEN_SIZE.height - _bottomSheetViewHeight, SCREEN_SIZE.width, _bottomSheetViewHeight);
}

#pragma mark - Getter & Setter
- (void)setTitle:(NSString *)title
{
    _titleString = title;
}

- (NSString *) title
{
    return _titleString;
}

#pragma mark - public
- (void)showWithAnimated:(BOOL)animated
{
    [self setupActionSheetUI];
    
    [self alertWindow];
    
    self.bottomSheetView.frame = CGRectMake(0, SCREEN_SIZE.height , SCREEN_SIZE.width, _bottomSheetViewHeight);
    self.backgroundView.alpha = 0;
    
    [UIView animateWithDuration:(animated ?SHOW_ANIMATION_DURATION :0.f) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.bottomSheetView.frame = CGRectMake(0, SCREEN_SIZE.height - _bottomSheetViewHeight, SCREEN_SIZE.width, _bottomSheetViewHeight);
        self.backgroundView.alpha = 1.f;
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void)show
{
    [self showWithAnimated:YES];
   
}


- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [self clickedButtonAtIndex:buttonIndex];
    [self dismissWithAnimated:animated];
}

- (void)dismissWithAnimated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ?DISMISS_ANIMATION_DURATION :0.f) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.bottomSheetView.frame = CGRectMake(0, SCREEN_SIZE.height, SCREEN_SIZE.width, _bottomSheetViewHeight);
        self.backgroundView.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.alertWindow.hidden = YES;
        self.alertWindow.rootViewController = nil;
    }];
    
}

#pragma mark - private
- (CGFloat)textSize:(NSString *)text WithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode maxWidth:(CGFloat)maxWidth
{
    CGSize size;
 
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    NSDictionary * dict = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading  attributes:dict context:nil].size;

    return ceil(size.height); // ceil 上取整
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)dealloc
{
    //NSLog(@"dealloc");
}


#pragma mark - delegate wrapper
- (void)clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.buttonClickedAction) {
        self.buttonClickedAction(buttonIndex, NO);
    }else if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
    }
}

- (void)actionSheetCancel
{
    if (self.buttonClickedAction) {
        self.buttonClickedAction(-1, YES);
    }else if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    }
}



@end
