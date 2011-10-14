//
//  NSObject+Runtime.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/***************
 Property declaration
 Property description
 @property char charDefault;                                                            Tc,VcharDefault
 @property double doubleDefault;                                                        Td,VdoubleDefault
 @property enum FooManChu enumDefault;                                                  Ti,VenumDefault
 @property float floatDefault;                                                          Tf,VfloatDefault
 @property int intDefault;                                                              Ti,VintDefault
 @property long longDefault;                                                            Tl,VlongDefault
 @property short shortDefault;                                                          Ts,VshortDefault
 @property signed signedDefault;                                                        Ti,VsignedDefault
 @property struct YorkshireTeaStruct structDefault;                                     T{YorkshireTeaStruct="pot"i"lady"c},VstructDefault
 @property YorkshireTeaStructType typedefDefault;                                       T{YorkshireTeaStruct="pot"i"lady"c},VtypedefDefault
 @property union MoneyUnion unionDefault;                                               T(MoneyUnion="alone"f"down"d),VunionDefault
 @property unsigned unsignedDefault;                                                    TI,VunsignedDefault
 @property int (*functionPointerDefault)(char *);                                       T^?,VfunctionPointerDefault
 @property id idDefault;                                                                T@,VidDefault                                Note: the compiler warns: no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed"                
 @property int *intPointer;                                                             T^i,VintPointer
 @property void *voidPointerDefault;                                                    T^v,VvoidPointerDefault
 
 @property int intSynthEquals;
 @synthesize intSynthEquals=_intSynthEquals;                                            Ti,V_intSynthEquals                           In the implementation block:

 @property(getter=intGetFoo, setter=intSetFoo:) int intSetterGetter;                    Ti,GintGetFoo,SintSetFoo:,VintSetterGetter
 @property(readonly) int intReadonly;                                                   Ti,R,VintReadonly
 @property(getter=isIntReadOnlyGetter, readonly) int intReadonlyGetter;                 Ti,R,GisIntReadOnlyGetter
 @property(readwrite) int intReadwrite;                                                 Ti,VintReadwrite
 @property(assign) int intAssign;                                                       Ti,VintAssign
 @property(retain) id idRetain;                                                         T@,&,VidRetain
 @property(copy) id idCopy;                                                             T@,C,VidCopy
 @property(nonatomic) int intNonatomic;                                                 Ti,VintNonatomic
 @property(nonatomic, readonly, copy) id idReadonlyCopyNonatomic;                       T@,R,C,VidReadonlyCopyNonatomic
 @property(nonatomic, readonly, retain) id idReadonlyRetainNonatomic;                   T@,R,&,VidReadonlyRetainNonatomic
 
 */

#import "NSObject+Runtime.h"
#import <Foundation/Foundation.h>

@implementation NSObject (Helper)

- (void)printProperties {
    unsigned int outCount = 0;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        const char *attributesName = property_getAttributes(propertyList[i]);
        
        unsigned int attributeCount;
        objc_property_attribute_t *attribute_t = property_copyAttributeList(propertyList[i], &attributeCount);
        for(int i = 0; i < attributeCount;i++){
            NSLog(@"--------------  name : %s value : %s",attribute_t[i].name,attribute_t[i].value);
        }
        free(attribute_t);
        
        char type = attributesName[1];
        SEL property = NSSelectorFromString([NSString stringWithFormat:@"%s",propertyName]);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:property]];
        [invocation setTarget:self];
        [invocation setSelector:property];
        [invocation invoke];

        switch (type) {
            case '@':
            {       //id
                NSObject* returnValue = nil;
                [invocation getReturnValue:&returnValue];
                printf("%s : %s\n", propertyName,[[returnValue debugDescription] UTF8String]);
                break;
            }
            case 'i':
            {       //Integer
                int returnValue;
                [invocation getReturnValue:&returnValue];
                printf("%s : %d\n",propertyName,returnValue);
                break;
            }
            case 'f':
            case 'd':
            case 'l':
            case 's':
            {   
                float returnValue;
                [invocation getReturnValue:&returnValue];
                printf("%s : %0.0f\n",propertyName,returnValue);
                break;
            }
            default:
                break;
        }
        
    }
    free(propertyList);
}

- (void)setAssociatedObject:(id)object forKey:(char *)hashKey {
    objc_setAssociatedObject(self, hashKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

- (void)setAssociatedObject:(id)object forKey:(char *)hashKey policy:(NSAssociationPolicy)policy{
    objc_setAssociatedObject(self, hashKey, object, policy);    
}

- (id)associatedObjectForKey:(char *)hashKey {
    return objc_getAssociatedObject(self, hashKey);    
}

@end
