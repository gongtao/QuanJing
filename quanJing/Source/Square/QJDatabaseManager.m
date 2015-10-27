//
//  QJDatabaseManager.m
//  Weitu
//
//  Created by QJ on 15/10/26.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "QJDatabaseManager.h"

#import <UIImageView+WebCache.h>

@interface QJDatabaseManager ()

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel * managedObjectModel;

@property (strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@end

@implementation QJDatabaseManager

@synthesize managedObjectContext = _managedObjectContext;

@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedManager
{
	static QJDatabaseManager * sharedManagerInstance = nil;
	
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		sharedManagerInstance = [[QJDatabaseManager alloc] init];
	});
	
	return sharedManagerInstance;
}

- (id)init
{
	self = [super init];
	
	if (self) {}
	return self;
}

- (void)databaseInitialize
{
	[self managedObjectContext];
}

- (BOOL)saveContext:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	__block BOOL result = YES;
	NSError * error;
	
	if (![context hasChanges])
		return result;
		
	// Check space full
	BOOL isMainThread = [NSThread isMainThread];
	NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSFileManager * fileManager = [[NSFileManager alloc] init];
	NSDictionary * fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
	NSNumber * freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
	
	if (freeSpace.longLongValue < 50 * 1024 * 1024) {
		NSLog(@"Clean Disk");
		
		if (isMainThread) {
			[context rollback];
			[[SDImageCache sharedImageCache] clearDisk];
			return NO;
		}
		else {
			dispatch_semaphore_t sem = dispatch_semaphore_create(0);
			[[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
				dispatch_semaphore_signal(sem);
			}];
			dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		}
	}
	
	result = [context save:&error];
	
	if (error) {
		NSLog(@"save context error: %@", error);
		[context rollback];
		return NO;
	}
	
	return result;
}

- (BOOL)saveContext
{
	return [self saveContext:nil];
}

#pragma mark - Property

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext != nil)
		return _managedObjectContext;
		
	NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
	
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel != nil)
		return _managedObjectModel;
		
	NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"database" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
		return _persistentStoreCoordinator;
		
	NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL * storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"database.sqlite"];
	
	// CoreData update
	NSDictionary * optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
		NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
		NSInferMappingModelAutomaticallyOption, nil];
		
	NSError * error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 Check the error message to determine what the actual problem was.
		 
		 
		 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
		 
		 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
		 @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
		 
		 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
		 
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _persistentStoreCoordinator;
}

#pragma mark - Public

- (void)performDatabaseUpdateBlock:(void (^)(NSManagedObjectContext * concurrencyContext))updateBlock
	finished:(void (^)(NSManagedObjectContext * mainContext))finished
{
	NSManagedObjectContext * temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	
	temporaryContext.parentContext = self.managedObjectContext;
	
	__weak NSManagedObjectContext * weakContext = temporaryContext;
	[temporaryContext performBlock:^{
		if (updateBlock)
			updateBlock(weakContext);
		__block BOOL isSuccess = [self saveContext:weakContext];
		// save parent to disk asynchronously
		[weakContext.parentContext performBlock:^{
			if (isSuccess)
				[self saveContext:self.managedObjectContext];
				
			if (finished)
				finished(self.managedObjectContext);
		}];
	}];
}

#pragma mark - QJImageCaption

- (QJImageCaption *)setImageCaptionByImageUrl:(NSString *)imageUrl
	caption:(NSString *)caption
	isSelfInsert:(BOOL)isSelfInsert
	context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	QJImageCaption * object = [self getImageCaptionByUrl:imageUrl context:context];
	
	if (!object)
		object = [NSEntityDescription insertNewObjectForEntityForName:ImageCaption_Entity
			inManagedObjectContext:context];
	object.imageUrl = imageUrl;
	object.caption = caption;
	object.isSelfInsert = [NSNumber numberWithBool:isSelfInsert];
	return object;
}

- (QJImageCaption *)getImageCaptionByUrl:(NSString *)imageUrl context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:ImageCaption_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kDBImageUrl, imageUrl]];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results[0];
		
	return nil;
}

- (NSArray *)getAllImageCaptions:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:ImageCaption_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results;
		
	return nil;
}

#pragma mark - QJAdviseCaption

- (QJAdviseCaption *)setAdviseCaptionByImageUrl:(NSString *)imageUrl
	caption:(NSString *)caption
	number:(NSNumber *)number
	context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	QJAdviseCaption * object = [self getAdviseCaptionByUrl:imageUrl context:context];
	
	if (!object)
		object = [NSEntityDescription insertNewObjectForEntityForName:AdviseCaption_Entity
			inManagedObjectContext:context];
	object.imageUrl = imageUrl;
	object.caption = caption;
	object.number = number;
	return object;
}

- (QJAdviseCaption *)getAdviseCaptionByUrl:(NSString *)imageUrl
	context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:AdviseCaption_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kDBImageUrl, imageUrl]];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results[0];
		
	return nil;
}

- (NSArray *)getAdviseCaptionsByCaption:(NSString *)caption context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:AdviseCaption_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kDBCaption, caption]];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results;
		
	return nil;
}

- (NSArray *)getAllAdviseCaptions:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:AdviseCaption_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results;
		
	return nil;
}

#pragma mark - QJSearchWord

- (QJSearchWord *)setSearchWordByWord:(NSString *)word
	detailed:(NSString *)detailed
	context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	QJSearchWord * object = [self getSearchWordByWord:word context:context];
	
	if (!object)
		object = [NSEntityDescription insertNewObjectForEntityForName:SearchWord_Entity
			inManagedObjectContext:context];
	object.word = word;
	object.detailed = detailed;
	return object;
}

- (QJSearchWord *)getSearchWordByWord:(NSString *)word
	context:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:SearchWord_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kDBWord, word]];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results[0];
		
	return nil;
}

- (NSArray *)getAllSearchWords:(NSManagedObjectContext *)context
{
	if (!context)
		context = self.managedObjectContext;
		
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:SearchWord_Entity
		inManagedObjectContext:context];
		
	[request setEntity:entity];
	
	NSError * error;
	NSArray * results = [context executeFetchRequest:request error:&error];
	
	if (!error && (results.count > 0))
		return results;
		
	return nil;
}

@end
