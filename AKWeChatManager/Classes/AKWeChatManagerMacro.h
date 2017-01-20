//
//  AKWeChatManagerMacro.h
//  Pods
//
//  Created by 李翔宇 on 2017/1/16.
//
//

#ifndef AKWeChatManagerMacro_h
#define AKWeChatManagerMacro_h

static BOOL AKWeChatManagerLogState = YES;

#define AKWeChatManagerLogFormat(INFO, ...) [NSString stringWithFormat:(@"\n[Date:%s]\n[Time:%s]\n[File:%s]\n[Line:%d]\n[Function:%s]\n" INFO @"\n"), __DATE__, __TIME__, __FILE__, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__]

#if DEBUG
#define AKWeChatManagerLog(INFO, ...) !AKWeChatManagerLogState ? : NSLog((@"\n[Date:%s]\n[Time:%s]\n[File:%s]\n[Line:%d]\n[Function:%s]\n" INFO @"\n"), __DATE__, __TIME__, __FILE__, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__);
#else
#define AKWeChatManagerLog(INFO, ...)
#endif

//nil和类型判断
#define AK_WXM_Nilable_Class_Return(_obj, _nilable, _class, _stuff, ...) \
    if(!_nilable) {\
        NSParameterAssert(_obj);\
        if(!_obj) {\
            _stuff;\
            return __VA_ARGS__;\
        }\
    }\
    if(_obj) {\
        NSParameterAssert([_obj isKindOfClass:_class.class]);\
        if(![_obj isKindOfClass:_class.class]) {\
            _stuff;\
            return __VA_ARGS__;\
    }\
}

#endif /* AKWeChatManagerMacro_h */
