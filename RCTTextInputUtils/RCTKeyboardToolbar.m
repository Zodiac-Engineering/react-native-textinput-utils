//
//  RCTKeyboardToolbar.m
//  RCTKeyboardToolbar
//
//  Created by Kanzaki Mirai on 11/7/15.
//  Copyright © 2015 DickyT. All rights reserved.
//

#import "RCTKeyboardToolbar.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTTextField.h"
#import "RCTTextView.h"
#import "RCTUIManager.h"
#import "RCTEventDispatcher.h"
#import "RCTKeyboardPicker.h"
#import "RCTKeyboardDatePicker.h"
#import "RCTTextViewExtension.h"

@implementation RCTKeyboardToolbar

#pragma mark -

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(configure:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        // The convert is little bit dangerous, change it if you are going to fock the project
        // Or do not assign any non-common property between UITextView and UITextView
        UITextField *textView;
        if ([view class] == [RCTTextView class]) {
            RCTTextView *reactNativeTextView = ((RCTTextView *)view);
            textView = [reactNativeTextView getTextView];
        }
        else {
            RCTTextField *reactNativeTextView = ((RCTTextField *)view);
            textView = reactNativeTextView;
        }
        
        if (options[@"tintColor"]) {
            NSLog(@"tintColor is %@", options[@"tintColor"]);
            textView.tintColor = [RCTConvert UIColor:options[@"tintColor"]];
        }
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        UIView* borderView = [[UIView alloc]initWithFrame:CGRectMake(0, 43, screenWidth, 0.5)];
        borderView.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.40];
        [numberToolbar addSubview:borderView];
        NSInteger toolbarStyle = [RCTConvert NSInteger:options[@"barStyle"]];
        numberToolbar.barStyle = toolbarStyle;
        numberToolbar.backgroundColor = [UIColor whiteColor];
        numberToolbar.barTintColor = [UIColor whiteColor];
        
        numberToolbar.tintColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.329 alpha:1.00];
        NSString *leftButtonText = [RCTConvert NSString:options[@"leftButtonText"]];
        NSString *rightButtonText = [RCTConvert NSString:options[@"rightButtonText"]];
        
        NSNumber *currentUid = [RCTConvert NSNumber:options[@"uid"]];
        
        NSMutableArray *toolbarItems = [NSMutableArray array];
        if (![leftButtonText isEqualToString:@""]) {
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:[leftButtonText uppercaseString] style:UIBarButtonItemStyleDone target:self action:@selector(keyboardCancel:)];
            leftItem.tag = [currentUid intValue];
            [toolbarItems addObject:leftItem];
        }
        if (![leftButtonText isEqualToString:@""] && ![rightButtonText isEqualToString:@""]) {
            [toolbarItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        }
        if (![rightButtonText isEqualToString:@""]) {
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:[rightButtonText uppercaseString] style:UIBarButtonItemStyleDone target:self action:@selector(keyboardDone:)];
            rightItem.tag = [currentUid intValue];
            [toolbarItems addObject:rightItem];
        }
        numberToolbar.items = toolbarItems;
        
        NSArray *pickerData = [RCTConvert NSArray:options[@"pickerViewData"]];
        NSLog(@"%@", pickerData);
        
        if (pickerData.count > 0) {
            RCTKeyboardPicker *pickerView = [[RCTKeyboardPicker alloc]init];
            pickerView.tag = [currentUid intValue];
            [pickerView setCallbackObject:self withSelector:@selector(valueSelected:)];
            [pickerView setData:pickerData];
            textView.inputView = pickerView;
        }
        
        BOOL datePicker = [RCTConvert BOOL:options[@"datePicker"]];
        
        if(datePicker) {
            
            RCTKeyboardDatePicker *datePickerView = [[RCTKeyboardDatePicker alloc]init];
            
            NSString *datePickerMode = [RCTConvert NSString:options[@"datePickerMode"]];
            
            if([datePickerMode isEqualToString:@"date"]) {
                datePickerView.datePickerMode = UIDatePickerModeDate;
            }
            else if([datePickerMode isEqualToString:@"time"]) {
                datePickerView.datePickerMode = UIDatePickerModeTime;
            }
            else if ([datePickerMode isEqualToString:@"countdown"]) {
                datePickerView.datePickerMode = UIDatePickerModeCountDownTimer;
            }
            
            datePickerView.tag = [currentUid intValue];
            
            [datePickerView setCallbackObject:self withSelector:@selector(dateValueSelected:)];
            
            textView.inputView = datePickerView;
        }
        
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
        
        callback(@[[NSNull null], [currentUid stringValue]]);
    }];
}

RCT_EXPORT_METHOD(dismissKeyboard:(nonnull NSNumber *)reactNode) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView resignFirstResponder];
        });
    }];
}

RCT_EXPORT_METHOD(moveCursorToLast:(nonnull NSNumber *)reactNode) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITextPosition *position = [textView endOfDocument];
            textView.selectedTextRange = [textView textRangeFromPosition:position toPosition:position];
        });
    }];
}

RCT_EXPORT_METHOD(setSelectedTextRange:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        NSNumber *startPosition = [RCTConvert NSNumber:options[@"start"]];
        NSNumber *endPosition = [RCTConvert NSNumber:options[@"length"]];
        
        NSRange range  = NSMakeRange([startPosition integerValue], [endPosition integerValue]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITextPosition *from = [textView positionFromPosition:[textView beginningOfDocument] offset:range.location];
            UITextPosition *to = [textView positionFromPosition:from offset:range.length];
            [textView setSelectedTextRange:[textView textRangeFromPosition:from toPosition:to]];
        });
    }];
}

RCT_EXPORT_METHOD(setPickerRowByIndex:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UIPickerView *textView = ((UIPickerView *)view.inputView);
        
        NSInteger *index = [RCTConvert NSInteger:options[@"index"]];
        
        [textView selectRow: index inComponent:0 animated:YES];
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //        });
    }];
}

RCT_EXPORT_METHOD(reloadPickerData:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        RCTKeyboardPicker *textView = ((RCTKeyboardPicker *)view.inputView);
        
        NSArray *data = [RCTConvert NSArray:options[@"data"]];
        
        NSLog(@"%@", data);
        [textView setData: data];
        [textView reloadAllComponents];
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //        });
    }];
}

RCT_EXPORT_METHOD(setDate:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UIDatePicker *textView = ((UIDatePicker *)view.inputView);
        
        NSDate *date = [RCTConvert NSDate:options[@"date"]];
        NSLog(@"setting Date to %@", date);
        [textView setDate: date];
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //        });
    }];
}

- (void)valueSelected:(RCTKeyboardPicker*)sender
{
    NSNumber *selectedIndex = [NSNumber numberWithLong:[sender selectedRowInComponent:0]];
    NSLog(@"Selected %d", [selectedIndex intValue]);
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"keyboardPickerViewDidSelected"
                                                    body:@{@"currentUid" : [currentUid stringValue], @"selectedIndex": [selectedIndex stringValue]}];
}

- (void)dateValueSelected:(RCTKeyboardDatePicker*)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *stringFromDate = [formatter stringFromDate:[sender date]];
    
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    NSLog(@"selected date %@", stringFromDate);
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"keyboardDatePickerViewDidSelected"
                                                    body:@{@"currentUid" : [currentUid stringValue], @"selectedDate": stringFromDate}];
}

- (void)keyboardCancel:(UIBarButtonItem*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"keyboardToolbarDidTouchOnCancel"
                                                    body:@([currentUid intValue])];
}

- (void)keyboardDone:(UIBarButtonItem*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"keyboardToolbarDidTouchOnDone"
                                                    body:@([currentUid intValue])];
}

@end
