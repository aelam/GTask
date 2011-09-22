/*
 Navicat Premium Data Transfer

 Source Server         : GTask-Mock
 Source Server Type    : SQLite
 Source Server Version : 3006022
 Source Database       : main

 Target Server Type    : SQLite
 Target Server Version : 3006022
 File Encoding         : utf-8

 Date: 09/22/2011 17:44:51 PM
*/

-- ----------------------------
--  Table structure for "TaskLists"
-- ----------------------------
DROP TABLE IF EXISTS "TaskLists";
CREATE TABLE TaskLists (_id INTEGER primary key autoincrement,GoogleId TEXT,Name TEXT NOT NULL,Account TEXT NOT NULL,IsDefault INTEGER NOT NULL DEFAULT 0,LatestSyncPoint INTEGER,ServerModifyTime INTEGER,LocalModifyTime INTEGER,Cleared INTEGER NOT NULL DEFAULT 0,_deleted INTEGER NOT NULL DEFAULT 0,_status INTEGER NOT NULL DEFAULT 0,_order INTEGER NOT NULL DEFAULT -1,Color INTEGER,SortType INTEGER NOT NULL DEFAULT 1);

-- ----------------------------
--  Records of "TaskLists"
-- ----------------------------
BEGIN;
INSERT INTO "TaskLists" VALUES ('1', '12810797069189272244:8:0', 'Mobile List', 'wanglun02@gmail.com', '0', '63450412530000000', '1314729326000', '1316623755213', '0', '0', '2', '10000000', '-3381760', '1');
INSERT INTO "TaskLists" VALUES ('2', '12810797069189272244:0:0', 'TODO LIST', 'wanglun02@gmail.com', '1', '63452307196000000', '1316623996000', '1316623996590', '0', '0', '2', '10000001', '-65536', '1');
INSERT INTO "TaskLists" VALUES ('3', '12810797069189272244:6:0', 'My Tasks', 'wanglun02@gmail.com', '0', '63452306993000000', '1316623793000', '1316623794749', '0', '0', '2', '10000002', '-6697984', '1');
COMMIT;

