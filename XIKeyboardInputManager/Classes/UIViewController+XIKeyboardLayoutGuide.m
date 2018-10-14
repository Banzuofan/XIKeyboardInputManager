//
//  UIViewController+XIKeyboardLayoutGuide.m
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import "UIViewController+XIKeyboardLayoutGuide.h"
#import <objc/runtime.h>

@interface XIKeyboardLayoutGuide : UIView
@property (nonatomic, weak) NSLayoutConstraint *verticalPositionConstraint;
- (void)addToView:(UIView *)view;
@end


static void* XIKeyboardLayoutGuideSavedKey = &XIKeyboardLayoutGuideSavedKey;

@implementation UIViewController (XIKeyboardLayoutGuide)
- (id)keyboardLayoutGuide
{
    XIKeyboardLayoutGuide *layoutGuide = objc_getAssociatedObject(self, XIKeyboardLayoutGuideSavedKey);
    
    if (!layoutGuide)
    {
        layoutGuide = [[XIKeyboardLayoutGuide alloc] init];
        [layoutGuide addToView:self.view];
        
        objc_setAssociatedObject(self, XIKeyboardLayoutGuideSavedKey, layoutGuide, OBJC_ASSOCIATION_ASSIGN);
    }
    
    return layoutGuide;
}
@end


@implementation XIKeyboardLayoutGuide

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addToView:(UIView *)view
{
    if(self.superview){
        [self removeFromSuperview];
    }
    self.hidden = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:self];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.f
                                                                   constant:0.f];
    
    [view addConstraint:constraint];
    
    self.verticalPositionConstraint = constraint;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurveOptions = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    CGRect beginKeyboardFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    BOOL animateToChange = YES;
    if(fabs(endKeyboardFrame.origin.y-beginKeyboardFrame.origin.y)<1.){
        animateToChange = NO;
    }
    
    endKeyboardFrame = [self.superview.window convertRect:endKeyboardFrame toView:self.superview];
    _verticalPositionConstraint.constant = -(self.superview.frame.size.height-endKeyboardFrame.origin.y);
    
    if(animateToChange){
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOptions
                         animations:^
         {
             [self.superview layoutIfNeeded];
         }
                         completion:nil];
    }
    else{
        [self.superview layoutIfNeeded];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurveOptions = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    CGRect endKeyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _verticalPositionConstraint.constant = endKeyboardFrame.size.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOptions
                     animations:^
     {
         [self.superview layoutIfNeeded];
     }
                     completion:nil];
}

@end
