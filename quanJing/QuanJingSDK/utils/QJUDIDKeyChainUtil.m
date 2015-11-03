//
//  MPUDIDKeyChainUtil.m
//  MiPassportFoundation
//
//  Created by Gongtao on 15/4/16.
//  Copyright (c) 2015年 Xiaomi. All rights reserved.
//

#import "QJUDIDKeyChainUtil.h"

#import "QJCoreMacros.h"

static const char kKeychainUDIDItemIdentifier[] = "UUID";

static NSString * keyChainUDIDAccessGroup = nil;

@implementation QJUDIDKeyChainUtil

#pragma mark - Helper Method for make identityForVendor consistency

+ (void)setKeyChainAccessGroup:(NSString *)group
{
	keyChainUDIDAccessGroup = [group copy];
}

+ (NSString *)getUDIDFromKeyChain
{
	NSMutableDictionary * dictForQuery = [[NSMutableDictionary alloc] init];
	
	[dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	// set Attr Description for query
	[dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]
	forKey:(id)kSecAttrDescription];
	
	// set Attr Identity for query
	NSData * keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
		length:strlen(kKeychainUDIDItemIdentifier)];
	[dictForQuery setObject:keychainItemID forKey:(id)kSecAttrGeneric];
	
	// The keychain access group attribute determines if this item can be shared
	// amongst multiple apps whose code signing entitlements contain the same keychain access group.
	if (!QJ_IS_STR_NIL(keyChainUDIDAccessGroup)) {
#if TARGET_IPHONE_SIMULATOR
			// Ignore the access group if running on the iPhone simulator.
			//
			// Apps that are built for the simulator aren't signed, so there's no keychain access group
			// for the simulator to check. This means that all apps can see all keychain items when run
			// on the simulator.
			//
			// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
			// simulator will return -25243 (errSecNoAccessForItem).
#else
			NSString * accessGroup = [keyChainUDIDAccessGroup copy];
			[dictForQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
	}
	
	[dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
	[dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	OSStatus queryErr = noErr;
	NSString * udid = nil;
	CFTypeRef udidValueRef = NULL;
	queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, &udidValueRef);
	
	if (queryErr != errSecSuccess)
		NSLog(@"KeyChain Item query Error: %ld", (long)queryErr);
	NSData * udidValue = (__bridge_transfer NSData *)udidValueRef;
	
	CFTypeRef dictRef = NULL;
	[dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, &dictRef);
	NSMutableDictionary * dict = (__bridge_transfer NSMutableDictionary *)dictRef;
	
	if (queryErr == errSecItemNotFound)
		NSLog(@"KeyChain Item: %@ not found", [NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]);
	else if (queryErr != errSecSuccess)
		NSLog(@"KeyChain Item query Error: %ld", (long)queryErr);
		
	if (queryErr == errSecSuccess) {
		NSLog(@"KeyChain Item: %@", udidValue);
		NSLog(@"KeyChain Dict: %@", dict);
		
		if (udidValue)
			udid = [NSString stringWithUTF8String:udidValue.bytes];
	}
	return udid;
}

+ (BOOL)setUDIDToKeyChain:(NSString *)udid
{
	NSMutableDictionary * dictForAdd = [[NSMutableDictionary alloc] init];
	
	[dictForAdd setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(id)kSecAttrDescription];
	
	[dictForAdd setValue:@"UUID" forKey:(id)kSecAttrGeneric];
	
	// Default attributes for keychain item.
	[dictForAdd setObject:@"" forKey:(id)kSecAttrAccount];
	[dictForAdd setObject:@"" forKey:(id)kSecAttrLabel];
	
	// The keychain access group attribute determines if this item can be shared
	// amongst multiple apps whose code signing entitlements contain the same keychain access group.
	if (!QJ_IS_STR_NIL(keyChainUDIDAccessGroup)) {
#if TARGET_IPHONE_SIMULATOR
			// Ignore the access group if running on the iPhone simulator.
			//
			// Apps that are built for the simulator aren't signed, so there's no keychain access group
			// for the simulator to check. This means that all apps can see all keychain items when run
			// on the simulator.
			//
			// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
			// simulator will return -25243 (errSecNoAccessForItem).
#else
			NSString * accessGroup = [keyChainUDIDAccessGroup copy];
			[dictForAdd setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
	}
	
	const char * udidStr = [udid UTF8String];
	NSData * keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
	[dictForAdd setValue:keyChainItemValue forKey:(id)kSecValueData];
	
	OSStatus writeErr = noErr;
	
	if ([QJUDIDKeyChainUtil getUDIDFromKeyChain]) {			// there is item in keychain
		[QJUDIDKeyChainUtil updateUDIDInKeyChain:udid];
		return YES;
	}
	else {			// add item to keychain
		writeErr = SecItemAdd((CFDictionaryRef)dictForAdd, NULL);
		
		if (writeErr != errSecSuccess) {
			NSLog(@"Add KeyChain Item Error: %ld", (long)writeErr);
			
			return NO;
		}
		else {
			NSLog(@"Add KeyChain Item Success");
			return YES;
		}
	}
	
	return NO;
}

+ (BOOL)removeUDIDFromKeyChain
{
	NSMutableDictionary * dictToDelete = [[NSMutableDictionary alloc] init];
	
	[dictToDelete setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	NSData * keyChainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier length:strlen(kKeychainUDIDItemIdentifier)];
	[dictToDelete setValue:keyChainItemID forKey:(id)kSecAttrGeneric];
	
	OSStatus deleteErr = noErr;
	deleteErr = SecItemDelete((CFDictionaryRef)dictToDelete);
	
	if (deleteErr != errSecSuccess) {
		NSLog(@"delete UUID from KeyChain Error: %ld", (long)deleteErr);
		return NO;
	}
	else {
		NSLog(@"delete UUID from KeyChain success");
	}
	return YES;
}

+ (BOOL)updateUDIDInKeyChain:(NSString *)newUDID
{
	NSMutableDictionary * dictForQuery = [[NSMutableDictionary alloc] init];
	
	[dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	NSData * keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
		length:strlen(kKeychainUDIDItemIdentifier)];
	[dictForQuery setValue:keychainItemID forKey:(id)kSecAttrGeneric];
	[dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
	[dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	
	CFTypeRef queryResultRef = NULL;
	SecItemCopyMatching((CFDictionaryRef)dictForQuery, &queryResultRef);
	NSDictionary * queryResult = (__bridge_transfer NSDictionary *)queryResultRef;
	
	if (queryResult) {
		NSMutableDictionary * dictForUpdate = [[NSMutableDictionary alloc] init];
		[dictForUpdate setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:(id)kSecAttrDescription];
		[dictForUpdate setValue:keychainItemID forKey:(id)kSecAttrGeneric];
		
		const char * udidStr = [newUDID UTF8String];
		NSData * keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
		[dictForUpdate setValue:keyChainItemValue forKey:(id)kSecValueData];
		
		OSStatus updateErr = noErr;
		
		// First we need the attributes from the Keychain.
		NSMutableDictionary * updateItem = [NSMutableDictionary dictionaryWithDictionary:queryResult];
		
		// Second we need to add the appropriate search key/values.
		// set kSecClass is Very important
		[updateItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
		
		updateErr = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)dictForUpdate);
		
		if (updateErr != errSecSuccess) {
			NSLog(@"Update KeyChain Item Error: %ld", (long)updateErr);
			return NO;
		}
		else {
			NSLog(@"Update KeyChain Item Success");
			return YES;
		}
	}
	return NO;
}

@end
