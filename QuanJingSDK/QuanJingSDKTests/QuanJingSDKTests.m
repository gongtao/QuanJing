//
//  QuanJingSDKTests.m
//  QuanJingSDKTests
//
//  Created by QJ on 15/10/18.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AFNetworking.h"

#import "QuanJingSDK.h"

#define kPhoneNumber	@"18600962172"
#define kPassword		@"Gongtao1987"

@interface QuanJingSDKTests : XCTestCase

@end

@implementation QuanJingSDKTests

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

#pragma mark - 获取缩略图url

- (void)testThumbnailSizeExample
{
	NSString * url = [QJInterfaceManager thumbnailUrlFromImageUrl:@"http://quanjing-test.oss.aliyuncs.com/041/819/0418191be0c4e584005436e1235ffc4a/dd8fac16fece498dabd03625cc5cfa7d.gif" size:CGSizeMake(200.0, 200.0)];
	
	NSLog(@"%@", url);
}

#pragma mark - 发送注册短信

- (void)testSendRegistSMSExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testSendRegistSMSExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [[QJPassport sharedPassport] sendRegistSMS:kPhoneNumber];
			
			if (error)
				XCTFail(@"testSendRegistSMSExample error: %@", error);
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testSendRegistSMSExample error: %@", error);
		}];
	}];
}

#pragma mark - 注册

- (void)testUserRegistExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserRegistExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJPassport sharedPassport] registerUser:kPhoneNumber
			password:kPassword
			code:@"278715"
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testUserRegistExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testUserRegistExample error: %@", error);
		}];
	}];
}

#pragma mark - 发送登录短信

- (void)testSendLoginSMSExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testSendLoginSMSExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [[QJPassport sharedPassport] sendLoginSMS:kPhoneNumber];
			
			if (error)
				XCTFail(@"testSendLoginSMSExample error: %@", error);
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testSendLoginSMSExample error: %@", error);
		}];
	}];
}

#pragma mark - 短信登录

- (void)testLoginSMSExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testLoginSMSExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			code:@"536528"
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testLoginSMSExample error: %@", error);
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			[[QJPassport sharedPassport] logout];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testLoginSMSExample error: %@", error);
		}];
	}];
}

#pragma mark - 用户信息

- (void)testUserExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testUserExample error: %@", error);
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
            
            NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"kCookieDictionaryKey"]);
			
			__block QJUser * modifyUser = nil;
			[[QJPassport sharedPassport] requestUserInfo:^(QJUser * user, NSDictionary * userDic, NSError * error) {
				if (error) {
					XCTFail(@"testUserExample error: %@", error);
					return;
				}
				modifyUser = user;
			}];
			
			modifyUser.nickName = @"熊熊";
			
			[[QJPassport sharedPassport] requestModifyUserInfo:modifyUser
			finished:^(QJUser * user, NSDictionary * userDic, NSError * error) {
				if (error)
					XCTFail(@"testUserExample error: %@", error);
			}];
			
			[[QJPassport sharedPassport] logout];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testUserExample error: %@", error);
		}];
	}];
}

#pragma mark - 首页

- (void)testHomeIndexExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testHomeIndexExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJInterfaceManager sharedManager] requestHomeIndex:^(NSDictionary * resultDic, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testHomeIndexExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testHomeIndexExample error: %@", error);
		}];
	}];
}

#pragma mark - 搜索

- (void)testImageSearchExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testImageSearchExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJInterfaceManager sharedManager] requestImageSearchKey:@"家"
			pageNum:1
			pageSize:20
			finished:^(NSArray * imageObjectArray, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testImageSearchExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testImageSearchExample error: %@", error);
		}];
	}];
}

#pragma mark - 图片分类

- (void)testImageCategoryExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testImageCategoryExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJInterfaceManager sharedManager] requestImageRootCategory:^(NSArray * imageCategoryArray, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testImageCategoryExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testImageCategoryExample error: %@", error);
		}];
	}];
}

#pragma mark - 图片故事

- (void)testArticleExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testImageCategoryExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJInterfaceManager sharedManager] requestArticleCategory:^(NSArray * articleCategoryArray, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testImageCategoryExample error: %@", error);
			}];
			
			__block NSNumber * cursorIndex = nil;
			[[QJInterfaceManager sharedManager] requestArticleList:[NSNumber numberWithLongLong:1]
			cursorIndex:nil
			pageSize:20
			finished:^(NSArray * articleObjectArray, NSNumber * nextCursorIndex, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testImageCategoryExample error: %@", error);
					
				cursorIndex = nextCursorIndex;
			}];
			
			if (cursorIndex)
				[[QJInterfaceManager sharedManager] requestArticleList:[NSNumber numberWithLongLong:1]
				cursorIndex:cursorIndex
				pageSize:20
				finished:^(NSArray * articleObjectArray, NSNumber * nextCursorIndex, NSArray * resultArray, NSError * error) {
					if (error)
						XCTFail(@"testImageCategoryExample error: %@", error);
						
					cursorIndex = nextCursorIndex;
				}];
				
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testImageCategoryExample error: %@", error);
		}];
	}];
}

#pragma mark - 圈子

- (void)testActionExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testActionExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			__block NSNumber * actionId = nil;
			[[QJInterfaceManager sharedManager] requestActionList:nil
			pageSize:20
			userId:nil
			finished:^(NSArray * actionArray, NSArray * resultArray, NSNumber * nextCursorIndex, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
					
				if (actionArray && (actionArray.count > 0)) {
					QJActionObject * actionObject = [actionArray lastObject];
					actionId = actionObject.aid;
				}
			}];
			
			NSError * error = [[QJInterfaceManager sharedManager] requestLikeAction:actionId];
			
			if (error)
				XCTFail(@"testActionExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestCancelLikeAction:actionId];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestCollectAction:actionId];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestCollectCancelAction:actionId];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestCommentAction:actionId comment:@"赞"];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testActionExample error: %@", error);
		}];
	}];
}

#pragma mark - 图片详情

- (void)testImageExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testImageExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSNumber * imageId = [NSNumber numberWithLongLong:900006405];
			NSNumber * imageType = [NSNumber numberWithLongLong:1];
			
			[[QJInterfaceManager sharedManager] requestImageDetail:imageId
			imageType:imageType
			finished:^(QJImageObject * imageObject, NSError * error) {
				if (error)
					XCTFail(@"testImageExample error: %@", error);
			}];
			
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			NSError * error = [[QJInterfaceManager sharedManager] requestImageComment:imageId
			imageType:imageType
			comment:@"赞"];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestImageLike:imageId imageType:imageType];
			
			if (error)
				XCTFail(@"testImageExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestImageCancelLike:imageId imageType:imageType];
			
			if (error)
				XCTFail(@"testImageExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestImageCollect:imageId imageType:imageType];
			
			if (error)
				XCTFail(@"testImageExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestImageCancelCollect:imageId imageType:imageType];
			
			if (error)
				XCTFail(@"testImageExample error: %@", error);
				
			error = [[QJInterfaceManager sharedManager] requestImageAddDownload:imageId imageType:imageType];
			
			if (error)
				XCTFail(@"testImageExample error: %@", error);
				
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testImageExample error: %@", error);
		}];
	}];
}

#pragma mark - 用户列表

- (void)testUserImageListExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserImageListExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			[[QJInterfaceManager sharedManager] requestUserCollectImageList:1
			pageSize:20
			finished:^(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testUserImageListExample error: %@", error);
			}];
			
			[[QJInterfaceManager sharedManager] requestUserCommentImageList:1
			pageSize:20
			finished:^(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testUserImageListExample error: %@", error);
			}];
			
			[[QJInterfaceManager sharedManager] requestUserAlbumList:1
			pageSize:20
			finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testUserImageListExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testUserImageListExample error: %@", error);
		}];
	}];
}

- (void)testUserListExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserImageListExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			__block NSNumber * mainId = nil;
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
				mainId = userId;
			}];
			
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
			[[QJPassport sharedPassport] requestUserFollowList:nil
			pageNum:1
			pageSize:20
			finished:^(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				if (error)
					XCTFail(@"testUserImageListExample error: %@", error);
			}];
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testUserImageListExample error: %@", error);
		}];
	}];
}

#pragma mark - 发布图片

- (void)testSendImageExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testActionExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			[[QJPassport sharedPassport] loginUser:kPhoneNumber
			password:kPassword
			finished:^(NSNumber * userId, NSString * ticket, NSError * error) {
				if (error)
					XCTFail(@"testActionExample error: %@", error);
			}];
			
			NSString * url = @"http://b.hiphotos.baidu.com/image/pic/item/faf2b2119313b07e73cdc2690ad7912397dd8c5b.jpg";
			NSData * imageData1 = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
			returningResponse:nil
			error:nil];
			
			url = @"http://a.hiphotos.baidu.com/image/pic/item/1f178a82b9014a90aeefd5dcaf773912b21beefa.jpg";
			NSData * imageData2 = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
			returningResponse:nil
			error:nil];
			
			dispatch_semaphore_t sem = dispatch_semaphore_create(0);
			AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://mapp.tiankong.com"]];
			[manager POST:@"/imageUser/save.user"
			parameters:@{@"tag": @"美女",
						 @"open": [NSNumber numberWithInt:1]}
			constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData1
                                            name:@"f1"
                                        fileName:@"upload1.jpg"
                                        mimeType:@"application/octet-stream"];
                [formData appendPartWithFileData:imageData1
                                            name:@"f2"
                                        fileName:@"upload2.jpg"
                                        mimeType:@"application/octet-stream"];
            }
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
				dispatch_semaphore_signal(sem);
			}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
				dispatch_semaphore_signal(sem);
			}];
			dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
			
			[expectation fulfill];
		});
		[self waitForExpectationsWithTimeout:300.0 handler:^(NSError * error) {
			if (error)
				XCTFail(@"testActionExample error: %@", error);
		}];
	}];
}

@end
