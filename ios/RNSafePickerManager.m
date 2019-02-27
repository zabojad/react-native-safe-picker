/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSafePickerManager.h"

//#import "RCTBridge.h"
#import "RNSafePicker.h"
#import "RCTFont.h"
#import <React/RCTLog.h>

#import <React/RCTUIManager.h>

@implementation RNSafePickerManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [RNSafePicker new];
}

RCT_EXPORT_VIEW_PROPERTY(items, NSArray<NSDictionary *>)
RCT_EXPORT_VIEW_PROPERTY(selectedIndex, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(color, UIColor)
RCT_EXPORT_VIEW_PROPERTY(textAlign, NSTextAlignment)
RCT_CUSTOM_VIEW_PROPERTY(fontSize, NSNumber, RNSafePicker)
{
  view.font = [RCTFont updateFont:view.font withSize:json ?: @(defaultView.font.pointSize)];
}
RCT_CUSTOM_VIEW_PROPERTY(fontWeight, NSString, __unused RNSafePicker)
{
  view.font = [RCTFont updateFont:view.font withWeight:json]; // defaults to normal
}
RCT_CUSTOM_VIEW_PROPERTY(fontStyle, NSString, __unused RNSafePicker)
{
  view.font = [RCTFont updateFont:view.font withStyle:json]; // defaults to normal
}
RCT_CUSTOM_VIEW_PROPERTY(fontFamily, NSString, RNSafePicker)
{
  view.font = [RCTFont updateFont:view.font withFamily:json ?: defaultView.font.familyName];
}
RCT_EXPORT_METHOD(isScrolling: (nonnull NSNumber *)reactTag resolver: (RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        RNSafePicker *view = (RNSafePicker *)[self.bridge.uiManager viewForReactTag: reactTag];
        if (!view) {
            RCTLogTrace(@"NO PICKER VIEW FOUND");
            reject(@"NO PICKER VIEW FOUND", [NSString stringWithFormat: @"ReactTag passed: %@", reactTag], nil);
            return;
        }
        BOOL ret = [self anySubViewScrolling:view];
        RCTLogTrace(@"isScrolling resolves with %d",ret);
        resolve(@[[NSNumber numberWithBool:ret]]);
    });
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(isScrollingSynchronous:(nonnull NSNumber *)reactTag) {
    __block BOOL ret = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        RNSafePicker *view = (RNSafePicker *)[self.bridge.uiManager viewForReactTag: reactTag];
        if (view) {
            //return @[[NSNumber numberWithBool:NO]];
            ret = [self anySubViewScrolling:view];
        }
        
    });
    return @[[NSNumber numberWithBool:ret]];
}
-(bool) anySubViewScrolling:(UIView*)view {
    if([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scroll_view = (UIScrollView*) view;
        if(scroll_view.dragging || scroll_view.decelerating){
            return true;
        }
    }
    for(UIView *sub_view in [view subviews]){
        if([self anySubViewScrolling:sub_view]){
            return true;
        }
    }
    return false;
}

@end
