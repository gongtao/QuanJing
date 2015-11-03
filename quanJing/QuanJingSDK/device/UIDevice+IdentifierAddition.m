//
//  UIDevice(Identifier).m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "QJUDIDKeyChainUtil.h"
#import "QJCoreMacros.h"
#import "QJUtils.h"

#include <sys/socket.h>	// Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice (Private)

- (NSString *)macaddress;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macaddress
{
	int mib[6];
	size_t len;
	char * buf;
	unsigned char * ptr;
	struct if_msghdr * ifm;
	struct sockaddr_dl * sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString * outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
		*ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
	free(buf);
	
	return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *)uniqueDeviceIdentifier
{
	NSString * macaddress = [[UIDevice currentDevice] macaddress];
	NSString * bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	
	NSString * stringToHash = [NSString stringWithFormat:@"%@%@", macaddress, bundleIdentifier];
	NSString * uniqueIdentifier = [QJUtils md5String:stringToHash];
	
	return uniqueIdentifier;
}

- (NSString *)uniqueGlobalDeviceIdentifier
{
	static NSString * uniqueIdentifier = nil;
	
	if (!QJ_IS_STR_NIL(uniqueIdentifier))
		return uniqueIdentifier;
		
	uniqueIdentifier = [QJUDIDKeyChainUtil getUDIDFromKeyChain];
	
	if (QJ_IS_STR_NIL(uniqueIdentifier)) {
		if (![[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
			// lower than ios 7.0
			NSString * macaddress = [[UIDevice currentDevice] macaddress];
			uniqueIdentifier = [QJUtils md5String:macaddress];
		}
		else {
			// 7.0 and later
			NSString * uniqueId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
			uniqueIdentifier = [QJUtils md5String:uniqueId];
		}
		
		if (QJ_IS_STR_NIL(uniqueIdentifier))
			// for protection
			return @"";
		else
			[QJUDIDKeyChainUtil setUDIDToKeyChain:uniqueIdentifier];
	}
	return uniqueIdentifier;
}

@end
