#import "RKObjectMapping+Transforming.h"
#import <TransformerKit/NSValueTransformer+TransformerKit.h>
#import <TransformerKit/TTTStringTransformers.h>

@implementation RKObjectMapping (Transforming)

+ (id)mappingForClassWithLlamaCaseTransforming:(Class)objectClass
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:objectClass];
    [mapping enableLlamaCaseTransforming];
    return mapping;
}

- (void)enableLlamaCaseTransforming
{
    [self setSourceToDestinationKeyTransformationBlock:^NSString*(RKObjectMapping* mapping, NSString* sourceKey) {
         return [[NSValueTransformer valueTransformerForName:TTTLlamaCaseStringTransformerName] transformedValue:sourceKey];
     }

    ];
}

@end