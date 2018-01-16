//
//  SGLaunchData.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPActivityKind.h"


@interface SGResponseData : NSObject
//事件类型
@property (nonatomic, assign) SGActivityKind type;
//事件发生时间，自1970年1月1日0时起的毫秒数
@property (nonatomic, copy) NSNumber *ts;

@end

@interface SGPLaunchData : SGResponseData<NSCopying>

//事件附带数据
@property (nonatomic, retain) NSDictionary *data;

@end

//@interface SGPStartEvent : SGResponseData<NSCopying>
//
////事件附带数据
//@property (nonatomic, retain) NSDictionary *data;
//
//@end
//
//@interface SGPEndEvent : SGResponseData<NSCopying>
//
////事件附带数据
//@property (nonatomic, retain) NSDictionary *data;
//
//@end
//
//@interface SGPUserEvent : SGResponseData<NSCopying>
//
////事件附带数据
//@property (nonatomic, retain) NSDictionary *data;
//
//@end
