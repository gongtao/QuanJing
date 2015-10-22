//
//  OWTexploreModel.h
//  Weitu
//
//  Created by sunhu on 15/1/7.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTexploreModel : NSObject


@property (nonatomic, copy) NSString* Subtitle;//有关海獭的一切           主标题

@property (nonatomic, copy) NSString* Summary;//有关海獭的一切            副标题




@property (nonatomic, copy) NSString* Caption;//水中的萌宝宝              title

@property (nonatomic, copy) NSString* Url;//http://m.quanjing.com/topic/default.aspx?id=1088


@property (nonatomic, copy) NSString* CoverUrl;//http://apppic.quanjing.com/cover/1088.jpg 80*60

@property (nonatomic, copy) NSString* HCoverUrl;//http://apppic.quanjing.com/cover/high/1088.jpg

@property (nonatomic, copy) NSString* Class;//6

@property (nonatomic, copy) NSString* IsRec;//True
@property (nonatomic, copy) NSNumber* ReleaseDate;//1420042089

@property (nonatomic, copy) NSString* Sort;
//@property(nonatomic,copy)NSString *BigCoverUrl;

@end


