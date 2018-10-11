//
//  XIKeyboardInputView.h
//  Pods-XIKeyboardInputManager_Example
//
//  Created by YXLONG on 2018/10/11.
//

#import "XIKeyboardInput.h"

@interface XIKeyboardInputView : UIView<XIKeyboardInput>
@property(nonatomic, assign) BOOL editingDone;

- (NSString *)trimPublishContent:(NSString *)content limitedTextLength:(NSInteger)limitedTextLength;

@end
