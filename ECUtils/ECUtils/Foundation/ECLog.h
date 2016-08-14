//
//  ECLog.h
//  ECUtils
//
//  Created by kiri on 16/8/15.
//  Copyright © 2016年 kiri. All rights reserved.
//

#ifndef ECLog_h
#define ECLog_h

#ifdef DEBUG
#define ECLogDebug(fmt, ...) NSLog(fmt @" %s line:%d", ##__VA_ARGS__, __PRETTY_FUNCTION__, __LINE__)
#else
#define ECLogDebug(fmt, ...)
#endif

#define ECLogError(fmt, ...) NSLog(fmt @" %s line:%d", ##__VA_ARGS__, __PRETTY_FUNCTION__, __LINE__)

#endif /* ECLog_h */
