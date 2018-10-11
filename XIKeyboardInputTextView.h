//
//  XIKeyboardInputTextView.h
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import <UIKit/UIKit.h>

@interface XIKeyboardInputTextView : UITextView
{
@private
    UILabel *placeholderLabel;
}
@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) UIColor *placeholderColor;
@property(nonatomic, strong) UIFont *placeholderFont;
@end
