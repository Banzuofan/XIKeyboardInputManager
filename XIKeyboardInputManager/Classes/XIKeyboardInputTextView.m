//
//  XIKeyboardInputTextView.m
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import "XIKeyboardInputTextView.h"

@implementation XIKeyboardInputTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollsToTop = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (void)commonInit
{
    _placeholderFont = [UIFont systemFontOfSize:16];
    _placeholderColor = [UIColor lightGrayColor];
}

- (void)textDidChange:(NSNotification *)notification
{
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!placeholderLabel && self.superview){
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        placeholderLabel.font = _placeholderFont;
        placeholderLabel.textColor = _placeholderColor;
        placeholderLabel.text = _placeholder;
        [self.superview addSubview:placeholderLabel];
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:placeholderLabel
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:self.textContainerInset.left*2],
                                 [NSLayoutConstraint constraintWithItem:placeholderLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:self.textContainerInset.top]];
        [NSLayoutConstraint activateConstraints:constraints];
        
    }
    placeholderLabel.hidden = self.text.length>0;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    if(placeholderLabel){
        placeholderLabel.text = placeholder;
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    if(placeholderLabel){
        placeholderLabel.textColor = _placeholderColor;
    }
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    if(placeholderLabel){
        placeholderLabel.font = placeholderFont;
    }
}

@end
