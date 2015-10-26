//
//  QJDatabaseManager.h
//  Weitu
//
//  Created by QJ on 15/10/26.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "QJAdviseCaption.h"

#import "QJSearchWord.h"

#import "QJImageCaption.h"

#define AdviseCaption_Entity	@"QJAdviseCaption"

#define SearchWord_Entity		@"QJSearchWord"

#define ImageCaption_Entity		@"QJImageCaption"

NS_ASSUME_NONNULL_BEGIN

@interface QJDatabaseManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)saveContext:(NSManagedObjectContext *)context;

- (BOOL)saveContext;

- (void)performDatabaseUpdateBlock:(nullable void (^)(NSManagedObjectContext * concurrencyContext))updateBlock
	finished:(nullable void (^)(NSManagedObjectContext * mainContext))finished;


	
@end

NS_ASSUME_NONNULL_END
