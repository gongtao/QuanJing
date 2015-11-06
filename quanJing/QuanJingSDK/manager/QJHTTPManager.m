//
//  QJHTTPManager.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJHTTPManager.h"

#import "QJServerConstants.h"

#import "UIDevice-Hardware.h"

@interface QJHTTPManager ()
{
	AFHTTPClient * _httpRequestManager;
}

@property (readwrite, nonatomic, strong) NSString * userAgent;

@end

@implementation QJHTTPManager

+ (instancetype)sharedManager
{
	static QJHTTPManager * sharedManager = nil;
	static dispatch_once_t t;
	
	dispatch_once(&t, ^{
		sharedManager = [[QJHTTPManager alloc] init];
	});
	return sharedManager;
}

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		NSString * userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
		// User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
		NSArray * languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
		userAgent = [NSString stringWithFormat:@"%@/%@;%@;%@;iOS %@;%@;", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] ? :[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ? :[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] machine], [[UIDevice currentDevice] ROM], [[UIDevice currentDevice] systemVersion], languages[0]];
		
#pragma clang diagnostic pop

		if (userAgent) {
			if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
				NSMutableString * mutableUserAgent = [userAgent mutableCopy];
				
				if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false))
					userAgent = mutableUserAgent;
			}
			[self.httpRequestManager setDefaultHeader:userAgent value:@"User-Agent"];
			_userAgent = userAgent;
		}
		
		[self.httpRequestManager setDefaultHeader:@"Accept" value:@"application/json,text/json,text/javascript"];
		[self.httpRequestManager registerHTTPOperationClass:[AFJSONRequestOperation class]];
	}
	return self;
}

#pragma mark - Property

- (AFHTTPClient *)httpRequestManager
{
	if (!_httpRequestManager)
		_httpRequestManager = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kQJServerURL]];
	return _httpRequestManager;
}

@end
