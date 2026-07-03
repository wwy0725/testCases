# 一、消费客户中心单位客户合并mq，topic：operation-customer-unit-merge

1. 根据被合并客户id查询签到信息
    1. select \* from itcrmweb.itcrm\_sign\_in\_info  where CUSTOMER\_ID = '被合并客户id'
2. 被合并客户未查到签到信息的无需处理
3. 被合并客户存在签到信息，按以下逻辑处理
    1. 被合并客户id更新为主合并客户id：itcrm\_sign\_in\_info表的CUSTOMER\_ID字段
    2. 被合并客户类型更新为主合并客户类型：单位客户合并，主被客户类型相同无需处理
    3. 签到的业务类型是客户的，更新业务id为主合并客户
        1. itcrm\_sign\_in\_info 表business\_type=customer的，更新business\_id
    4. 更新最后修改时间
4. 签退表是通过签到id关联的，无需处理




# 二、消费客户中心代理客户合并mq，topic：operation-customer-agent-merge

1. 根据被合并客户id查询签到信息
    1. select \* from itcrmweb.itcrm\_sign\_in\_info  where CUSTOMER\_ID = '被合并客户id'
2. 被合并客户未查到签到信息的无需处理
3. 被合并客户存在签到信息，按以下逻辑处理
    1. 被合并客户id更新为主合并客户id：itcrm\_sign\_in\_info表的CUSTOMER\_ID字段
    2. 被合并客户类型更新为主合并客户类型
        1. 签到使用的是小二老的客户类型：1- 中介；2-个代
    3. 签到的业务类型是客户的，更新业务id为主合并客户
        1. itcrm\_sign\_in\_info 表business\_type=customer的，更新business\_id
    4. 更新最后修改时间
4. 签退表是通过签到id关联的，无需处理

# 三、消费客户中心多企业合并mq，topic：operation-customer-business-entity-merge

1. 根据被合并客户id查询签到信息
    1. select \* from itcrmweb.itcrm\_sign\_in\_info  where CUSTOMER\_ID = '被合并多企业id'
2. 被合并客户未查到签到信息的无需处理
3. 被合并客户存在签到信息，按以下逻辑处理
    1. 被合并客户id更新为主合并客户id：itcrm\_sign\_in\_info表的CUSTOMER\_ID字段
    2. 被合并客户类型更新为主合并客户类型：多企业合并，主被客户类型相同无需处理
    3. 签到的业务类型是客户的，更新业务id为主合并客户
        1. itcrm\_sign\_in\_info 表business\_type=customer的，更新business\_id
    4. 更新最后修改时间
4. 签退表是通过签到id关联的，无需处理




# 四、消费客户中心代理编辑mq，topic：operation-customer-agent-info-modify

### 触发场景

1. 个代转中介
2. 中介转个代

### 处理逻辑

1. 处理消息体内容
    1. 变更前客户类型=变更后客户类型：无需处理
2.  查询消息体内被编辑客户的签到信息
    1. select \* from itcrmweb.itcrm\_sign\_in\_info  where CUSTOMER\_ID = '客户id'
3. 客户未查到签到信息的无需处理
4. 客户存在签到信息，按以下逻辑处理
    1. 根据客户id和客户中心的客户类型转换得到小二老的客户类型
        1. 客户中心：2-中介；3-个代 
        2. 小二：1- 中介；2-个代
    2. 客户类型转换失败的无需处理
    3. 客户类型转换成功的，修改相关签到记录的客户类型
        1. 按CUSTOMER\_ID = '客户id'查询签到记录更新 itcrm\_sign\_in\_info 表的CUSTOMER\_TYPE字段
        2. 更新最后修改时间





