//
//  NIST_GCDAsyncSocketRequestElementModel.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/26.
//  Copyright © 2017年 范云飞. All rights reserved.
//

/*****************************************
 本类主要负责：
 1.响应报文模型中最小单元
 *****************************************/
#import <JSONModel/JSONModel.h>

@interface NIST_GCDAsyncSocketRequestElementModel : JSONModel
@property (nonatomic , copy) NSString  <Optional>* desc;    /* 描述字段 */
@property (nonatomic , copy) NSString  <Optional>* text;    /* 数据字段 */
@end
