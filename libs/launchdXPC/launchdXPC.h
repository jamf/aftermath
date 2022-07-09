//
//  launchdXPC.h
//
//  Created by Patrick Wardle
//  Ported from code by Jonathan Levin
//

#ifndef launchdXPC_h
#define launchdXPC_h

#include <xpc/xpc.h>
#include <mach/task.h>
#include <objc/objc.h>

#import <Foundation/Foundation.h>

int getSubmittedPid(int pid);

//hit up launchd (via XPC) to get process info
NSString* getSubmittedByPlist(unsigned long pid);

//launchd structs/functions
// inspired by: http://newosxbook.com/articles/jlaunchctl.html
struct xpc_global_data {
    
    uint64_t    a;
    uint64_t    xpc_flags;
    mach_port_t task_bootstrap_port;
#ifndef _64
    uint32_t    padding;
#endif
    xpc_object_t   xpc_bootstrap_pipe;
};
 
struct _os_alloc_once_s {
    long once;
    void *ptr;
};
extern struct _os_alloc_once_s _os_alloc_once_table[];

typedef struct _xpc_pipe_s* xpc_pipe_t;

__attribute__((weak_import))
int xpc_pipe_routine(xpc_pipe_t pipe, xpc_object_t message, xpc_object_t *reply);
int xpc_pipe_interface_routine(xpc_pipe_t pipe, int request, xpc_object_t message, xpc_object_t *reply, int unknown);

#endif
