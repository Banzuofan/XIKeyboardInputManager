//
//  XIKeyboardInputManager.h
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

@import UIKit;
#import "XIKeyboardInput.h"


typedef NS_ENUM(NSUInteger, XIKeyboardInputType) {
    ///通用回复框
    CommonReplyType,
    //    ,
    //    ,
};

@interface UIViewController (XIKeyboardInputManager)
@property(nonatomic, assign) BOOL enableKeyboardInputDraft;

/**
 输入框是否处在编辑中
 */
- (BOOL)inputViewOnFocus;

- (NSString *)getDraftForKey:(NSString *)key;
- (void)setDraft:(NSString *)draft forKey:(NSString *)key;
- (void)removeDraftForKey:(NSString *)key;

/**
 唤起输入框
 
 @param draft 草稿
 @param placeholder 占位文本
 @param backgroundMode 添加输入框背景模式
 @param returnKeyType 设置键盘Return键类型
 @param limitedTextLength 限制输入文本长度
 @param inputView 自定义的输入视图
 @param shouldEndFinishing 检测输入内容是否合法
 @param completion 输入内容合法并完成输入
 */
- (void)beginEditingWithDraft:(NSString *)draft
                  placeholder:(NSString *)placeholder
               backgroundMode:(XIKeyboardBackgroundMode)backgroundMode
                returnKeyType:(UIReturnKeyType)returnKeyType
            limitedTextLength:(NSInteger)limitedTextLength
                    inputView:(UIView<XIKeyboardInput> *)inputView
           shouldEndFinishing:(XIKeyboardInputShouldEndFinishingBlock)shouldEndFinishing
                   completion:(XIKeyboardInputDidEndFinishingBlock)completion;

/**
 按照预定义的类型唤起输入框
 
 @param draft 草稿
 @param placeholder 占位文本
 @param backgroundMode 添加输入框背景模式
 @param limitedTextLength 限制输入文本长度
 @param inputType 自定义的输入视图类型
 @param shouldEndFinishing 检测输入内容是否合法
 @param completion 输入内容合法并完成输入
 */
- (void)beginEditingWithDraft:(NSString *)draft
                  placeholder:(NSString *)placeholder
               backgroundMode:(XIKeyboardBackgroundMode)backgroundMode
            limitedTextLength:(NSInteger)limitedTextLength
                    inputType:(XIKeyboardInputType)inputType
           shouldEndFinishing:(XIKeyboardInputShouldEndFinishingBlock)shouldEndFinishing
                   completion:(XIKeyboardInputDidEndFinishingBlock)completion;

@end
