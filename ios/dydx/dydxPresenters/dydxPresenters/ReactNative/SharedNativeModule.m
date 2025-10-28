//
//  SharedNativeModule.m
//  dydxPresenters
//
//  Created by Rui Huang on 27/10/2025.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(SharedNativeModule, RCTEventEmitter)

RCT_EXTERN_METHOD(trackEvent
                  :(NSString) eventName
                  :(NSDictionary *)eventParams)

RCT_EXTERN_METHOD(localize
                  :(NSString *)path
                  :(id)params
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
@end
