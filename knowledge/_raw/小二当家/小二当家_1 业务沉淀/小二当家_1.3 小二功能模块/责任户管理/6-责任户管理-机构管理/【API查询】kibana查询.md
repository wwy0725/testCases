### 日志查询

1. warden 查询--不稳定，正常会有10s的延时，但是经常打印不出来 
    1. 地址：[http://warden-eyes-front.servyou-stable.sit.91lyd.com/warden/warden\_v2/log/query.html?a=datapicore&i=datapicore-preset&f=1684723190712&r=60&q=&fi=%5B%221000%40source%22%2C%22%2Fusr%2Flocal%2Flogs%2Fdatapicore%2Fapi-common-query.log%22%5D&o=%40timestamp&ot=DESC](http://warden-eyes-front.servyou-stable.sit.91lyd.com/warden/warden_v2/log/query.html?a=datapicore&i=datapicore-preset&f=1684723190712&r=60&q=&fi=%5B%221000%40source%22%2C%22%2Fusr%2Flocal%2Flogs%2Fdatapicore%2Fapi-common-query.log%22%5D&o=%40timestamp&ot=DESC)
    2. 公司账密登录
2. datapicore的release服务器查询（test环境和release环境的日志，他们都打印在release环境）
    1. 注意是release环境，/usr/local/logs/datapicore，api-common-query.log

### 【API查询】kibana查询-线上环境

【API，mysearch-es-idc集群账号】
网址
    [http://10.98.17.7/app/kibana#/management/security/users?\_g=](http://10.98.17.7/app/kibana#/management/security/users?_g=)()
用户，密码    
    mysearch\_ro\_agency/7s0fhlWVLu2ahN1s

| - |
|---|
| 【API，mysearch-es-idc集群账号】 mysearch\_ro\_agency/7s0fhlWVLu2ahN1s   -- 老模型 POST \_xpack/sql?format=json {   "query": """     select     "ccpi\_1@id" as customerId from     "mysearch-scene-agency-tax-agent-manage-20220825\_new-v2" limit 20          """ }   -- 新模型 POST \_xpack/sql?format=json {   "query": """     select     "oci\_1@id" as customerId from     "mysearch-scene-agency-tax-agent-manage-new-20230105-prod\_new-v2" limit 20          """ } |

#### 【目前线上环境都用API查询】kibana查询--老的索引查询-测试环境：

test/release环境 ：[http://10.199.151.14:5601/login?next=%2Fs%2Fmysearch%2Fapp%2Fkibana#/home?\_g=](http://10.199.151.14:5601/login?next=%2Fs%2Fmysearch%2Fapp%2Fkibana#/home?_g=)()    mysearch/mysearch\_123




| - |
|---|
| //广东运维账号登录，-网点的机构-itcrmweb默认查询-新模型 POST \_xpack/sql?format=txt {   "query": """  SELECT COUNT(\*) AS count  FROM "mysearch-scene-agency-tax-agent-manage-new-20230105-test-new-v18"  WHERE ("mcbbi\_8@business\_belong" = '1'  AND "mcdip\_7@sale\_area\_id" IN (3650,3653,3732,3654,3655,3924,3925,3656,3657,3658,3659,3660,3661,3662,3663,3664,3665,3666,3667,3668,3669,3670,3671,3672,3673,3674,3675,3676,3677,4019,4023,4024)  AND "mcbbi\_8@@del" <> 'true' AND "mcdip\_7@@del" = 'false' AND "ifolfi\_5@@del" <> 'true' AND "cl\_2@@del" <> 'true' AND "cerd\_3@@del" <> 'true' AND "icli\_6@@del" <> 'true' AND "oci\_1@valid\_flag" = 'Y' AND "oci\_1@customer\_type" IN ('2', '3') AND "oci\_1@@del" <> 'true' AND "aiioin\_16@@del" <> 'true')  and "omsr\_16@slave\_group\_id" is null """ }     //河北运维账号登录，网点机构-appcode:agencycrmweb-老模型 POST \_xpack/sql?format=txt {   "query": """     SELECT count(1)      FROM "mysearch-scene-agency-tax-agent-manage-20220825-test-v24"  WHERE  ("mcbbi\_8@@del" <> 'true' and "mcdip\_7@@del" = 'false'  and "ifolfi\_5@@del" <> 'true'  and "cl\_2@@del" <> 'true'  and "cerd\_3@@del" <> 'true'  and "icli\_6@@del" <> 'true' and "ccpi\_1@@del" <> 'true' and "aiioi\_14@@del" <> 'true'  and "omsr\_13@slave\_group\_id" is null)  AND  ("mcdip\_7@sale\_area\_id" in (3776,1,129,130,131,5,4102,4040,4106,3787,146,85,86,278,4057,98,99,4069,4070,4200,3946,3947,4204,47,3951,3761,3762,3765,3766,4087,3769,4093,4094))  AND  ("ccpi\_1@agent\_type" in ('1','2'))  AND  ("ccpi\_1@available" = 'Y')  AND  ("ccpi\_1@responsible\_branch\_id" = '001085')  AND  ('myInstitution' = 'myInstitution' and 1 = 1  OR 'myInstitution' = 'mobileInstitution'  and "ccpi\_1@available" = 'Y')  ) """ }     //我的机构-itcrmweb--老模型 POST \_xpack/sql?format=txt {   "query": """     SELECT count(1)     FROM "mysearch-scene-agency-tax-agent-manage-20220825-test-v24"  WHERE  ("mcbbi\_8@@del" <> 'true' and "mcdip\_7@@del" = 'false'  and "ifolfi\_5@@del" <> 'true'  and "cl\_2@@del" <> 'true'  and "cerd\_3@@del" <> 'true'  and "icli\_6@@del" <> 'true' and "ccpi\_1@@del" <> 'true' and "aiioi\_14@@del" <> 'true'  and "omsr\_13@slave\_group\_id" is null)  AND  ("mcbbi\_8@business\_belong" = '1')  AND  ("mcdip\_7@sale\_area\_id" in (3776,1,129,130,131,5,4102,4040,4106,3787,146,85,86,278,4057,98,99,4069,4070,4200,3946,3947,4204,47,3951,3761,3762,3765,3766,4087,3769,4093,4094))  AND  ("mcdip\_7@customer\_manager" in ('b763cad2fe2542018602d41fccc4ee39'))  AND  ("ccpi\_1@agent\_type" in ('1','2'))  AND  ("ccpi\_1@available" = 'Y')  AND  ("ccpi\_1@responsible\_branch\_id" = '001085')  AND  ('myInstitution' = 'myInstitution' and 1 = 1  OR 'myInstitution' = 'mobileInstitution'  and "ccpi\_1@available" = 'Y')  )   ) """ } |


