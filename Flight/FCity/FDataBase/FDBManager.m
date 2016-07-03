//
//  FDBManager.m
//  Flight
//
//  Created by caiyangjieto on 15-5-19.
//  Copyright (c) 2015年 just. All rights reserved.
//

#import "FDBManager.h"

#import "DBOperationConstant.h"
#import "FCityPhysicalMark.h"
#import "FNationPhyscialMark.h"

#ifdef _FMDATABASEQUEUE_H_
#import "FMDatabaseQueue.h"
#endif

//数据路径 文件名
#define kFlightDataRootFolder                       @"Flight"
#define kFlightDBFileName                           @"flightStore.db"

//沙盒数据库版本号 key
#define kFlightDBLocalVersionKeyName                @"versionLocal"
#define kFlightDBAppVersionKeyName                  @"versionApp"

@interface FDBManager ()

@property (strong,nonatomic)  NSMutableDictionary   *dict;      //记录版本号
@property (strong,nonatomic)  NSNumber              *usedCount; //记录open、close的次数

@end

// DB 操作的唯一实例
static FDBManager *f_staticDBInstance = nil;

@implementation FDBManager

+ (FDBManager *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (nil == f_staticDBInstance)
        { // 初始化实例
            f_staticDBInstance = [[FDBManager alloc] init];
            [f_staticDBInstance resetUsedCount];
        }
    });
    
    return f_staticDBInstance;
}

- (id)init
{
    if (self = [super init])
    {
#ifndef _FMDATABASEQUEUE_H_
        dbObject = [[FMDatabase alloc] init]; // 初始化资源
#endif
        dbFullPath = nil;
    }
    
    return self;
}

- (void)openFlightDB:(NSString *)accountId
{
    @synchronized(self)
    {
        //不是第一次就return
        [self usedCountIncrease];
        if ([[self usedCount] intValue] > 1)
            return;
        
        dbFullPath = [self getDBFileFullPath:accountId];
        NSAssert(!IsStrEmpty(dbFullPath), @"database file path error !");
        
        // 判断DB文件是否存在
        BOOL file = [[NSFileManager defaultManager] fileExistsAtPath:dbFullPath];
        
        // 文件不存在 copy到沙盒
        if (!file)
        {
            [self copyFileToDocument];
        }
        
        queue = [FMDatabaseQueue databaseQueueWithPath:dbFullPath];
    }
    
}

- (void)removeFlightDB:(NSString *)accountId
{
    @synchronized(self)
    {
        //关闭连接
        [self resetUsedCount];
        [self closeFlightDBUnlock];
        
        dbFullPath = [self getDBFileFullPath:accountId];
        
        // 判断DB文件是否存在
        BOOL file = [[NSFileManager defaultManager] fileExistsAtPath:dbFullPath];
        
        if (file)
        {
            [[NSFileManager defaultManager] removeItemAtPath:dbFullPath error:nil];
        }
    }
}

- (void)copyFileToDocument
{
    //获取工程中文件名
    NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:kFlightDBFileName ofType:@""];
    
    //通过NSFileManager 对象的复制属性，把工程中数据库的路径复制到应用程序的路径上
    if (!IsStrEmpty(backupDbPath))
        [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:dbFullPath error:nil];
}

- (void)closeFlightDB
{
    @synchronized(self)
    {
        // 计数器不等于0  不close
        [self usedCountDecrease];
        if ([[self usedCount] intValue] > 0)
            return;
        
        [self closeFlightDBUnlock];
    }
}

- (void)closeFlightDBUnlock
{
#ifdef _FMDATABASEQUEUE_H_
    [queue close];
#else
    if (![dbObject close]){
        DLog(@"Close DB Failed!\n");
    }
#endif
}

+ (void)closeFlightDB
{
#if !__has_feature(objc_arc)
    [f_staticDBInstance release];
#endif
    f_staticDBInstance = nil;
}

#pragma mark - 引用计数

- (void)resetUsedCount
{
    _usedCount = @0;
}

- (void)usedCountIncrease
{
    _usedCount = @([_usedCount intValue]+1);
}

- (void)usedCountDecrease
{
    _usedCount = @([_usedCount intValue]-1);
}

#pragma mark - 用于内部判断城市

- (NSArray *)selectArrayWithSearchID:(NSString *)cityName
{
    if (IsStrEmpty(cityName))
        return nil;
    
    NSString *condition = [[NSString alloc] initWithFormat:@" searchCity = '%@' ",cityName];
    NSArray *arrayCitys = [self selectTableDataForType:TableTypeCity condition:condition];
    return arrayCitys;
}

#pragma mark - 版本号

- (void)setCityDBVersion:(NSString *)version
{
    if (IsStrEmpty(version))
        return;
    
    if (_dict == nil)
        _dict = [[NSMutableDictionary alloc] init];
    
    [_dict setObjectSafe:version forKey:kFlightDBLocalVersionKeyName];
}

- (NSString *)getCityDBVersion
{
    if (_dict == nil)
    {
        // 获取document文件夹位置
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndexSafe:0];
        
        // 文件地址
        NSString *path = [documentDirectory stringByAppendingPathComponent:kFlightDBVersionFileName];
        
        // 该文件存在
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        }
    }
    
    NSString *localVersion = [_dict objectForKey:kFlightDBLocalVersionKeyName];
    if (!IsStrEmpty(localVersion)) {
        return  localVersion;
    }
    
    //默认版本号
    return kFCityDataBaseVersion;
}

- (void)setCityDBAppVersion:(NSString *)version
{
    if (IsStrEmpty(version))
        return;
    
    if (_dict == nil)
        _dict = [[NSMutableDictionary alloc] init];
    
    [_dict setObjectSafe:version forKey:kFlightDBAppVersionKeyName];
}

- (NSString *)getCityDBAppVersion
{
    if (_dict == nil)
    {
        // 获取document文件夹位置
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndexSafe:0];
        
        // 文件地址
        NSString *path = [documentDirectory stringByAppendingPathComponent:kFlightDBVersionFileName];
        
        // 该文件存在
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        }
    }
    
    NSString *appVersion = [_dict objectForKey:kFlightDBAppVersionKeyName];
    if (!IsStrEmpty(appVersion)) {
        return appVersion;
    }
    
    //第一次本地无数据
    return nil;
}

- (void)saveCityDBVersion
{
    if ([_dict count] == 0)
        return;
    
    // 获取document文件夹位置
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndexSafe:0];
    
    // 写入文件
    NSString *path = [documentDirectory stringByAppendingPathComponent:kFlightDBVersionFileName];
    [_dict writeToFile:path atomically:YES];
}

#pragma mark - 文件路径相关

- (NSString *)getDBFileFullPath:(NSString *)accountId
{
    NSString *path = [self getFlightDBRootPath];
    
    if (!IsStrEmpty(accountId))
    {
        NSString *accountPath = [self getFolderForName:accountId fromRootPath:path];
        return [[NSString alloc] initWithFormat:@"%@/%@", accountPath, kFlightDBFileName];
    }
    else
    {
        return [[NSString alloc] initWithFormat:@"%@/%@", path, kFlightDBFileName];
    }
}

- (NSString *)getFlightDBRootPath
{
    return [self getFolderForName:kFlightDataRootFolder fromRootPath:nil];
}

//!--该方法只需要传入需要构建的文件夹名称,默认所有文件都放到Libaray/中--!
- (NSString *)getFolderForName:(NSString *)folderName fromRootPath:(NSString *)rootPath
{
    if (IsStrEmpty(folderName))
        return @"";
    
    if (IsStrEmpty(rootPath))
        rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndexSafe:0];
    
    if (IsStrEmpty(rootPath))
        return @"";
    
    BOOL isFolder;
    BOOL isExsit = [[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:&isFolder];
    NSAssert((isExsit && isFolder), @"Error : rootPath is not a valid existed folder path");
    
    NSMutableString *path = [[NSMutableString alloc] initWithString:@""];
    
    [path appendString:rootPath];
    [path appendString:@"/"];
    [path appendString:folderName];
    
    // 该目录文件不存在则创建
    BOOL isDir;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir))
    {
        NSDictionary *folderPropertyDic = [NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:folderPropertyDic
                                                        error:nil];
        
    }
    
    return path;
}

//!--该方法只需要传入需要创建的文件名称--!
- (NSString *)createFlightDatabaseFlie:(NSString *)fileName fromFolder:(NSString *)folderPath
{
    if (IsStrEmpty(fileName) || IsStrEmpty(folderPath))
        return @"";
    
    NSMutableString *path = [[NSMutableString alloc] initWithString:@""];
    
    [path appendString:folderPath];
    [path appendString:@"/"];
    [path appendString:fileName];
    
    // 该文件不存在则创建
    BOOL isDir;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir))
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:nil
                                              attributes:nil];
    
    return path;
}

#pragma mark - Insert & SQL DML

- (void)insertCity:(FCityPhysicalMark *)mark
{
    if (!mark)
        return;
    
    NSString *datasql = [self constructInsertCitySQL:mark forTable:KDB_TABLE_QFCITY];
    
#ifdef _FMDATABASEQUEUE_H_
    [queue inDatabase:^(FMDatabase *db){
        
        if (!IsStrEmpty(datasql))
        {
            [db executeUpdate:datasql];
        }
    }];
#else
    if (!IsStrEmpty(datasql))
    {
        [db executeUpdate:datasql];
    }
#endif
}

- (void)insertNation:(FNationPhyscialMark *)mark
{
    if (IsStrEmpty(mark.nameEN) || IsStrEmpty(mark.nameCN)){
        return;
    }
    
    NSString *datasql = [self constructInsertNationSQL:mark];
    
#ifdef _FMDATABASEQUEUE_H_
    [queue inDatabase:^(FMDatabase *db){
        
        if (!IsStrEmpty(datasql))
        {
            [db executeUpdate:datasql];
        }
    }];
#else
    if (!IsStrEmpty(datasql))
    {
        [db executeUpdate:datasql];
    }
#endif
}

#pragma mark - Update & SQL DML

- (void)updateCity:(FCityPhysicalMark *)mark
{
    if (!mark)
        return;
    
    // update 不存在就insert
    NSString *updatesql = [self constructUpdateCitySQL:mark forTable:KDB_TABLE_QFCITY];
    NSString *insertsql = [self constructInsertCitySQL:mark forTable:KDB_TABLE_QFCITY];
    
#ifdef _FMDATABASEQUEUE_H_
    [queue inDatabase:^(FMDatabase *db){
        
        if (!IsStrEmpty(updatesql) && !IsStrEmpty(insertsql))
        {
            [db executeUpdate:insertsql];
            [db executeUpdate:updatesql];
        }
    }];
#else
    if (!IsStrEmpty(updatesql) && !IsStrEmpty(insertsql))
    {
        [db executeUpdate:insertsql];
        [db executeUpdate:updatesql];
    }
#endif
}
#pragma mark - Delete & SQL DML

- (void)deleteCity:(NSNumber *)cityId
{
    if ([cityId intValue] == 0)
        return;
    
    NSString *where = [[NSString alloc] initWithFormat:@" fIndex = %li ",(long)cityId.integerValue];
    NSString *datasql = DELETETABLE(KDB_TABLE_QFCITY,where);
    
#ifdef _FMDATABASEQUEUE_H_
    [queue inDatabase:^(FMDatabase *db){
        
        if (!IsStrEmpty(datasql))
        {
            [db executeUpdate:datasql];
        }
    }];
#else
    if (!IsStrEmpty(datasql))
    {
        [db executeUpdate:datasql];
    }
#endif
}

#pragma mark - Select & SQL DML

- (NSArray *)selectDomesticCity
{
#warning caiyangjieto 第一期只有大陆城市
//    NSString *condition = @"country like '中国%%' order by sectionTitle";
    NSString *condition = @"country = '中国' order by sectionTitle";
    
    return [self selectTableDataForType:TableTypeCity condition:condition];
}

- (NSArray *)selectInternationalCity
{
    NSString *condition = @"country != '中国' order by sectionTitle";
    
    return [self selectTableDataForType:TableTypeCity condition:condition];
}

- (NSArray *)selectCityName:(NSString *)cityName
{
    NSMutableString *condition = [[NSMutableString alloc] init];
    
    [condition appendFormat:@"cityCode like '%@%%' ",cityName];
    [condition appendFormat:@"or airportCodeLower like '%%%@%%' ",cityName];
    [condition appendFormat:@"or searchCity like '%@%%' ",cityName];
    [condition appendFormat:@"or cityNameCN like '%@%%' ",cityName];
    [condition appendFormat:@"or cityNameJP like '%@%%' ",cityName];
    [condition appendFormat:@"or cityNamePY like '%@%%' ",cityName];
    [condition appendFormat:@"or cityNameEN like '%@%%' ",cityName];
    
    // 为了把国内的都显示在前面 分两次搜
    NSString *where;
    where = [[NSString alloc] initWithFormat:@"country like '中国%%' and (%@)",condition];
    NSArray *arrayDomestic = [self selectTableDataForType:TableTypeCity condition:where];
    where = [[NSString alloc] initWithFormat:@"country not like '中国%%' and (%@)",condition];
    NSArray *arrayInter = [self selectTableDataForType:TableTypeCity condition:where];
    
    if (IsArrEmpty(arrayInter))
    {
        return arrayDomestic;
    }
    
    return [arrayDomestic arrayByAddingObjectsFromArray:arrayInter];
}

- (NSArray *)selectCityCountryName:(NSString *)countryName
{
    NSString *condition=[[NSString alloc] initWithFormat:@"country = '%@' order by sectionTitle",countryName];
    
    return [self selectTableDataForType:TableTypeCity condition:condition];
}

- (NSArray *)selectNation:(NSString *)countryName
{
    NSString *condition = [[NSString alloc] initWithFormat:@"nameCN = '%@' or nameEN = '%@' or nameFullPinYin = '%@' or nation2Code = '%@' limit 1",countryName,countryName,countryName,countryName];
    
    return [self selectTableDataForType:TableTypeNation condition:condition];
}

- (NSArray *)selectTableDataForType:(TableType)type condition:(NSString *)condition
{
    NSString *tableName = @"";
    if (type == TableTypeCity)
        tableName = KDB_TABLE_QFCITY;
    else if (type == TableTypeNation)
        tableName = KDB_TABLE_QFNATION;
    
    NSString *sql = IsStrEmpty(condition)? kSQL_SELECT(tableName) : kSQL_SELECT_WHERE(tableName, condition);
    
    __block  NSMutableArray *resultList = [NSMutableArray array];
    
#ifdef _FMDATABASEQUEUE_H_
    [queue inDatabase:^(FMDatabase *db){
        
        if (IsStrEmpty(sql))
            return ;
        
        FMResultSet *result = [db executeQuery:sql];
        
        if (result)
        {
            while (result.next)
            {
                if (type == TableTypeNation)
                {
                    [self addNationResult:result to:resultList];
                }
                else if (type == TableTypeCity)
                {
                    [self addCityResult:result to:resultList];
                }
            }
            
            [result close];
        }
    }];
#else
    if (IsStrEmpty(sql))
        return ;
    
    FMResultSet *result = [db executeQuery:sql];
    
    if (result)
    {
        while (result.next)
        {
            if (type == TableTypeNation)
            {
                [self addNationResult:result to:resultList];
            }
            else if (type == TableTypeCity)
            {
                [self addCityResult:result to:resultList];
            }
        }
        
        [result close];
    }
#endif
    
    return resultList;
}

- (void)addNationResult:(FMResultSet *)result to:(NSMutableArray *)list
{
    FNationPhyscialMark *mark = [[FNationPhyscialMark alloc] init];
    
    NSInteger fcid = [result intForColumnIndex:0];
    NSString *nameFullPinYin = [result stringForColumnIndex:1];
    NSString *nameEN = [result stringForColumnIndex:2];
    NSString *nameCN = [result stringForColumnIndex:3];
    NSString *nation2Code  = [result stringForColumnIndex:4];
    NSString *nation3Code  = [result stringForColumnIndex:5];
    NSString *url  = [result stringForColumnIndex:6];
    NSString *continentNameCN  = [result stringForColumnIndex:7];
    NSString *continentNameEN  = [result stringForColumnIndex:8];
    NSString *continentUrl  = [result stringForColumnIndex:9];
//    NSString *ext1  = [result stringForColumnIndex:10];
//    NSString *ext2  = [result stringForColumnIndex:11];
//    NSString *ext3  = [result stringForColumnIndex:12];
//    NSString *ext4  = [result stringForColumnIndex:13];
//    NSString *ext5  = [result stringForColumnIndex:14];
//    NSString *ext6  = [result stringForColumnIndex:15];
//    NSString *ext7  = [result stringForColumnIndex:16];
//    NSString *ext8  = [result stringForColumnIndex:17];
//    NSString *ext9  = [result stringForColumnIndex:18];
//    NSString *ext10 = [result stringForColumnIndex:19];
    
    [mark setFcid:fcid];
    [mark setNameFullPinYin:nameFullPinYin];
    [mark setNameEN:nameEN];
    [mark setNameCN:nameCN];
    [mark setNation2Code:nation2Code];
    [mark setNation3Code:nation3Code];
    [mark setUrl:url];
    [mark setContinentNameCN:continentNameCN];
    [mark setContinentNameEN:continentNameEN];
    [mark setContinentUrl:continentUrl];
//    [mark setExt1:ext1];
//    [mark setExt2:ext2];
//    [mark setExt3:ext3];
//    [mark setExt4:ext4];
//    [mark setExt5:ext5];
//    [mark setExt6:ext6];
//    [mark setExt7:ext7];
//    [mark setExt8:ext8];
//    [mark setExt9:ext9];
//    [mark setExt10:ext10];
    
     [list addObject:mark];
}

- (void)addCityResult:(FMResultSet *)result to:(NSMutableArray *)list
{
    FCityPhysicalMark *mark = [[FCityPhysicalMark alloc] init];
    
    
                    int fIndex = [result intForColumnIndex:0];
              int isHasAirport = [result intForColumnIndex:1];
        NSString *sectionTitle = [result stringForColumnIndex:2];
          NSString *cityNameCN = [result stringForColumnIndex:3];
          NSString *cityNameEN = [result stringForColumnIndex:4];
          NSString *cityNamePY = [result stringForColumnIndex:5];
          NSString *cityNameJP = [result stringForColumnIndex:6];
    NSString *airportCodeLower = [result stringForColumnIndex:7];
            NSString *cityCode = [result stringForColumnIndex:8];
             NSString *country = [result stringForColumnIndex:9];
       NSString *recommendCity = [result stringForColumnIndex:10];
          NSString *searchCity = [result stringForColumnIndex:11];
            NSString *latitude = [result stringForColumnIndex:12];
           NSString *longitude = [result stringForColumnIndex:13];
    
//               NSString *ext1  = [result stringForColumnIndex:14];
//               NSString *ext2  = [result stringForColumnIndex:15];
//               NSString *ext3  = [result stringForColumnIndex:16];
//               NSString *ext4  = [result stringForColumnIndex:17];
//               NSString *ext5  = [result stringForColumnIndex:18];
//               NSString *ext6  = [result stringForColumnIndex:19];
//               NSString *ext7  = [result stringForColumnIndex:20];
//               NSString *ext8  = [result stringForColumnIndex:21];
//               NSString *ext9  = [result stringForColumnIndex:22];
//               NSString *ext10 = [result stringForColumnIndex:23];
    
    [mark setSectionTitle:sectionTitle];
    [mark setFIndex:fIndex];
    [mark setIsHasAirport:isHasAirport];
    [mark setCityNameCN:cityNameCN];
    [mark setCityNameEN:cityNameEN];
    [mark setCityNamePY:cityNamePY];
    [mark setCityNameJP:cityNameJP];
    [mark setAirportCodeLower:airportCodeLower];
    [mark setCityCode:cityCode];
    [mark setCountry:country];
    [mark setRecommendCity:recommendCity];
    [mark setSearchCity:searchCity];
    [mark setLongitude:longitude];
    [mark setLatitude:latitude];
//    [mark setExt1:ext1];
//    [mark setExt2:ext2];
//    [mark setExt3:ext3];
//    [mark setExt4:ext4];
//    [mark setExt5:ext5];
//    [mark setExt6:ext6];
//    [mark setExt7:ext7];
//    [mark setExt8:ext8];
//    [mark setExt9:ext9];
//    [mark setExt10:ext10];
    
    [list addObject:mark];
}

#pragma mark - Construct SQL

- (NSString *)constructInsertCitySQL:(FCityPhysicalMark *)mark forTable:(NSString *)tableName;
{
    NSString *sql = @"";
    
    NSString *insertSql = [[NSString alloc] initWithFormat:@"%@%@%@%@",kSQL_INSERT, tableName, @"(fIndex,isHasAirport,sectionTitle,cityNameCN,cityNameEN,cityNamePY,cityNameJP,airportCodeLower,cityCode,country,recomendCity,searchCity,latitude,longitude,ext1,ext2,ext3,ext4,ext5,ext6,ext7,ext8,ext9,ext10)",@"values(%i,'%i','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')"];
    
    sql = [[NSString alloc] initWithFormat:insertSql,
           mark.fIndex,
           mark.isHasAirport,
           mark.sectionTitle,
           IsStrEmpty(mark.cityNameCN)?@"":mark.cityNameCN,
           IsStrEmpty(mark.cityNameEN)?@"":mark.cityNameEN,
           IsStrEmpty(mark.cityNamePY)?@"":mark.cityNamePY,
           IsStrEmpty(mark.cityNameJP)?@"":mark.cityNameJP,
           IsStrEmpty(mark.airportCodeLower)?@"":mark.airportCodeLower,
           IsStrEmpty(mark.cityCode)?@"":mark.cityCode,
           IsStrEmpty(mark.country)?@"":mark.country,
           IsStrEmpty(mark.recommendCity)?@"":mark.recommendCity,
           IsStrEmpty(mark.searchCity)?@"":mark.searchCity,
           IsStrEmpty(mark.latitude)?@"":mark.latitude,
           IsStrEmpty(mark.longitude)?@"":mark.longitude,
           IsStrEmpty(mark.ext1)?@"":mark.ext1,
           IsStrEmpty(mark.ext2)?@"":mark.ext2,
           IsStrEmpty(mark.ext3)?@"":mark.ext3,
           IsStrEmpty(mark.ext4)?@"":mark.ext4,
           IsStrEmpty(mark.ext5)?@"":mark.ext5,
           IsStrEmpty(mark.ext6)?@"":mark.ext6,
           IsStrEmpty(mark.ext7)?@"":mark.ext7,
           IsStrEmpty(mark.ext8)?@"":mark.ext8,
           IsStrEmpty(mark.ext9)?@"":mark.ext9,
           IsStrEmpty(mark.ext10)?@"":mark.ext10];
    
    return sql;
}

- (NSString *)constructInsertNationSQL:(FNationPhyscialMark *)mark
{
    NSString *sql = @"";
    
    NSString *insertSql = [[NSString alloc] initWithFormat:@"%@%@%@%@",kSQL_INSERT, KDB_TABLE_QFNATION, @"(fcid,nameFullPinYin,nameEN,nameCN,nation2Code,nation3Code,url,continentNameCN,continentNameEN,continentUrl,ext1,ext2,ext3,ext4,ext5,ext6,ext7,ext8,ext9,ext10)", @"values(%i,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')"];
    
    sql = [[NSString alloc] initWithFormat:insertSql,mark.fcid,
           IsStrEmpty(mark.nameFullPinYin)?@"":mark.nameFullPinYin,
           IsStrEmpty(mark.nameEN)?@"":mark.nameEN,
           IsStrEmpty(mark.nameCN)?@"":mark.nameCN,
           IsStrEmpty(mark.nation2Code)?@"":mark.nation2Code,
           IsStrEmpty(mark.nation2Code)?@"":mark.nation3Code,
           IsStrEmpty(mark.nation2Code)?@"":mark.url,
           IsStrEmpty(mark.nation2Code)?@"":mark.continentNameCN,
           IsStrEmpty(mark.nation2Code)?@"":mark.continentNameEN,
           IsStrEmpty(mark.nation2Code)?@"":mark.continentUrl,
           IsStrEmpty(mark.ext1)?@"":mark.ext1,
           IsStrEmpty(mark.ext2)?@"":mark.ext2,
           IsStrEmpty(mark.ext3)?@"":mark.ext3,
           IsStrEmpty(mark.ext4)?@"":mark.ext4,
           IsStrEmpty(mark.ext5)?@"":mark.ext5,
           IsStrEmpty(mark.ext6)?@"":mark.ext6,
           IsStrEmpty(mark.ext7)?@"":mark.ext7,
           IsStrEmpty(mark.ext8)?@"":mark.ext8,
           IsStrEmpty(mark.ext9)?@"":mark.ext9,
           IsStrEmpty(mark.ext10)?@"":mark.ext10];
    
    return sql;
}

- (NSString *)constructUpdateCitySQL:(FCityPhysicalMark *)mark forTable:(NSString *)tableName;
{
    NSString *where = [[NSString alloc] initWithFormat:@" fIndex = %d ",mark.fIndex];
    
    NSString *setSql;
    setSql = [[NSString alloc] initWithFormat:@"isHasAirport = %d,sectionTitle = '%@',cityNameCN = '%@',cityNameEN = '%@',cityNamePY = '%@',cityNameJP = '%@',airportCodeLower = '%@',cityCode = '%@',country = '%@',recomendCity = '%@',searchCity = '%@',latitude = '%@',longitude = '%@' ",
               mark.isHasAirport,
               mark.sectionTitle,
               IsStrEmpty(mark.cityNameCN)?@"":mark.cityNameCN,
               IsStrEmpty(mark.cityNameEN)?@"":mark.cityNameEN,
               IsStrEmpty(mark.cityNamePY)?@"":mark.cityNamePY,
               IsStrEmpty(mark.cityNameJP)?@"":mark.cityNameJP,
               IsStrEmpty(mark.airportCodeLower)?@"":mark.airportCodeLower,
               IsStrEmpty(mark.cityCode)?@"":mark.cityCode,
               IsStrEmpty(mark.country)?@"":mark.country,
               IsStrEmpty(mark.recommendCity)?@"":mark.recommendCity,
               IsStrEmpty(mark.searchCity)?@"":mark.searchCity,
               IsStrEmpty(mark.latitude)?@"":mark.latitude,
               IsStrEmpty(mark.longitude)?@"":mark.longitude];
    
    NSString *sql = kSQL_UPDATE(tableName,setSql,where);
    
    return sql;
}

@end
