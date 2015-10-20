#pragma once

#import "WTForward.h"
#import "WTDefine.h"
#import "WTConstants.h"
#import "WTError.h"
#import "WTDebug.h"
#import "HXLoginStatus.h"
#ifdef __OBJC__

#import "OWTGlobalThemer.h"

extern NSString* kWTScrollUpNotification;
extern NSString* kWTScrollDownNotification;

extern NSString* kWTHideMainTabBarNotification;
extern NSString* kWTShowMainTabBarNotification;

extern NSString* kWTLoggedOutNotification;

#if __cplusplus
extern "C" {
#endif
HXLoginStatus* GetHXStatus();
OWTGlobalThemer* GetThemer();
OWTAppDelegate* GetAppDelegate();
OWTUserManager* GetUserManager();
OWTAuthManager* GetAuthManager();
OWTDataManager* GetDataManager();
OWTFeedManager* GetFeedManager();
OWTCategoryManager* GetCategoryManager();
OWTAssetManager* GetAssetManager();
OWTActivityManager* GetActivityManager();
OWTRecommendationManager* GetRecommendationManager();
   OWTRecommendationManager1* GetRecommendationManager1();
OWTSearchManager* GetSearchManager();

    
    //dutu
    OWTCategoryManagerlife* GetCategoryManagerlife();
    OWTCategoryManagerbaike* GetCategoryManagerbaike();
    
    
    OWTCategoryManagershishang* GetCategoryManagershishang();
    OWTCategoryManagerlvyou* GetCategoryManagerlvyou();
    OWTCategoryManagerlvyouinternational * GetCategoryManagerlvyouinternational();
    OWTCategoryManagerjiaju* GetCategoryManagerjiaju();
    OWTCategoryManagerbaike* GetCategoryManagerbaike();

    OWTCategoryManagerqiche* GetCategoryManagerqiche();
    OWTCategoryManagermeishi* GetCategoryManagermeishi();
    //
#if __cplusplus
}
#endif

#endif
