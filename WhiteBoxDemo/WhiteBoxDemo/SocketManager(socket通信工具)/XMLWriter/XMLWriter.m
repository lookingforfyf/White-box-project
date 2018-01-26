//
//  XMLWriter.m
//
#import "XMLWriter.h"

#define PREFIX_STRING_FOR_ELEMENT @"@" /* From XMLReader */

@implementation XMLWriter
- (void)serialize:(id)root
{    
    if([root isKindOfClass:[NSArray class]])
        {
            int mula = (int)[root count];
            mula--;
            [nodes addObject:[NSString stringWithFormat:@"%i",(int)mula]];

            for(id objects in root)
            {
                if ([[nodes lastObject] isEqualToString:@"0"] || [nodes lastObject] == NULL || ![nodes count])
                {
                    [nodes removeLastObject];
                    [self serialize:objects];
                }
                else
                {
                    [self serialize:objects];
                    if(!isRoot)
                    {
                        NSString * itemLast = [NSString stringWithFormat:@"</%@><%@>",
                                              [treeNodes lastObject],
                                              [treeNodes lastObject]];
                        itemLast = [itemLast stringByReplacingOccurrencesOfString:@"</(null)><(null)>" withString:@"\n"]; //RealZYC
                        [xml appendData:[itemLast dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    else
                        isRoot = FALSE;
                    int value = [[nodes lastObject] intValue];
                    [nodes removeLastObject];
                    value--;
                    [nodes addObject:[NSString stringWithFormat:@"%i",(int)value]];
                }
            }
        }
        else if ([root isKindOfClass:[NSDictionary class]])
        {
            for (NSString* key in root)
            {
                if(!isRoot)
                {
                    [treeNodes addObject:key];
                    [xml appendData:[[NSString stringWithFormat:@"<%@>",key] dataUsingEncoding:NSUTF8StringEncoding]];
                    [self serialize:[root objectForKey:key]];
                    [xml appendData:[[NSString stringWithFormat:@"</%@>",key] dataUsingEncoding:NSUTF8StringEncoding]];
                    [treeNodes removeLastObject];
                }
                else
                {
                    isRoot = FALSE;
                    [self serialize:[root objectForKey:key]];
                }
            }
        }
        else if ([root isKindOfClass:[NSString class]] || [root isKindOfClass:[NSNumber class]] || [root isKindOfClass:[NSURL class]])
        {
            [xml appendData:[[NSString stringWithFormat:@"%@",root] dataUsingEncoding:NSUTF8StringEncoding]];
        }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        xml = [[NSMutableData alloc] init];
        if (withHeader)
        {
            [xml appendData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        nodes = [[NSMutableArray alloc] init]; 
        treeNodes = [[NSMutableArray alloc] init]; 
        isRoot = YES;
        passDict = [[dictionary allKeys] lastObject];
//        [xml appendData:[[NSString stringWithFormat:@"<%@>\n",passDict] dataUsingEncoding:NSUTF8StringEncoding]];
        [xml appendData:[[NSString stringWithFormat:@"<%@>",passDict] dataUsingEncoding:NSUTF8StringEncoding]];

        [self serialize:dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header
{
    withHeader = header;
    self = [self initWithDictionary:dictionary];
    return self;
}

- (void)dealloc
{
    nodes = nil ;
    treeNodes = nil;
}

- (NSData *)getXML
{
    [xml appendData:[[NSString stringWithFormat:@"\n</%@>",passDict] dataUsingEncoding:NSUTF8StringEncoding]];
    return xml;
}

+ (NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
    {
        return NULL;
    }
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary];
    return [fromDictionary getXML];
}

+ (NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary
                       withHeader:(BOOL)header
{
    if (![[dictionary allKeys] count])
    {
        return NULL;
    }
    XMLWriter * fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary withHeader:header];
    return [fromDictionary getXML];
}

+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
{
    return [[NSString alloc]initWithData:[XMLWriter XMLDataFromDictionary:dictionary] encoding:NSUTF8StringEncoding];
}

+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
                           withHeader:(BOOL)header
{
    return [[NSString alloc]initWithData:[XMLWriter XMLDataFromDictionary:dictionary withHeader:header] encoding:NSUTF8StringEncoding];
}

+ (BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary
                 toStringPath:(NSString *) path
                        Error:(NSError **)error
{
    
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary];
    [[fromDictionary getXML] writeToFile:path atomically:YES];
    if (error)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary withStartElement:(NSString *)startElement isFirstElement:(BOOL)isFirstElement
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    NSArray *arr = [dictionary allKeys];
    if (isFirstElement)
    {
        [xml appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    }
    [xml appendString:[NSString stringWithFormat:@"<%@>\n", startElement]];
    for(NSUInteger i = 0; i < [arr count]; i++)
    {
        NSString *nodeName = [arr objectAtIndex:i];
        id nodeValue = [dictionary objectForKey:nodeName];
        if([nodeValue isKindOfClass:[NSArray class]])
        {
            if([nodeValue count]>0)
            {
                for(NSUInteger j = 0; j < [nodeValue count];j++)
                {
                    id value = [nodeValue objectAtIndex:j];
                    if([value isKindOfClass:[NSDictionary class]])
                    {
                        [xml appendString:[self XMLStringFromDictionary:value withStartElement:nodeName isFirstElement:NO]];
                    }
                } 
            }
        }
        else if([nodeValue isKindOfClass:[NSDictionary class]])
        {
            [xml appendString:[self XMLStringFromDictionary:nodeValue withStartElement:nodeName isFirstElement:NO]];
        }
        else
        {
            //            if([nodeValue length]>0){
            [xml appendString:[NSString stringWithFormat:@"<%@>",nodeName]];
            [xml appendString:[NSString stringWithFormat:@"%@",[dictionary objectForKey:nodeName]]];
            [xml appendString:[NSString stringWithFormat:@"</%@>\n",nodeName]];
            //            }
        }
    }
    [xml appendString:[NSString stringWithFormat:@"</%@>\n",startElement]];
    NSString *finalxml=[xml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    return finalxml;
}

#pragma mark - MLeaksFinder（内存泄漏检测工具）
- (BOOL)willDealloc
{
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf assertNotDealloc];
    });
    return YES;
}

- (void)assertNotDealloc
{
    NSAssert(NO, @"内存泄漏");
}

@end
