//
//  RCTKeyboardDatePicker.h
//  RCTTextInputUtils
//
//  Created by Dave on 22/02/2016.
//  Copyright © 2016 DickyT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTBridgeModule.h"

@interface RCTKeyboardDatePicker : UIDatePicker

@property (nonatomic, retain) id callbackObject;
@property (nonatomic, assign) SEL callbackSeletor;

- (void)setCallbackObject:(id)anObject withSelector:(SEL)selector;

@end
