//
//  XIKeyboardInput.h
//  Pods
//
//  Created by YXLONG on 2018/10/11.
//

#ifndef XIKeyboardInput_h
#define XIKeyboardInput_h
#import <UIKit/UIKit.h>

typedef BOOL(^XIKeyboardInputShouldEndFinishingBlock)(NSString *currentInput);

/**
 输入完成的回调Block
 
 @param result {@"text":@"result"}}
 @param finished YES输入完成，NO输入取消
 */
typedef void(^XIKeyboardInputDidEndFinishingBlock)(NSDictionary *result, BOOL finished);


/**
 添加输入框背景模式
 
 - BackgroundNone: 不加背景
 - BackgroundTransparent: 全透明背景
 - BackgroundTranslucent: 半透明背景
 */
typedef NS_ENUM(NSUInteger, XIKeyboardBackgroundMode) {
    XIKeyboardBackgroundNone,
    XIKeyboardBackgroundTransparent,
    XIKeyboardBackgroundTranslucent,
};


@protocol XIKeyboardInput <NSObject>
//@optional
@property(nonatomic) XIKeyboardBackgroundMode backgroundMode;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic, copy) NSString *placeholder;
@property(nonatomic, copy) NSString *text;
///最大的文本输入的长度
@property(nonatomic, assign) NSInteger limitedTextLength;
///输入完成的回调处理
@property(nonatomic, copy) XIKeyboardInputDidEndFinishingBlock inputDidEndFinishingHandler;
///检测输入内容是否为有效输入
@property(nonatomic, copy) XIKeyboardInputShouldEndFinishingBlock inputShouldEndFinishingHandler;

- (UIView<UITextInput> *)textInputView;/// return instance of textFiled or textView.

- (void)keyboardWillDismissWithAnimationDuration:(NSTimeInterval)animationDuration;
@end

#endif /* XIKeyboardInput_h */
