#pragma once

#import <RestKit/ObjectMapping/RKObjectMapping.h>

@interface RKObjectMapping (Transforming)

+ (id)mappingForClassWithLlamaCaseTransforming:(Class)objectClass;
- (void)enableLlamaCaseTransforming;

@end