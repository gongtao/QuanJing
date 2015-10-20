#import "WTCommon.h"
#import "OWTAppDelegate.h"

NSString* kWTScrollUpNotification = @"kWTScrollUpNotification";
NSString* kWTScrollDownNotification = @"kWTScrollDownNotification";

NSString* kWTHideMainTabBarNotification = @"kWTHideMainTabBarNotification";
NSString* kWTShowMainTabBarNotification = @"kWTShowMainTabBarNotification";

NSString* kWTLoggedOutNotification = @"kWTLoggedOutNotification";

OWTAppDelegate* GetAppDelegate()
{
    return (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
}

OWTGlobalThemer* GetThemer()
{
    return GetAppDelegate().themer;
}

OWTUserManager* GetUserManager()
{
    return GetAppDelegate().userManager;
}

HXLoginStatus* GetHXStatus()
{
    return GetAppDelegate().hxStatus;
}

OWTAuthManager* GetAuthManager()
{
    return GetAppDelegate().authManager;
}

OWTDataManager* GetDataManager()
{
    OWTAppDelegate* appDelegate = GetAppDelegate();
    return appDelegate.dataManager;
}

OWTFeedManager* GetFeedManager()
{
    return GetAppDelegate().feedManager;
}

OWTCategoryManager* GetCategoryManager()
{
    return GetAppDelegate().categoryManager;
}
//增加读图
OWTCategoryManagerlife* GetCategoryManagerlife()
{
    return GetAppDelegate().categoryManagerlife;
}
OWTCategoryManagerbaike* GetCategoryManagerbaike()
{
    return GetAppDelegate().categoryManagerbaike;
}


OWTCategoryManagershishang* GetCategoryManagershishang()
{
    return GetAppDelegate().categoryManagershishang;
}
OWTCategoryManagerlvyou* GetCategoryManagerlvyou()
{
    return GetAppDelegate().categoryManagerlvyou;
}
OWTCategoryManagerlvyouinternational* GetCategoryManagerlvyouinternational()
{
    return GetAppDelegate().categoryManagerlvyouinternational;
}


OWTCategoryManagerjiaju* GetCategoryManagerjiaju()
{
    return GetAppDelegate().categoryManagerjiaju;
}
OWTCategoryManagerqiche* GetCategoryManagerqiche()
{
    return GetAppDelegate().categoryManagerqiche;
}
OWTCategoryManagermeishi* GetCategoryManagermeishi()
{
    return GetAppDelegate().categoryManagermeishi;
}

//
OWTAssetManager* GetAssetManager()
{
    return GetAppDelegate().assetManager;
}

OWTActivityManager* GetActivityManager()
{
    return GetAppDelegate().activityManager;
}

OWTRecommendationManager* GetRecommendationManager()
{
    return GetAppDelegate().recommendationManager;
}
OWTRecommendationManager1* GetRecommendationManager1()
{
    return GetAppDelegate().recommendationManager1;
}

OWTSearchManager* GetSearchManager()
{
    return GetAppDelegate().searchManager;
}
