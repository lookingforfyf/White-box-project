//
// XMLWriter.h
//
//  Changed by RealZYC on 10/31/2016
//

#import <Foundation/Foundation.h>

@interface XMLWriter : NSObject
{
    NSMutableArray * nodes;
    NSMutableData  * xml;
    NSMutableArray * treeNodes;
    BOOL             isRoot;
    NSString       * passDict;
    BOOL             withHeader;
}

/* 字典转XML字符串 */
+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
                    withStartElement:(NSString *)startElement
                      isFirstElement:(BOOL) isFirstElement;

+ (NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary;

+ (NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary
                       withHeader:(BOOL)header; 

+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary;

+ (NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
                           withHeader:(BOOL)header;

+ (BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary
                 toStringPath:(NSString *)path
                        Error:(NSError **)error;

@end
