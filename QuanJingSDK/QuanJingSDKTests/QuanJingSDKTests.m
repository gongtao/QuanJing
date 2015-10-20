//
//  QuanJingSDKTests.m
//  QuanJingSDKTests
//
//  Created by QJ on 15/10/18.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QuanJingSDK.h"

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

// 发送注册短信
- (void)testSendRegistSMSExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testSendRegistSMSExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [[QJPassport sharedPassport] sendRegistSMS:@"18600962172"];
			
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

// 注册
- (void)testUserRegistExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserRegistExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJPassport sharedPassport] registerUser:@"18600962172"
			password:@"Gongtao1987"
			code:@"278715"
			finished:^(QJUser * user, NSDictionary * userDic, NSError * error) {
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

- (void)testUserExample
{
	// This is an example of a functional test case.
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	[self measureBlock:^{
		XCTestExpectation * expectation = [self expectationWithDescription:@"testUserExample"];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// Login
			NSError * error = [[QJPassport sharedPassport] loginUser:@"18600962172" password:@"Gongtao1987"];
			
			if (error)
				XCTFail(@"testUserExample error: %@", error);
				
			NSLog(@"isLogin: %i", [[QJPassport sharedPassport] isLogin]);
			
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

// 首页
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

// 搜索
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

// 图片分类
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

@end
