//
//  AVIMConversation_Internal.h
//  AVOSCloudIM
//
//  Created by Qihe Bian on 12/12/14.
//  Copyright (c) 2014 LeanCloud Inc. All rights reserved.
//

#import "AVIMConversation.h"

/* key of the conversation's attribute */
///

/* Value Type: NSString */
static NSString * const kConvAttrKey_conversationId       = @"objectId";
static NSString * const kConvAttrKey_uniqueId             = @"uniqueId";

/* Value Type: NSString */
static NSString * const kConvAttrKey_name                 = @"name";
static NSString * const kConvAttrKey_avatarURL            = @"avatarURL";
static NSString * const kConvAttrKey_creator              = @"c";
static NSString * const kConvAttrKey_createdAt            = @"createdAt";
static NSString * const kConvAttrKey_updatedAt            = @"updatedAt";
static NSString * const kConvAttrKey_lastMessageAt        = @"lm";
static NSString * const kConvAttrKey_lastMessage          = @"msg";
static NSString * const kConvAttrKey_lastMessageId        = @"msg_mid";
static NSString * const kConvAttrKey_lastMessageFrom      = @"msg_from";

/* Value Type: NSNumber double */
static NSString * const kConvAttrKey_lastMessageTimestamp = @"msg_timestamp";

/* Value Type: NSDictionary */
static NSString * const kConvAttrKey_attributes           = @"attr";

/* Value Type: NSArray */
static NSString * const kConvAttrKey_members              = @"m";
static NSString * const kConvAttrKey_membersMuted         = @"mu";

/* Value Type: NSNumber BOOL */
static NSString * const kConvAttrKey_muted                = @"muted";
static NSString * const kConvAttrKey_unique               = @"unique";
static NSString * const kConvAttrKey_transient            = @"tr";
static NSString * const kConvAttrKey_system               = @"sys";
static NSString * const kConvAttrKey_temporary            = @"temp";

/* Value Type: NSNumber int32 */
static NSString * const kConvAttrKey_temporaryTTL         = @"ttl";

///

FOUNDATION_EXPORT NSString *LCIMClientIdKey;
FOUNDATION_EXPORT NSString *LCIMConversationIdKey;
FOUNDATION_EXPORT NSString *LCIMConversationPropertyNameKey;
FOUNDATION_EXPORT NSString *LCIMConversationPropertyValueKey;
FOUNDATION_EXPORT NSNotificationName LCIMConversationPropertyUpdateNotification;

#define LCIM_NOTIFY_PROPERTY_UPDATE(clientId, conversationId, propname, propvalue)  \
do {                                                                                \
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];               \
                                                                                    \
    userInfo[LCIMClientIdKey]                  = (clientId);                        \
    userInfo[LCIMConversationIdKey]            = (conversationId);                  \
    userInfo[LCIMConversationPropertyNameKey]  = (propname);                        \
    userInfo[LCIMConversationPropertyValueKey] = (propvalue);                       \
                                                                                    \
    [[NSNotificationCenter defaultCenter]                                           \
      postNotificationName:LCIMConversationPropertyUpdateNotification               \
      object:nil                                                                    \
      userInfo:userInfo];                                                           \
} while(0)

FOUNDATION_EXPORT NSNotificationName LCIMConversationMessagePatchNotification;
FOUNDATION_EXPORT NSNotificationName LCIMConversationDidReceiveMessageNotification;

/// it's a key. the value from dic, True: 开启未读通知; False: 关闭离线消息推送。
static NSString *const kAVIMUserOptionUseUnread = @"AVIMUserOptionUseUnread";

@interface AVIMConversation ()

@property (nonatomic, copy)   NSString     *name;
@property (nonatomic, strong) NSDate       *createAt;
@property (nonatomic, strong) NSDate       *updateAt;
@property (nonatomic, strong) AVIMMessage  *lastMessage;
@property (nonatomic, strong) NSDate       *lastMessageAt;
@property (nonatomic, strong) NSDate       *lastReadAt;
@property (nonatomic, strong) NSDate       *lastDeliveredAt;
@property (nonatomic, assign) NSUInteger    unreadMessagesCount;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, assign) BOOL          muted;
@property (nonatomic, assign) BOOL          transient;

@property (nonatomic, strong) NSMutableDictionary *properties;

/*
 because `properties` can be changed by user,
 so need a immutable dic to store conversation's attribute data
 */
@property (nonatomic, strong) NSDictionary *rawDataDic;

@property (nonatomic, strong) NSHashTable<id<AVIMConversationDelegate>> *delegates;

- (instancetype)initWithConversationId:(NSString *)conversationId;
- (void)setConversationId:(NSString *)conversationId;
- (void)setMembers:(NSArray *)members;
- (void)setCreator:(NSString *)creator;
- (void)setImClient:(AVIMClient *)imClient;
- (void)addMembers:(NSArray *)members;
- (void)addMember:(NSString *)clientId;
- (void)removeMembers:(NSArray *)members;
- (void)removeMember:(NSString *)clientId;

- (void)setKeyedConversation:(AVIMKeyedConversation *)keyedConversation;

@end
