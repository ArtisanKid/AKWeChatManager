//
//  AKWeChatManagerMacro.h
//  Pods
//
//  Created by 李翔宇 on 2017/1/16.
//
//

#ifndef AKWeChatManagerMacro_h
#define AKWeChatManagerMacro_h

#if DEBUG
    #define AKWeChatManagerLog(_Format, ...) NSLog((@"\n[File:%s]\n[Line:%d]\n[Function:%s]\n" _Format), __FILE__, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__);printf("\n");
#else
    #define AKWeChatManagerLog(_Format, ...)
#endif

//nil和类型判断
//_stuff传入{}(代码块)

#define AKWXM_String_Nilable_Return(_string, _nilable, _stuff, ...) \
    do {\
        NSString *string = (NSString *)(_string);\
        if(string) {\
            if(![string isKindOfClass:[NSString class]]) {\
                NSAssert(0, nil);\
                _stuff;\
                return __VA_ARGS__;\
            }\
            \
            if(!_nilable) {\
                if(!string.length) {\
                    NSAssert(0, nil);\
                    _stuff;\
                    return __VA_ARGS__;\
                }\
            }\
        } else if(!_nilable) {\
            NSAssert(0, nil);\
            _stuff;\
            return __VA_ARGS__;\
        }\
    } while(0)

#endif /* AKWeChatManagerMacro_h */
