//
//  Dispatching.h
//  Common
//
//  Created by Bing SU on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

static inline
void DispatchMQAfter(double seconds, dispatch_block_t block)
{
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * 1000.f) * 1000ull * 1000ull);
    dispatch_after(t, dispatch_get_main_queue(), block);
}

static inline
void DispatchMQAsync(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}
