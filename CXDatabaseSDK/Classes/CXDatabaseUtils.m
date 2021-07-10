//
//  CXDatabaseUtils.m
//  Pods
//
//  Created by wshaolin on 2018/5/17.
//

#import "CXDatabaseUtils.h"
#import <CXFoundation/CXFoundation.h>

static FMDatabaseQueue *CXDatabaseQueue(void){
    static FMDatabaseQueue *databaseQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = @".data.db";
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:name];
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    });
    
    return databaseQueue;
}

@implementation CXDatabaseUtils

+ (void)createTable:(NSString *)sql{
    if(CXStringIsEmpty(sql)){
        return;
    }
    
    [CXDatabaseQueue() inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

+ (void)executeUpdate:(NSString *)sql arguments:(NSArray *)arguments handler:(void (^)(BOOL))handler{
    if(CXStringIsEmpty(sql)){
        return;
    }
    
    __block BOOL success = NO;
    [CXDatabaseQueue() inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql withArgumentsInArray:arguments];
    }];
    
    if(handler){
        handler(success);
    }
}

+ (void)executeQuery:(NSString *)sql arguments:(NSArray *)arguments handler:(void (^)(FMResultSet *))handler{
    if(CXStringIsEmpty(sql)){
        return;
    }
    
    [CXDatabaseQueue() inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:arguments];
        if(handler){
            handler(rs);
        }
        
        [rs close];
    }];
}

+ (BOOL)removeAllDataWithTable:(NSString *)tableName{
    if(CXStringIsEmpty(tableName)){
        return NO;
    }
    
    __block BOOL success = NO;
    [CXDatabaseQueue() inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@;", tableName]];
    }];
    
    return success;
}

+ (void)checkTable:(NSString *)tableName column:(NSString *)columnName existsBlock:(void (^)(BOOL, BOOL))block{
    if(CXStringIsEmpty(tableName) || !block){
        return;
    }
    
    __block BOOL tableExists = NO;
    __block BOOL columnExists = NO;
    [CXDatabaseQueue() inDatabase:^(FMDatabase * _Nonnull db) {
        tableExists = [db tableExists:tableName];
        if(tableExists && [CXStringUtils isValidString:columnName]){
            columnExists = [db columnExists:columnName inTableWithName:tableName];
        }
    }];
    
    block(tableExists, columnExists);
}

+ (BOOL)dropTable:(NSString *)tableName{
    if(CXStringIsEmpty(tableName)){
        return NO;
    }
    
    __block BOOL success = NO;
    [CXDatabaseQueue() inDatabase:^(FMDatabase * _Nonnull db) {
        success = [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE %@;", tableName]];
    }];
    
    return success;
}

@end
