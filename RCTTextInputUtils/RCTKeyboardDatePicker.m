//
//  RCTKeyboardDatePicker.m
//  RCTTextInputUtils
//
//  Created by Dave on 22/02/2016.
//  Copyright © 2016 DickyT. All rights reserved.
//

#import "RCTKeyboardDatePicker.h"

@implementation RCTKeyboardDatePicker

- (id)init
{
    self = [super init];
    
    [self addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    return self;
}

- (void)setCallbackObject:(id)anObject withSelector:(SEL)selector
{
    self.callbackObject = anObject;
    self.callbackSeletor = selector;
}

-(void)dateChanged:(NSDate*)date {
    [self.callbackObject performSelector:self.callbackSeletor withObject:self];
}

@end
