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

#define kDBImageUrl				@"imageUrl"
#define kDBWord					@"word"
#define kDBCaption				@"caption"

NS_ASSUME_NONNULL_BEGIN

@interface QJDatabaseManager : NSObject

+ (instancetype)sharedManager;

- (void)databaseInitialize;

- (NSManagedObjectContext *)managedObjectContext;

- (BOOL)saveContext:(nullable NSManagedObjectContext *)context;

- (BOOL)saveContext;

- (void)performDatabaseUpdateBlock:(nullable void (^)(NSManagedObjectContext * concurrencyContext))updateBlock
	finished:(nullable void (^)(NSManagedObjectContext * mainContext))finished;
	
// QJImageCaption
- (QJImageCaption *)setImageCaptionByImageUrl:(NSString *)imageUrl
	caption:(nullable NSString *)caption
	isSelfInsert:(BOOL)isSelfInsert
	context:(nullable NSManagedObjectContext *)context;
	
- (QJImageCaption *)getImageCaptionByUrl:(NSString *)imageUrl
	context:(nullable NSManagedObjectContext *)context;
	
- (NSArray *)getAllImageCaptions:(nullable NSManagedObjectContext *)context;

- (NSArray *)getImageCaptions:(nullable NSManagedObjectContext *)context captions:(NSArray *)captions;
// QJAdviseCaption
- (QJAdviseCaption *)setAdviseCaptionByImageUrl:(NSString *)imageUrl
	caption:(nullable NSString *)caption
	number:(nullable NSNumber *)number
	context:(nullable NSManagedObjectContext *)context;
	
- (QJAdviseCaption *)getAdviseCaptionByUrl:(NSString *)imageUrl
	context:(nullable NSManagedObjectContext *)context;
	
- (NSArray *)getAdviseCaptionsByCaption:(NSString *)caption
	context:(nullable NSManagedObjectContext *)context;
	
- (NSArray *)getAllAdviseCaptions:(nullable NSManagedObjectContext *)context;

// QJSearchWord
- (QJSearchWord *)setSearchWordByWord:(NSString *)word
	detailed:(NSString *)detailed
	context:(nullable NSManagedObjectContext *)context;
	
- (QJSearchWord *)getSearchWordByWord:(NSString *)word
	context:(nullable NSManagedObjectContext *)context;
	
- (NSArray *)getAllSearchWords:(nullable NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
