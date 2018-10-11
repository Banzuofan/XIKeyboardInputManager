//
//  XIKeyboardInputView.m
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import "XIKeyboardInputView.h"

@interface XIKeyboardInputView ()
{
    UIControl *dimissKeyboardBgView;
}
@end

@implementation XIKeyboardInputView
@synthesize placeholder=_placeholder;
@synthesize text=_text;
@synthesize returnKeyType=_returnKeyType;
@synthesize limitedTextLength;
@synthesize inputDidEndFinishingHandler;
@synthesize inputShouldEndFinishingHandler;
@synthesize backgroundMode;


- (UIView<UITextInput> *)textInputView;/// return instance of textFiled or textView.
{
    return nil;
}

- (void)keyboardWillDismissWithAnimationDuration:(NSTimeInterval)animationDuration
{
    if(self.backgroundMode!=XIKeyboardBackgroundNone&&dimissKeyboardBgView){
        __weak XIKeyboardInputView *weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            XIKeyboardInputView *strongSelf = weakSelf;
            strongSelf->dimissKeyboardBgView.alpha = 0;
        }];
        [dimissKeyboardBgView removeFromSuperview];
        dimissKeyboardBgView = nil;
    }
}

- (NSString *)trimPublishContent:(NSString *)content limitedTextLength:(NSInteger)limitedTextLength
{
    NSString *newText = content;
    NSInteger backend = 1;
    while (newText.length>limitedTextLength) {
        newText = [newText substringToIndex:NSMaxRange([newText rangeOfComposedCharacterSequenceAtIndex:limitedTextLength-backend])];
        backend++;
    }
    return newText;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if(self.backgroundMode==XIKeyboardBackgroundNone){
        return;
    }
    
    if(newSuperview){
        if(dimissKeyboardBgView){
            [dimissKeyboardBgView.layer removeAllAnimations];
            
            [dimissKeyboardBgView removeFromSuperview];
            dimissKeyboardBgView = nil;
        }
        
        dimissKeyboardBgView = [[UIControl alloc] initWithFrame:newSuperview.bounds];
        if(self.backgroundMode==XIKeyboardBackgroundTransparent){
            dimissKeyboardBgView.backgroundColor = [UIColor clearColor];
        }
        else if(self.backgroundMode==XIKeyboardBackgroundTranslucent){
            dimissKeyboardBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        }
        
        [dimissKeyboardBgView addTarget:self.textInputView action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
        [newSuperview addSubview:dimissKeyboardBgView];
        dimissKeyboardBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        dimissKeyboardBgView.alpha = 0;
        __weak XIKeyboardInputView *weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            XIKeyboardInputView *strongSelf = weakSelf;
            strongSelf->dimissKeyboardBgView.alpha = 1;
        }];
    }
    else{
        if(dimissKeyboardBgView){
            __weak XIKeyboardInputView *weakSelf = self;
            [UIView animateWithDuration:0.15 animations:^{
                XIKeyboardInputView *strongSelf = weakSelf;
                strongSelf->dimissKeyboardBgView.alpha = 0;
            }];
            [dimissKeyboardBgView removeFromSuperview];
            dimissKeyboardBgView = nil;
        }
    }
}

@end
