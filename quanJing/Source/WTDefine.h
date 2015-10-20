#pragma once

#ifndef ASSERTION_ENABLED
#define ASSERTION_ENABLED 1
#endif

#ifndef ASSERTION_TRACE_ENABLED
#define ASSERTION_TRACE_ENABLED 1
#endif

#if ASSERTION_ENABLED
#   include <assert.h>
#   define AssertFATAL(expr) NSCAssert(expr, @"")
#   define AssertFATALC(condition, expr) do { if (condition) { NSCAssert(expr, @""); } } while(0)
#else
#   define AssertFATAL(expr)
#   define AssertFATALC(condition, expr)
#endif

#if ASSERTION_TRACE_ENABLED
#   define AssertTR(expr) \
    do { \
        if(!(expr)) { \
            DDLogError(@"Assertion failure in %s, %s:%d\nCondition not satisfied: %s.", __PRETTY_FUNCTION__, __FILE__, __LINE__, #expr); \
        } \
    } while(0)
#else
#   define AssertTR(expr) AssertFATAL(expr)
#endif

#define AssertShouldNotReachHere AssertTR (!"Should not reach here.");
#define AssertNotImplemented     AssertFATAL (!"Not implemented yet.");
#define AssertBadParam           AssertFATAL (!"Bad Parameter!");

typedef enum
{
    nWTDoneTypeCancelled,
    nWTDoneTypeCreated,
    nWTDoneTypeUpdated,
    nWTDoneTypeDeleted,
} EWTDoneType;
