## 一、财代

### 功能入口-qqt报表

测试[http://bi-ep-management.qqt-test.sit.91lyd.com/#/dashboard/LYJ5YF80](http://bi-ep-management.qqt-test.sit.91lyd.com/#/dashboard/LYJ5YF80)（release环境配置存在问题未做验证）账号：zwz 密码：123（或运维河北账号）

线上[https://qqt.dc.servyou-it.com/#/dashboard/482DIWFF](https://qqt.dc.servyou-it.com/#/dashboard/482DIWFF)（数据组提供的测试专用报表，需要数据组协助插入测试数据，pre环境需要数据组协助调整账户中心配置，pre地址[https://pre-qqt.dc.servyou-it.com/#/dashboard/482DIWFF](https://pre-qqt.dc.servyou-it.com/#/dashboard/482DIWFF)），用线上账号登录，若无权限联系数据组授权即可

### 造数表及sql

[http://10.199.151.41:8889/hue/editor?editor=24860&type=impala](http://10.199.151.41:8889/hue/editor?editor=24860&type=impala)

servyou\_ads.ads\_shangji\_info

```plaintext
-- 查询数据
select *from servyou_ads.ads_shangji_info t;
 
-- 清空表
truncate table servyou_ads.ads_shangji_info;
 
-- 插入单条数据
insert into servyou_ads.ads_shangji_info (main_id,person_id,chance_name,type,main_type,sign_amount,sign_time,stage_code,app_code,principal_trueid) values  
('','20230413000050090232040000080','线索-cly测试1','certificate','1',1,'2024-12-31','cpxj','agencycrmweb','b763cad2fe2542018602d41fccc4ee39');
 
-- 插入多条数据
insert into servyou_ads.ads_shangji_info (main_id,person_id,chance_name,type,main_type,sign_amount,sign_time,stage_code,app_code,principal_trueid) values  
('','20230413000050090232040000080','线索-cly测试1','certificate','1',1,'2024-12-31','cpxj','agencycrmweb','b763cad2fe2542018602d41fccc4ee39'),
('','20230413000050090232040000080','线索-cly测试1','certificate','1',1,'2024-12-31','cpxj','agencycrmweb','b763cad2fe2542018602d41fccc4ee39');
```

### qqt创建商机功能

接口：[52-销售机会-qqt批量创建商机-财代](/read/book/70/174368)  /sales/chance/qqtBatchCreateChance

#### 1、qqt字段映射及创建商机的校验：

| - | - | - | - | - |
|---|---|---|---|---|
| 客户id | mainId | 4d1170fe008f4d7f9ee6a60d88bbec62 | 是 | 主体id，客户必须存在且为中介、个代 |
| 联系人 | personId | 202411190005015910001010000046 | 是 | 联系人personId，必须存在 |
| 商机名称 | chanceName | qqt创建商机名称 | 是 | 最多100个字符 |
| 商机类型 | type | getNew | 否 | - |
| 商机主体类型 | mainType | 1 | 是 | 1-中介，2-个代 |
| 预计签单金额 | signAmount | 100 | 是 | 数值类型 |
| 预计签单日期 | signTime | 2024-11-29 | 是 | 格式为：YYYY-MM-DD |
| 商机阶段 | stageCode | contact | 是 | 必须是对应分公司（qqt登录人业务分公司）范围内商机阶段code，不支持赢单 - win，输单-fail |
| appCode | appCode | agencycrmweb | 是 | 创建时写死为agencycrmweb，且校验qqt内勾选的记录必须是agencycrmweb |
| 商机负责人 | principalTrueid | b763cad2fe2542018602d41fccc4ee39 | 是 | 员工账户中心trueId，必须存在，不区分离职 |
| 商机创建人 | - | 后台取当前登录人 | 否 | 后台取当前登录人 |
| 商机创建时间 | - | 后台取系统时间 | 否 | 后台取系统时间 |

其他校验：最多勾选100条数据创建商机，以及单个创建接口已有的校验

#### 2、流程交互

qqt报表勾选商机后，点击创建商机打开弹框嵌入商机提供的前端页面（用于展示创建结果），商机的页面将qqt生成的businessId传给服务端，服务端将businessId解析成勾选的报表数据后调用单个创建接口，返回成功和失败条数及原因。

失败原因中的以下四个字段直接取qqt报表中的数据

客户名称：original\_main\_name  
商机负责人名称：original\_principal\_trueid\_name
类型名称：original\_type\_name
阶段名称：original\_stage\_code\_name




## 二、政务

### 功能入口-qqt报表

测试环境：QQT链接：[http://bi-ep-management.qqt-test.sit.91lyd.com/#/dashboard/Z31SJKJ3](http://bi-ep-management.qqt-test.sit.91lyd.com/#/dashboard/Z31SJKJ3)  （release环境配置存在问题未做验证）账号：zwz 密码：123（或运维河北账号）

线上：[https://qqt.dc.servyou-it.com/?from\_wecom=1#/dashboard/T73YA1KV](https://qqt.dc.servyou-it.com/?from_wecom=1#/dashboard/T73YA1KV)  可以找陈俊旭加权限陈陈俊旭俊旭陈俊旭

### 造数表及sql

1、造数表： [http://10.199.151.41:8889/hue/editor?editor=28326](http://10.199.151.41:8889/hue/editor?editor=28326)[&type=impala](http://10.199.151.41:8889/hue/editor?editor=24860&type=impala)   

表名：servyou\_ads.ads\_shangji\_batch\_info

2、sql

```sql
//插入单条数据
INSERT INTO servyou_ads.ads_shangji_batch_info (bigregioncode,bigregionname,mainid,originalmainname,personid,chancename,bizcategory,type,originaltypename,maintype,prepackageids,prepackagenames,prepackagesignamounts,signamount,signtime,stagecode,originalstagecodename,originalexpiredpackageids,originalpackageexpireddate,appcode,principaltrueid,originalprincipaltrueidname) VALUES ('004010002004','华北大区','41859ce55b004c32a5b451a5121e0d37','hll测试政务企业01','20220120001022150232040000000','hll线上测试-QQT创建02','govRenewal','levelUp','升版','0','100001152,100002200','【政务】资产盘点,【政务】资产管理','5800,200','6000','2026-03-30','contractSigning','合同签订','100001152,100002200','2026-03-30','gitcrm','fc5f7fdac4694f3fb06403c393cfecd9','黄丽丽_测试_政务');
//复制已有数据
insert into table `servyou_ads`.`ads_shangji_batch_info`  select * from `servyou_ads`.`ads_shangji_batch_info` where chancename='2026年华北企业产品续费商机';
```




### qqt创建商机功能

#### 1、接口

[60-销售机会-qqt批量创建商机-政务](/read/book/70/174362)/sales/chance/qqtBatchCreateChanceByGitcrm

#### 2、iris相关配置：

# 政务QQT批量创建续费商机上限（代码默认20000）
govQqtCreateChance.limit=20000
# 政务QQT批量创建续费商机分页大小（代码默认500）
govQqtCreateChance.pageSize=500

#### 3、创建流程交互

- qqt报表勾选商机后，点击创建商机打开弹框嵌入商机提供的前端页面：商机已提交创建，请稍后查看结果
- 前端将qqt生成的businessId通过调用接口（/sales/chance/qqtBatchCreateChanceByGitcrm）传给服务端，服务端处理逻辑：
    - 先校验任务是否存在、总数是否超 2w（数量限制配置在iris：govQqtCreateChance.limit=20000）
    - 讲任务数据插入 itcrm\_import\_log 表：channel ='govQqtCreateRenewChanceImport'
    - 线程池异步处理：每批次处理数量配置在iris（govQqtCreateChance.pageSize=500）
    - 接口立即返回 importLogId + 执行中状态

#### 4、查看政务商机创建结果

- 对接 中介CRM-导入结果查看页面组件
    - [http://yypt-front-spare.sit.91lyd.com/itcrm-manage-pc/#/allResult?appCode=gitcrm&hiddenBossMenu=1&channel=govQqtCreateRenewChanceImport](http://yypt-front-spare.sit.91lyd.com/itcrm-manage-pc/#/allResult?appCode=itcrmweb&hiddenBossMenu=1&channel=distributeAgentResponsible) 
    - 默认带入类别“政务QQT批量创建续费商机”
    - 结果展示：n条成功， m条失败
        - 失败数字支持点击下载excel文件
    - qqt入口不展示导入说明列
-  失败文件-失败原因中的以下四个字段直接取qqt报表中的数据
    - 主体名称、商机负责人名称、商机类型名称、商机阶段名称：取qqt数据
    - 业务大区名称：取根据code补充的名字

#### 5、数据校验

- 字段必填校验
    - 业务大区不能为空；客户ID不能为空；联系人ID不能为空；商机名称不能为空；商机业务分类不能为空；商机类型不能为空；商机主体类型不能为空；预购产品包ID不能为空；预购产品包名称不能为空；预购产品包金额不能为空；预计签单金额不能为空；预计签单日期不能为空；商机阶段不能为空；商机原到期产品ID不能为空；商机原产品到期时间不能为空；应用code不能为空；商机负责人不能为空
    - 若有多个字段未填：提示信息中需要包含所有未填的字段
        - 比如预购产品包ID、名称、金额都为空，需要提示：预购产品包ID不能为空；预购产品包名称不能为空；预购产品包金额不能为空
- 数量校验：限制创建100条，若超过则提示：数量超过100，无法操作
- 字段有效性校验：
    - **appCode**不为gitcrm的，错误提示：只支持创建政务商机
    - 商机**主体类型**不为0的，错误提示：只支持创建企业商机
    - **商机名称**超过100个长度的，错误提示：商机名称最多100字符
    - 根据**客户ID**未找到对应的企业，创建失败并提示：未查询到对应的客户信息
        - 查询全公司，不限制大区
    - 根据**personId**无法找到对应的联系人信息，创建失败并提示：未查询到对应的联系人信息
    - 根据**负责人id**未找到对应的客户经理，创建失败并提示：未查询到对应的负责人信息
    - **商机阶段**不在配置中，创建失败并提示：商机阶段不存在
        - 配置取stage\_setting表中gitcrm应用下的阶段配置
    - **商机阶段code**为win或fail的，错误提示：不支持创建赢单或输单商机
    - 若**预购产品包的id、名字、金额**有一个与其他数量不一致，错误提示：预购产品包ID/名称/金额个数不匹配
        - 分隔符只认英文逗号
    - **业务大区**不属于政务经营中心，创建失败并提示：业务大区错误
    - **业务分类**不在政务配置范围内，创建失败并提示：业务分类错误
        - 业务分类的范围=（政务业务线+对象类型为企业+大区） 关联映射的业务分类枚举值
    - **商机类型**不在基础枚举配置范围内，创建失败并提示：商机类型错误
        - 配置取配置中心基础枚举


