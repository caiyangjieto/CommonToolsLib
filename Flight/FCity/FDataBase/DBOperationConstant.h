//
//  DBOperationConstant.h
//  Flight
//
//  Created by caiyangjieto on 15-5-21.
//  Copyright (c) 2015年 just. All rights reserved.
//

#ifndef Flight_DBOperationConstant_h
#define Flight_DBOperationConstant_h


//--------------------------------------------------
// @Desc DDL SCOPE  数据定义语言区
//--------------------------------------------------
#pragma mark - DDL
/*
 * @Desc Create Table
 */
#define kSQL_CREATE                              @"create table if not exists "
/*
 * @Desc Delete Table
 */
#define kSQL_DROP                                @"drop table"
/*
 * @Desc Alter Table
 */
#define kSQL_ALTER_ADDFIELD_TABLE                @"alter table %@ add %@"

/*
 * @Desc Create Table
 */
#define kSQL_CREATEINDEX                         @"CREATE INDEX "

//--------------------------------------------------
// @Desc DML SCOPE  数据操纵语言
//--------------------------------------------------
#pragma mark - DML
/*
 * @Desc Insert
 * @Param N/A
 */
#define kSQL_INSERT                              @"insert or ignore into "
/*
 * @Desc  Delete
 * @Param table name , condition
 */
#define kSQL_DELETE                              @"delete from %@ where %@"
/*
 * @Desc  Delete All
 * @Param table name
 */
#define kSQL_DELETE_ALL                          @"delete from %@"
/*
 * @Desc  Update
 * @Param
 */
#define kSQL_UPDATE(NAME, SET, CONDITION)  [[NSString alloc] initWithFormat:@"UPDATE %@ set %@ where %@",NAME, SET, CONDITION]

/*
 * @Desc  Update
 * @Param
 */
#define kSQL_UPDATE_ALL(NAME, SET)    [[NSString alloc] initWithFormat:@"update %@ set %@",NAME,SET]
/*
 * @Desc  Update
 * @Param
 */
#define KSQL_UPDATEWB                            @"update %@ where %@"
/*
 * @Desc  Select
 * @Param
 */
#define kSQL_SELECT_WHERE(NAME, CONDITION)   [[NSString alloc] initWithFormat:@"select * from %@ where %@", NAME,CONDITION]
/*
 * @Desc  Select All
 * @Param
 */
#define kSQL_SELECT(NAME)                    [[NSString alloc] initWithFormat:@"select * from %@", NAME]
/*
 * @Desc  Select
 * @Param
 */
#define kSQL_SELECT_ITEM                         @"select %@ from %@"
/*
 * @Desc  Select Limit Count
 * @Param
 */
#define kSQL_SELECT_COUNT                        @"select count('%@') as MaxCount from %@ where %@"

//--------------------------------------------------
// @Desc   Table Name Define  表名字定义
// @Format KDB_TABLE_(表名)       请大家严格遵守命名规则!
//--------------------------------------------------
#pragma mark - Table Name Define

#define KDB_TABLE_QFCITY              @"QF_City"//城市
#define KDB_TABLE_QFHISTORYCITY       @"QF_HistoryCity"//历史城市\暂时不用了。。。
#define KDB_TABLE_QFNATION            @"QF_Nation"//国家列表

//--------------------------------------------------
// @Desc Table Field Define  表字段定义
// @Format KDB_TABLE_(表名)_FIELDS 请大家严格遵守命名规则!
//--------------------------------------------------
#pragma mark - Table Field Define

#define KDB_TABLE_QFCITY_MEMBERS       @"(fIndex integer , isHasAirport int default -1, sectionTitle text not null default '',cityNameCN text not null default '', cityNameEN text default '', cityNamePY text default '', cityNameJP text default '', airportCodelower text default '', cityCode text default '', country text default '', recomendCity text default '', searchCity text default '', latitude text default '', longitude text default '', ext1 text default '', ext2 text default '', ext3 text default '', ext4 text default '', ext5 text default '', ext6 text default '', ext7 text default '', ext8 text default '', ext9 text default '', ext10 text default '')"

#define KDB_TABLE_QFNATION_MEMBERS @"(fcid integer primary key autoincrement, nameFullPinYin text default '', nameEN text default '', nameCN text not null default '', nation2Code text default '', nation3Code text default '',url text default '',continentNameCN text default '',continentNameEN text default '',continentUrl text default '',ext1 text default '', ext2 text default '', ext3 text default '', ext4 text default '', ext5 text default '', ext6 text default '', ext7 text default '', ext8 text default '', ext9 text default '', ext10 text default '')"

#define KDB_TABLE_QFHISTORYCITY_MEMBERS @"(fiid integer primary key autoincrement, index int not null default -1, flag int default -1, isHasAirport int not null default 1, cityNameCN text not null default '', cityNameEN text default '', cityNamePY text default '', cityNameJP text default '', airportCodeLower text default '', airportCodeUpper text defaule '', country text default '', countryId int default -1, recommendCity text default '', searchCity text default '', depHotFlag int default -1, arrHotFlgh int default -1, firstLetter text not null default '', latitude text default '', longitude text default '', ext1 text default '', ext2 text default '', ext3 text default '', ext4 text default '', ext5 text default '', ext6 text default '', ext7 text default '', ext8 text default '', ext9 text default '', ext10 text default '')"

#pragma mark - 

/*
 * @Desc Create
 */
#define CREATETABLE(NAME, NAME_MEMBERS) [[NSString alloc] initWithFormat:@"%@%@%@", kSQL_CREATE, NAME, NAME_MEMBERS]
/*
 * @Desc Delete
 */
#define DELETETABLE(NAME, CONDITION)    [[NSString alloc] initWithFormat:kSQL_DELETE, NAME, CONDITION];

/*
 * @Desc Create Index
 */
#define CREATEINDEX(NAME, FIELD, INDEX) [[NSString alloc] initWithFormat:@"%@ %@ ON %@(%@)", kSQL_CREATEINDEX, INDEX, NAME, FIELD]

#pragma mark - 

// 一次取sql 最大数量
#define      KSQL_GET_NUM_MAX         13
// 页面显示数据
#define      kPAGE_SHOW_NUM_MAX       12


#endif
