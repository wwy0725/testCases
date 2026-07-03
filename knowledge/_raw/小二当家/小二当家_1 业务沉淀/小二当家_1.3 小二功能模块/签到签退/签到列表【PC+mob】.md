##  [签到列表接口](/read/book/70/174455)：/sign/list

- 仅自己场景：

    - 前端传参：
        - signInPersonDepartIdList[0] = 登录人trueId
        - signInPersonId = 登录人trueId
    - 接口把 signInPersonDepartIdList 清空，按签到人=signInPersonId 查询
        - itcrmweb.itcrm\_sign\_in\_info表，SIGN\_IN\_PERSON  = signInPersonId入参
- 部门场景：
    - 前端传参：signInPersonDepartIdList[0]=004011006002&signInPersonDepartIdList[1]=004011006001
    - 按签到人部门查询，or条件
        - itcrmweb.itcrm\_sign\_in\_info表，SIGN\_IN\_PERSON\_DEPARTID  like (signInPersonDepartIdList%)
- 仅自己+部门场景
    - 前端传参：signInPersonDepartIdList[0]=004011006002&signInPersonDepartIdList[1]=004011006001&signInPersonDepartIdList[2]=DF910C299FBE1BDD4AC92093ECC77B2A
    - 接口特殊处理【仅自己】，按签到人部门 or 签到人查询
    - itcrmweb.itcrm\_sign\_in\_info表，SIGN\_IN\_PERSON\_DEPARTID  like (signInPersonDepartIdList%) or SIGN\_IN\_PERSON  = 登录人trueId
- 默认按签到时间倒序排序
- 默认一次查询20条




## 一、PC端签到管理列表

### 1.1 列表配置

筛选项和列表字段对接管理端列表配置：签到管理/签到列表（signInList）

- 




列表的客户名称是固定列，不配置

自定义筛选项支持配置中心的隐藏配置：配置时设置部分筛选项隐藏，恢复初始状态点击后可清空登录人配置

部门和签到人筛选条件配置在列表范围内，需配合【团队管理】权限生效

    - 有配置团队管理权限的才展示

注意：团队管理的数据权限和功能权限需要人为控制同时配置/不配置

    - 不配置功能权限的，需要保证数据权限也不配，否则列表查询时前端会获取到数据权限范围内的第一个部门调用接口筛选
    - 无团队管理功能权限和数据权限的，默认查询签到人=当前登录人的数据

### 1.2 列表数据查询

#### 1.2.1 列表查询

筛选项-全部类型：

        1. 下拉枚举获取管理端配置，/common/getModuleEnumSceneList，枚举项：签到管理-签到业务类型(signBusinessType)

筛选项-企业名称：

        1. /itcrmweb/customer/searchCustomerByContent：[小二首页搜索企业/个代/中介/经营体](/read/book/70/175047)
            1. 查询登录人所属经营中心 + 省直单（如果登录人有省直单）下的单位客户
            2. 默认查10条
        2. 调用查询列表接口，入参：customerId

筛选项-机构名称：

        1. /itcrmweb/common/searchAgentByContent：[模糊查询个代/中介](/read/book/70/175040)
            1. 查询登录人所属经营中心 + 省直单（如果登录人有省直单）下的中介和个代
            2. 默认查10条
        2. 调用查询列表接口，入参：agentId




列表按签到时间倒序

默认查询交互同移动端签到列表：[2.1.1 列表查询](#id-签到列表【PC+mob】-2.1.1列表查询)

#### 1.2.2 签到信息展示

 根据签到的业务类型判断在客户名称前面展示标签，逻辑同移动端，见[签到列表的标签展示](#id-签到列表【PC+mob】-签到列表的标签展示)

### 1.3 列表按钮展示

只展示【查看详情】和【查看跟进】按钮

#### 1.3.1 查看详情

按钮常驻，查看签到/签退详情

#### 1.3.2 查看跟进

接口 *actionBars* 返回 lookFollow ：当前签到有关联跟进记录就展示

查看跟进跳转跟进组件逻辑同移动端，见：[签到列表查看跟进跳转逻辑](#id-签到列表【PC+mob】-签到列表查看跟进跳转逻辑)

### 1.4 点击客户名称跳转逻辑

- 个代
    - 1、appCode=财代，跳转财代机构一户式
    - 2、appCode不是财代 但是 业务线属于财代，跳转财代机构一户式
    - 3、以上都不满足，跳转一人式
- 中介
    - appcode不是大客，跳转财代机构一户式
    - appcode=大客，跳转大客机构一户式




## 二、移动端签到管理列表

### 2.1 筛选条件展示

部门和签到人筛选条件根据【团队管理】权限判断是否展示

其他筛选条件需要按appCode差异化的配置在galaxy配置平台，key：signListCondition

![image-2025-11-11_17-2-34.png](https://snack.dc.servyou-it.com/snack/257/41444040bd26406ebcd327a6180bed27.png)

中小：签到时间、签到范围、签到业务类型

政务：签到时间、签到范围、签到业务类型

财代：签到时间、签到范围、签到业务类型

大客：不配置，无筛选条件




### 2.2 列表数据查询

#### 2.2.1 列表查询

调用 /api/itcrmweb/common/dataFunctionDepartList?onlyMe=true 接口判断登录人权限

    - 当前登录人无【团队管理】功能权限和数据权限
        - 接口返回【仅自己】，按签到人=登录人查询签到列表
    - 当前登录人有【团队管理】功能权限和数据权限
        - 接口返回数据权限的部门列表+仅自己
        - 默认选中列表的第一个部门，按签到人部门查询

列表接口查询见：[签到列表接口逻辑](#id-签到列表【PC+mob】-签到列表接口逻辑)

#### 2.2.2 签到信息展示

    - 展示签到的客户名称，签到人，签到信息：签到时间、签到地址，签退信息：签退时间、签退地址
    - 根据签到的业务类型特殊处理：
        - 签到的业务类型是线索，business\_type=clue，客户名称前面展示【线索】标签
        - 签到的业务类型是实施，business\_type=implement，客户名称前面展示【实施】标签
        - 签到的业务类型是客户，business\_type=customer
            - 客户类型非多企业，不展示标签
            - 客户类型是多企业，展示【多企业】标签

### 2.3 列表按钮展示

*前端根据签到列表返回的 actionBars 展示操作按钮*

#### 2.3.1 签退按钮-signOut

同时满足以下条件的展示：

    1. 大区配置了需要签退
        1. 根据appCode查询签到的数据库配置
            1. select * from itcrmweb.`itcrm_system_config` t WHERE t.key = 'signType' and code = 'agencycrmweb';
        2. 大区有配置且"value":"signOut"
    2. 当前签到记录未签退
        1. itcrm\_sign\_in\_info 表对应签到id的 IS\_SIGN\_OUT=N
    3. 登录人=签到人

#### 2.3.2 是否可签退校验

签退按钮展示逻辑见[2.2.1 签退按钮-signOut](#id-签到列表【PC+mob】-2.2.1签退按钮-signOut)

点击签退校验功能权限：签退前必须填写跟进记录 -signMustFollow

    - 获取权限：/api/itcrmweb/upms/queryEmployeeFunctionList
    - 无功能权限
        - 直接签退，跳转签退页面
    - 有功能权限，判断当前签到有无跟进
        - 签到列表的 actionBars 是否返回 lookFollow
        - 有跟进记录
            -  直接签退，跳转签退页面
        - 无跟进记录
            - 提示：请先填写跟进记录再签退！
            - 不跳转签退页面

#### 2.3.3 添加跟进按钮-addFollow

同时满足以下条件的展示：

    1. 签到未关联跟进
        1. 根据签到id查询 itcrm\_sign\_in\_business\_relation 表，不存在关联关系
    2. 登录人=签到人
    3. 签到的业务类型不是实施
        1. itcrm\_sign\_in\_info 表对应签到id的 business\_type≠implement
        2. 实施的签到只能在实施入口关联跟进
    4. 签到对象的客户类型不是多企业– 此处后端接口未做过滤逻辑，由前端根据客户类型判断
    5. 满足【签到可选天数】的配置
        1. 根据入参的appCode + 登录人业务大区 获取【签到可选天数】配置
            1. 
        2. ***该配置不兜底默认大区，查询的大区未配置时，表示不限制，可跟进***
        3. 大区有配置，比对当前日期和签到日期（取 itcrm\_sign\_in\_info 表的 SIGN\_IN\_TIME ）
            1. 当前日期-签到日期＞配置的天数，不可跟进
            2. 否则可跟进
    6. 满足【是否允许关联跨月签到记录】配置
        1. 根据入参的appCode + 登录人业务大区 获取【是否允许关联跨月签到记录】配置
            1. 
        2. ***该配置不兜底默认大区，查询的大区未配置时，表示不限制，可跟进***
        3. 大区有配置
            1. 配置【允许】，无需校验该规则
            2. 配置【不允许】，签到日期是当月的可跟进，否则不可跟进




##### 2.3.3.1 AI跟进按钮-aiFollow

在满足“添加跟进按钮”出现逻辑的同时，如果符合ai跟进的要求（签到id有关联AI解析结果），展示“AI跟进”按钮，否则还展示“添加跟进”按钮

1. 满足现有的添加跟进：
    1. appCode=财代，根据签到ID调用跟进接口判断是否支持AI跟进
    2. 支持AI跟进时：操作按钮返回 aiFollow
        1. 调用接口方法[根据关联业务查询指定类型AI解析信息](https://17work.dc.servyou-it.com/read/book/70/204031)/follow/getAiResultByBusiness，传入queryType=“follow”、relBusinessIds：${签到ID}、relBusinessTypes=“relSignIn,followSignIn”，出参只要返回aiId就表示有关联的AI预生成跟进
    3. 不支持AI跟进时：操作按钮返回原先的 addFollow
2. 对接ai跟进组件并传入参数：
    1. 关联的业务id: relBusinessIds=签到id
    2. 关联的业务类型：relBusinessTypes=relSignIn,followSignIn
    3. 查询类型：queryType=follow
    4. 机构id:institutionIdList
    5. 个代id: agentIdList
    6. appCode=当前应用的appcode
    7. 场景：scene=签到
    8. 跟进方式：上门 （shangmen）

#### 2.3.4 查看跟进按钮-lookFollow

当前签到有关联跟进记录就展示

根据签到id查询跟进记录

```sql
select * from itcrm_sign_in_business_relation  where SIGN_IN_ID= '签到Id' and business_type = 'follow'
```







### 2.4 mob签到列表-添加跟进

根据签到的业务目的配置映射跟进的经营动作（财代支持多业务目的），有映射的经营动作的需要传给跟进组件，传入的经营动作在经营动作的下拉枚举内的默认选中（跟进组件处理）

映射到多个经营动作时需要跳转多跟进场景的跟进组件

映射到一个经营动作 或 无映射的经营动作跳转单跟进组件

- 根据业务目的获取经营动作映射关系：
    - 
    - 一个业务目的只能配置一个经营动作
    - 多个业务目的可以配置到同一个经营动作
- 跟进的多跟进组件和单跟进组件是两个分开的单独组件
- 跳转多跟进需要给跟进传特定场景，"followScene":"multiFollow"
- 中小和政务新增签到无业务目的，添加跟进时不取映射关系，直接跳转单跟进组件




### 2.5 mob签到列表-查看跟进

根据列表接口返回的签到关联跟进记录id数判断跳转跟进记录详情 or 跟进记录列表

取/sign/list 的businessInfo

- 签到关联一条跟进记录，跳转跟进详情页面，传入跟进id
- 签到关联多条跟进记录，跳转跟进列表页面，传入跟进id列表







## 三、签到列表组件

### 3.1 组件入口-mob

组件数据查询调用/sign/list：[签到列表接口](/read/book/70/174455)

- 移动端财代机构一户式-签到列表
    - 根据客户id查询
- 移动端大客机构一户式-签到列表
    - 根据客户id查询
- 移动端财代看板-下属看板/我的看板-工作推进表
    - 根据签到id列表查询
    - 看板传入签到id列表给签到组件
- 移动端企业一户式
    - 根据客户id查询
- 移动端个代一人式
    - 根据客户id查询

### 3.2 组件入口-pc

- 企业一户式
- 个代一户式


