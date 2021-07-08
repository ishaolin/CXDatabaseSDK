//
//  CXDatabaseUtils.h
//  Pods
//
//  Created by wshaolin on 2018/5/17.
//

#import <fmdb/FMDB.h>

#define CX_CREATE_TABLE(sql)    [CXDatabaseUtils createTable:sql]
#define CX_EMPTY_TABLE(table)   [CXDatabaseUtils removeAllDataWithTable:table]
#define CX_DROP_TABLE(table)    [CXDatabaseUtils dropTable:table]

@interface CXDatabaseUtils : NSObject

+ (void)createTable:(NSString *)sql;

+ (void)executeUpdate:(NSString *)sql
            arguments:(NSArray *)arguments
              handler:(void (^)(BOOL isSuccess))handler;

+ (void)executeQuery:(NSString *)sql
           arguments:(NSArray *)arguments
             handler:(void (^)(FMResultSet *rs))handler;

+ (BOOL)removeAllDataWithTable:(NSString *)tableName;

+ (void)checkTable:(NSString *)tableName
            column:(NSString *)columnName
       existsBlock:(void (^)(BOOL tableExists, BOOL columnExists))block;

+ (BOOL)dropTable:(NSString *)tableName;

@end
