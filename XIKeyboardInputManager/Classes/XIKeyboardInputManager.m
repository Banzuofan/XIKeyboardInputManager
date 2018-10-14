//
//  XIKeyboardInputManager.m
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import "XIKeyboardInputManager.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "UIViewController+XIKeyboardLayoutGuide.h"
#import "XIKeyboardInputTextView.h"
#import "XIKeyboardInputView.h"

@interface _XICommonReplyView : XIKeyboardInputView<UITextViewDelegate>
{
@private
    NSMutableArray *_constraints;
}
@property(nonatomic, strong) XIKeyboardInputTextView *textView;
@property(nonatomic, assign) CGFloat frameHeight;
@property(nonatomic, assign) NSInteger numberOfLines;
@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
static void* kCustomInputViewSavedKey = &kCustomInputViewSavedKey;
static void* kDraftPoolSavedKey = &kDraftPoolSavedKey;
static void* kEnableKeyboardInputDraftSavedKey = &kEnableKeyboardInputDraftSavedKey;

@implementation UIViewController (JDKeyboardInputManager)

- (UIView<XIKeyboardInput> *)customInputView
{
    return objc_getAssociatedObject(self, kCustomInputViewSavedKey);
}

- (void)setCustomInputView:(UIView<XIKeyboardInput> *)customInputView
{
    [self willChangeValueForKey:@"customInputView"];
    objc_setAssociatedObject(self, kCustomInputViewSavedKey, customInputView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"customInputView"];
}

- (BOOL)enableKeyboardInputDraft
{
    return [objc_getAssociatedObject(self, kEnableKeyboardInputDraftSavedKey) boolValue];
}

- (void)setEnableKeyboardInputDraft:(BOOL)enableKeyboardInputDraft
{
    objc_setAssociatedObject(self, kEnableKeyboardInputDraftSavedKey, @(enableKeyboardInputDraft), OBJC_ASSOCIATION_ASSIGN);
}

- (NSMutableDictionary *)draftPool
{
    return objc_getAssociatedObject(self, kDraftPoolSavedKey);
}

- (void)setDraftPool:(NSMutableDictionary *)draftPool
{
    objc_setAssociatedObject(self, kDraftPoolSavedKey, draftPool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)prepareDraftPool
{
    if(!self.draftPool){
        self.draftPool = [NSMutableDictionary dictionary];
    }
}

- (NSString *)getDraftForKey:(NSString *)key
{
    if(!self.enableKeyboardInputDraft){
        return @"";
    }
    if(!key){
        return nil;
    }
    [self prepareDraftPool];
    return self.draftPool[key];
}

- (void)setDraft:(NSString *)draft forKey:(NSString *)key
{
    if(!key || !self.enableKeyboardInputDraft){
        return;
    }
    [self prepareDraftPool];
    [self.draftPool setObject:draft forKey:key];
}

- (void)removeDraftForKey:(NSString *)key
{
    if(!key || !self.enableKeyboardInputDraft){
        return;
    }
    [self prepareDraftPool];
    [self.draftPool removeObjectForKey:key];
}

- (void)_keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if(self.customInputView.backgroundMode!=XIKeyboardBackgroundNone &&
       [self.customInputView respondsToSelector:@selector(keyboardWillDismissWithAnimationDuration:)]){
        
        [self.customInputView keyboardWillDismissWithAnimationDuration:animationDuration];
    }
}

- (void)beginEditingWithDraft:(NSString *)draft
                  placeholder:(NSString *)placeholder
               backgroundMode:(XIKeyboardBackgroundMode)backgroundMode
                returnKeyType:(UIReturnKeyType)returnKeyType
            limitedTextLength:(NSInteger)limitedTextLength
                    inputView:(UIView<XIKeyboardInput> *)inputView
           shouldEndFinishing:(XIKeyboardInputShouldEndFinishingBlock)shouldEndFinishing
                   completion:(XIKeyboardInputDidEndFinishingBlock)completion
{
    if(self.customInputView.superview){
        [self.customInputView removeFromSuperview];
        self.customInputView = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
    if(placeholder.length>0){
        if([inputView respondsToSelector:@selector(setPlaceholder:)]){
            [inputView setPlaceholder:placeholder];
        }
    }
    
    if(draft.length>0){
        if([inputView respondsToSelector:@selector(setText:)]){
            [inputView setText:draft];
        }
    }
    
    if([inputView respondsToSelector:@selector(setReturnKeyType:)]){
        [inputView setReturnKeyType:returnKeyType];
    }
    if([inputView respondsToSelector:@selector(setLimitedTextLength:)]){
        [inputView setLimitedTextLength:limitedTextLength];
    }
    if([inputView respondsToSelector:@selector(setBackgroundMode:)]){
        [inputView setBackgroundMode:backgroundMode];
    }
    if([inputView respondsToSelector:@selector(setInputShouldEndFinishingHandler:)]){
        [inputView setInputShouldEndFinishingHandler:shouldEndFinishing];
    }
    if([inputView respondsToSelector:@selector(setInputDidEndFinishingHandler:)]){
        [inputView setInputDidEndFinishingHandler:completion];
    }
    
    
    CGRect rect = inputView.frame;
    rect.origin.y = self.view.bounds.size.height;
    inputView.frame = rect;
    [self.view addSubview:inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customInputView = inputView;
    
    NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:inputView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:inputView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:inputView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.keyboardLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0],
                             ];
    [NSLayoutConstraint activateConstraints:constraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.customInputView.textInputView becomeFirstResponder];
}

- (void)beginEditingWithDraft:(NSString *)draft
                  placeholder:(NSString *)placeholder
               backgroundMode:(XIKeyboardBackgroundMode)backgroundMode
            limitedTextLength:(NSInteger)limitedTextLength
                    inputType:(XIKeyboardInputType)inputType
           shouldEndFinishing:(XIKeyboardInputShouldEndFinishingBlock)shouldEndFinishing
                   completion:(XIKeyboardInputDidEndFinishingBlock)completion
{
    UIView<XIKeyboardInput> *inputView = nil;
    UIReturnKeyType returnKeyType = UIReturnKeyDefault;
    if(inputType==CommonReplyType){
        inputView = [[_XICommonReplyView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
        returnKeyType = UIReturnKeySend;
    }
    
    [self beginEditingWithDraft:draft
                    placeholder:placeholder
                 backgroundMode:backgroundMode
                  returnKeyType:returnKeyType
              limitedTextLength:limitedTextLength
                      inputView:inputView
             shouldEndFinishing:shouldEndFinishing
                     completion:completion];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

#define kTextContainerInsetVertical 5

@implementation _XICommonReplyView
{
    UIFont *_textViewFont;
    CGFloat _frameHeight;
    CGFloat _maxFrameHeight;
    CGFloat _minFrameHeight;
    UIEdgeInsets _textViewInsets;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _constraints = @[].mutableCopy;
        _numberOfLines = 3;
        _textViewFont = [UIFont systemFontOfSize:16];
        
        CGSize constraintSize = CGSizeMake(HUGE_VAL, HUGE_VAL);
        NSDictionary *attrs = @{NSFontAttributeName : _textViewFont};
        CGFloat _singleLineHeight = [NSStringFromClass(self.class) boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.height;
        
        _maxFrameHeight = _singleLineHeight*3+kTextContainerInsetVertical*2;
        _minFrameHeight = _singleLineHeight+kTextContainerInsetVertical*2;
        _frameHeight = _minFrameHeight;
        
        _textViewInsets = UIEdgeInsetsMake(8, 10, 8, 10);
        
        UIView *hairline = [[UIView alloc] initWithFrame:CGRectZero];
        hairline.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        [self addSubview:hairline];
        hairline.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:hairline
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:hairline
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:hairline
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:hairline
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:0.5]];
        [NSLayoutConstraint activateConstraints:constraints];
        
        _textView = [[XIKeyboardInputTextView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(5, 15, 5, 15))];
        _textView.delegate = self;
        _textView.textContainerInset = UIEdgeInsetsMake(kTextContainerInsetVertical, 5, kTextContainerInsetVertical, 0);
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.placeholderFont = [UIFont systemFontOfSize:16];
        _textView.placeholderColor = [UIColor lightGrayColor];
        [self addSubview:_textView];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_textView.layer setCornerRadius:3];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:[UIColor colorWithWhite:0.75 alpha:1].CGColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_textViewTextDidChange:) name:UITextViewTextDidChangeNotification
                                                   object:_textView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_textViewTextDidEndEditing:) name:UITextViewTextDidEndEditingNotification
                                                   object:_textView];
        
    }
    return self;
}

- (void)_textViewTextDidChange:(NSNotification *)aNotification
{
    NSString *newText = _textView.text;
    if(newText.length>self.limitedTextLength){
        _textView.text = [self trimPublishContent:newText limitedTextLength:self.limitedTextLength];
    }
    
    BOOL layoutChanged = NO;
    if(_frameHeight!=_textView.contentSize.height){
        _frameHeight = _textView.contentSize.height;
        if(_frameHeight>_maxFrameHeight){
            _frameHeight = _maxFrameHeight;
        }
        else if(_frameHeight<_minFrameHeight){
            _frameHeight = _minFrameHeight;
        }
        
        layoutChanged = YES;
    }
    
    if(layoutChanged){
        [self invalidateIntrinsicContentSize];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if(self.superview){
                [self.superview layoutIfNeeded];
            }
        } completion:nil];
        [_textView scrollRangeToVisible:_textView.selectedRange];
    }
}

- (void)_textViewTextDidEndEditing:(NSNotification *)aNotification
{
    if(!self.editingDone){
        if(self.inputDidEndFinishingHandler){
            self.inputDidEndFinishingHandler(@{@"text": _textView.text}, NO);
        }
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    _textView.placeholder = placeholder;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    _textView.text = text;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if(_textView.text.length>0){
        [self _textViewTextDidChange:nil];
    }
    [_textView scrollRangeToVisible:_textView.selectedRange];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    [super setReturnKeyType:returnKeyType];
    _textView.returnKeyType = returnKeyType;
}

- (UIView<UITextInput> *)textInputView
{
    return self.textView;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        
        NSString *_currentInput = textView.text?textView.text:@"";
        _currentInput = [_currentInput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(self.inputShouldEndFinishingHandler){
            if(self.inputShouldEndFinishingHandler(_currentInput)){
                
                self.editingDone = YES;
                [textView resignFirstResponder];
                
                if(self.inputDidEndFinishingHandler){
                    if(self.inputDidEndFinishingHandler){
                        self.inputDidEndFinishingHandler(@{@"text": _currentInput}, YES);
                    }
                }
                return NO;
            }
            else{
                return NO;
            }
        }
        
        self.editingDone = YES;
        [textView resignFirstResponder];
        
        if(self.inputDidEndFinishingHandler){
            if(self.inputDidEndFinishingHandler){
                self.inputDidEndFinishingHandler(@{@"text": _currentInput}, YES);
            }
        }
        return NO;
    }
    
    return YES;
}

- (void)updateConstraints
{
    if(_constraints.count>0){
        [NSLayoutConstraint deactivateConstraints:_constraints];
        [_constraints removeAllObjects];
    }
    [_constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:_textView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:_textViewInsets.left],
                                         [NSLayoutConstraint constraintWithItem:_textView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:-_textViewInsets.right],
                                         [NSLayoutConstraint constraintWithItem:_textView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:_textViewInsets.top],
                                         [NSLayoutConstraint constraintWithItem:_textView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:_frameHeight]
                                         ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
    
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric,
                      _textViewInsets.top+_textViewInsets.bottom+_frameHeight);
}

@end
