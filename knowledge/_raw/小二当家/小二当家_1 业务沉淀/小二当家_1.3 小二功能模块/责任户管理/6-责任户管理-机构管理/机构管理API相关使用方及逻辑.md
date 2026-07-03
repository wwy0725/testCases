
原逻辑可见文档：[【20251225】小二当家分析设计-机构管理](/read/book/70/173515)

前端设计：[小二相关-lww](/read/book/70/176595)

## **一、机构管理基础功能提供**

1. 新增接口：[11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
    1. 出入参可见文档：[机构管理公共方法](/read/book/70/174589)
2. 新增api接口：resInstitutionManageQuery
    1. 测试环境：[http://datark-manage-pc.servyou-release.devops.91lyd.com/#/service/development/detail?apiCode=resInstitutionManageQuery](http://datark-manage-pc.servyou-release.devops.91lyd.com/#/service/development/detail?apiCode=resInstitutionManageQuery)
3. 接口修改统一规则
    1. 出入参逻辑修改统一规则：
        1. 所有比例参数，之前一部分由前端自行处理为%形式，本次改为都由服务端统一返回展示
        2. 所有比例/小数参数，之前一部分返回保留两位小数，一部分保留一位小数，本次统一为保留两位小数，去除末尾0
        3. 所有是否类参数，之前一部分由前端自行展示中文是否或有无，本次改为都由服务端统一返回展示
        4. 所有非是否类枚举code，之前一部分命名无code尾缀，本次都改为code、name尾缀
        5. 之前时间/数值范围类参数，之前一部分由前端以特定符号拼接传入，本次统一改为两个参数，以From和To结尾，之前是Start、End结尾的也统一改为From和To
        6. 入参时间统一传入年月日，时分秒后端处理+00:00:00 23:59:50
        7. 之前传入的列表参数有的带list尾缀，有的没有，本次统一加list尾缀
        8. 相同逻辑字段合并为一个，详细可见在线文档
        9. 出参展示的员工名称换取调用员工账户中心接口用dubbo接口替换原http接口
            1. com.servyou.facade.EmployeeFacade#getEmployeeByTrueId
        10. cnt结尾也统一改为了num结尾
        11. 会员命名统一member
        12. 之前由服务端拼接的参数统一改为返回前端list 由前端自行拼接展示样式，用于适配未来假设要做样式修改的情况
    2. 数据补充逻辑统一规则：
        1. 调用管理端获取枚举值的枚举key之前有的配置在IRIS中有的代码中写死（且分了不同的位置）统一在代码中使用一个枚举管理
    3. 排序逻辑修改：
        1. 原逻辑：
            1. 原pc排序：
                1. 判断前端是否传入排序字段
                    1. 传入则：前端传入参数排序+(如果是共享机构还要加创建时间倒序)+机构id升序
                    2. 没传入：divideTime倒序+(如果是共享机构还要加创建时间倒序)+机构id升序
            2. 移动排序：
                1. 中介公共池查询时：主要是映射了releaseTime-> divideTime，其他前端传入什么是什么，前端没有传入时使用divideTime倒序排列
                2. 其他：
                    1. 判断前端是否传入排序字段
                        1. 传入则：前端传入参数排序+(如果是共享机构还要加创建时间倒序)
                        2. 没传入：divideTime倒序+(如果是共享机构还要加创建时间倒序)
            3. 如果传入ukid则需要根据ukid升序
        2. 改动逻辑：
            1. 判断前端是否传入排序字段
                1. 传入则：前端传入参数排序+(如果是共享机构还要加创建时间倒序)+机构id升序
                2. 没传入则：划分时间倒序（字段应该是claimTime）+(如果是共享机构还要加创建时间倒序)+机构id升序
            2. 如果传入了要根据ukid查询则还要在末尾加ukid——客户管理策略使用
        3. **测试需要特别注意的点：mybatis的查询参数不能和单表查询一样塞到orderConditions里而是要作为一个普通的查询条件塞到queryConditions里 @测试**
4. 机构管理的新逻辑
    1. // 一、关于查询
1、必填参数校验
	整个入参不能传空
	登陆人信息获取不到也会报错
    statisticsWay查询范围不能为空
	appCode不能为空
2、查询API接口参数预处理
	A、机构ID参数相关（所有的机构ID列表都会取交集）
	    a、分群逻辑处理：如果传入分群code则会走分群逻辑而非机构管理，会调用数据组接口换取机构ID，换取不到直接返回空列表
		b、重点关注处理：重点关注场景下若换取不到客户id会直接结束返回空列表
			如果传入客户经理ID列表则以客户经理进行查询（我的机构、下属网点选择客户经理），直接调用公共方法
			如果没有传入客户经理ID列表则以组织机构对应销售区域进行查询（下属网点未选择客户经理）公共方法
			公共方法支持销售区域id入参和客户经理id入参：cn.com.servyou.marketing.itcrmweb.business.service.impl.FocusDataBusinessImpl#querySaleInstitutionIdList
        c、如果传入联系号码，需要根据号码换取机构ID
		d、最后传入API接口的参数就是institutionIdList
	B、时间参数处理
	    a、最近跟进时间计算，需要处理未推进天数 + 最近跟进时间联合筛选
	    b、处理无效地址更新时间（根据前端传入的code匹配到对应的时间范围再查询API接口）
	    c、处理地址采集时间（根据前端传入的code匹配到对应的时间范围再查询API接口）
	    d、处理成立时长（根据前端传入的code匹配到对应的时间范围再查询API接口）
		e、处理责任户机构管理认领时间起止（尾部增加00:00:00、23:59:59）
		f、处理最后一次跟进时间起止（尾部增加00:00:00、23:59:59）
	C、特殊参数逻辑处理
		a、地区参数处理：去除末尾00
		b、纳入率需要转换为小数后再查询api（VipPercentBroadFrom、VipPercentBroadTo）
		c、机构规模要根据_拆分成institutionScaleFrom、institutionScaleTo传入API接口
3、机构管理范围查询参数（区分我的机构、下属的机构、网点的机构，可见销售区域范围框定）
	A、默认查询我的机构
	B、查询我的机构：设置客户经理为登录人
	C、查询下属的机构：根据查询部门获取客户经理数据（数据权限范围其实前端传入时已限定，可选部门只有数据权限范围内的，但是代码目前存在传入部门即使不在权限范围内仍会正常返回的情况）
	D、查询网点的机构：数据权限范围下的组织机构对应的销售区域，销售区域若为空则直接返回空（同下属一样，实际由入参控制的数据权限范围）
	E、可见销售区域范围框定（调用的公共池的方法，直接拷贝的，逻辑没改）
		————————————需要注意：共享机构查询场景没有这个销售区域范围框定的逻辑
		给公共方法传的参数只有appCode和登陆人信息
	F、设置大区（传入则以传入为准，没传入则设置为登陆人业务大区）	
	G、设置省直单（如果是跨区经营户 isCrossRegionBusinessCustomer = Y，省直单不传；如果不是，传入则以传入为准，没传入则设置为登陆人业务省直单）
	H、协同人员参数设置
	    设置remoteList、implementList、extend1List...extend20List，方法拷贝的是之前的老方法
		需要将前面设置的客户经理ID清除
4、查询API接口（根据小二数据库中配置进行查询）
	A、表itcrm_api_query_config，配置为空表示全部都要查询和筛选，默认就是全部

// 二、关于数据补充
1、由调用方法的参数控制是否要补充额外数据（除API接口返回的数据外的都叫额外数据），比如agentCount接口只进行统计就无需额外数据补充
2、管理端枚举值名称/现有枚举值名称 补充
3、无需调用dubbo接口补充数据的参数 补充
	A、计算抵扣率：deductionRate = (deduction / recharge) * 100; 处理百分号返回
	B、计算设置未跟进天数
	C、百分比处理拼接
		涉及参数：
			renewalRate
			enewedAmountCollectionRate
			vipPercentBroad
			vipPercentGeneral
	D、补充距离参数（只有入参和结果参数都包含经纬度时才会补充距离参数distance）
	F、数据处理：带小数的数值类型保留两位小数、四舍五入、去掉末尾0
		涉及参数：
		    invoiceTaxIncomeYear
			complianceIncomeYear
		    electricityIncomeYear
		    jointVentureIncomeYear
		    vipTransferContributionValueAll
		    vipTransferContributionValueYear
		    paidContributionValueAll
		    paidContributionValueYear
	        prepaidRechargeAmountYear
		    deductDepositAmount
		    deductedAmountYear
4、需要调用dubbo接口进行数据补充的参数
	A、补充客户经理名称（员工账户中心）
	B、补充客户机构规模（客户中心详情接口）
	C、补充地区信息（字典获取）
	D、补充客户经理部门名称（账户中心和缓存）
	E、补充客户所属网点（缓存）
	F、补充跟进人信息（员工账户中心）
	G、共享人员（市场划分、账户中心）
	H、签到人（账户中心）
	I、会销（线索）
5. 配置相关：见文档 [20260129小二-发布脚本-机构管理](/read/book/70/173299) 

## **二、机构管理新对接（机构管理、其他上层）**

**见在线文档** [**https://doc.weixin.qq.com/sheet/e3\_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcIbmHg4iAGsAvwaPAME&tab=fhmrtt**](https://doc.weixin.qq.com/sheet/e3_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcIbmHg4iAGsAvwaPAME&tab=fhmrtt)

### 2026年1月13日 提测部分：PC、移动机构管理

1. 新增接口：[11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
    1. 出入参可见文档：[机构管理公共方法](/read/book/70/174589)
    2. 以下老接口需要前端替换到新接口
        1. 移动端机构管理：
            1. [02-移动端机构管理-列表查询](/read/book/70/173045) /agency/manage/list 
                1. 替换方式：直接替换，命名规则按照最新接口和在线文档进行修改
            2. [04-移动端机构管理-顶部查询](/read/book/70/173043) /agency/manage/top
                1. 替换方式：直接替换，命名规则按照最新接口和在线文档进行修改
                2. 前端需要传入pageIdex=1，pageSize=10用来和原逻辑保持统一 @李文武 
        2. pc接口管理：[00-责任户列表信息获取（老的接口）](/read/book/70/173046) /table/getTableData

            1. 替换方式：直接替换，命名规则按照最新接口和在线文档进行修改
        3. 老接口暂时先不下线，后面迭代再下线 @陈禹吣 
2. [03-移动端机构管理-代理机构数统计](/read/book/70/173044) /agency/manage/agentCount
    1. 为了线上更方便的对比数据，该老接口不动，复制一个新接口[01 移动端机构管理-代理机构数统计](/read/book/70/174604)/table/agentCount
        1. 原逻辑：
            1. 登陆人业务大区为空时直接返回空（需要给统计值设置默认值0）——————保持
            2. appCode为空直接抛错——————保持
            3. **如果传入大区则以传入大区查询api，否则以登陆人大区查询api——————在这个接口中要删除不用单独再写一遍，因为机构管理里有这段逻辑**
            4. **判断跨区经营户——————在这个接口中要删除不用单独再写一遍，因为机构管理里有这段逻辑**
                1. **如果不是跨区经营户则需要设置省直单，传入则以传入为准，没传入则以登陆人业务省直单为准**
                2. **如果是的话省直单参数不传**
            5. **如果传入手机号，则换有效关系换取机构ID列表，为空直接返回——————在这个接口中要删除不用单独再写一遍，因为机构管理里有这段逻辑**
            6. **如果传入focusScene不为空重点关注场景，则调用数据组接口换取机构ID，机构ID为空直接返回空——————去除，机构管理方法中会完成**
            7. 三个统计值：
                1. 调用公共方法 [cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList ——————保持
                2. 总计：不传客户类型，统计中介和个代
                3. 中介数量：传入客户类型为中介
                4. 个代数量：传入客户类型为个代
            8. 如果是人资appcode，则需要把个代设置为0——————保持
        2. 改动方式
            1. 入参按照机构管理的命名进行统一修改，出参不变
            2. 内部逻辑服务端需要替换对接最新的机构管理
            3. 额外做的逻辑不需要专门再做一遍，统一由机构管理完成，只需要控制客户类型的统计即可
3. [02-移动端机构管理-列表查询](/read/book/70/173045) /agency/manage/list 
    1. 前端改动：使用新接口 [11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
    2. 该接口后面迭代下线
4. [04-移动端机构管理-顶部查询](/read/book/70/173043) /agency/manage/top
    1. 前端改动
        1. 使用新接口 [11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
        2. 需要传入pageIdex=1，pageSize=10以保持和原保持统一
    2. 原逻辑：直接调用  /agency/manage/list 接口 并且后端传入 pageIdex=1，pageSize=10
    3. 该接口后面迭代下线

### 2026年1月16日 提测部分：所有机构管理剩下内容 @陈禹吣 待补充，提测前补充完 

简单的场景和场景对应出入参可以见文档[https://doc.weixin.qq.com/sheet/e3\_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcJjcaqBhAGsAvwaPAME&tab=2ehzn5](https://doc.weixin.qq.com/sheet/e3_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcJjcaqBhAGsAvwaPAME&tab=2ehzn5) 页签「机构管理上层对接出入参」

1. [待办-我的机构支持跨页创建客户待办](/read/book/70/174949) /todo/myInstitutionDimensionBatchCreateTodo 
    1. 该场景使用出入参
        1. 
    2. 前端对接的改动方式（前端改动）： @李文武 
        1. 删除入参”terminalType“: "pc/mob",之前pc和移动是两个接口因此需要用参数区分调用哪个接口 
        2. 修改参数parameter
            1. 命名修改为"queryParam":""
            2. 参数格式从json改为正常对象
    3. 对接机构管理的改动方式（服务端改动）
        1. 原逻辑：
            1. 如果入参terminalType为pc
                1. 入参为空不做查询
                2. 补充查询条件查询页数为5000
                3. 调用老的pc机构管理接口/table/getTableData，传入参数和登陆人信息
                4. 如果查询接口返回的total超过5000则直接报错返回
                5. 获取出参的机构ID做后续处理（老参数institutionId）
                6. 调用待办接口：[cn.com](http://cn.com).servyou.yypt.todotask.facade.ITodoService#uploadTodoReportData
            2. 如果入参terminalType非pc
                1. 入参为空不做查询
                2. 补充查询条件查询页数为5000
                3. 调用老的移动机构管理接口/agency/manage/list，传入参数和登陆人信息
                4. 如果查询接口返回的total超过5000则直接报错返回
                5. 获取出参的机构ID做后续处理（老参数customerId）
                6. 调用待办接口：[cn.com](http://cn.com).servyou.yypt.todotask.facade.ITodoService#uploadTodoReportData
        2. 新逻辑：
            1. 入参为空不做机构管理的查询
            2. 不管是移动调用还是pc调用都调用新接口[1 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
            3. 设置分页参数为5000，其他参数以前端传入为准，传入补充参数标志为false，即无需机构管理额外补充数据范围，因为这个场景只需要获取机构ID，传入机构管理的场景为“institutionBasic”
            4. 如果查询接口返回的total超过5000则直接报错返回
            5. 获取出参的机构ID做后续处理（参数institutionId）
            6. 如果前端传入了参数excludedCustomerIdList，则还要过滤掉这些客户ID
            7. 调用待办接口：[cn.com](http://cn.com).servyou.yypt.todotask.facade.ITodoService#uploadTodoReportData——————不变
2.   [04 机构管理-共享机构列表查询](/read/book/70/174583) /table/queryShareInstitution
    1. 为了线上更方便的对比数据，该老接口不动，复制一个新接口 ：[04 机构管理-人资共享机构列表查询](/read/book/70/174596)/table/queryShareInstitutionNew
    2. 该场景使用出入参
        1. 详细使用和配置可见文档[https://doc.weixin.qq.com/sheet/e3\_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcl1OW01RAGsAvwaPAME&tab=yrggla](https://doc.weixin.qq.com/sheet/e3_AGsAvwaPAMECNK52lP2apSiqaXNZX?scode=AAoA1wcYAAcl1OW01RAGsAvwaPAME&tab=yrggla)
        2. 简单的出入参可以直接见接口文档，已经按新的重新写过了
    3. 前端对接的改动方式（前端改动）：
        1. 出入参命名全部要按照机构管理的最新定义，可以见在线文档
    4. 对接机构管理的改动方式（服务端改动）
        1. 原逻辑：
            1. 责任户管理，登陆者无大区直接返回空列表
            2. 参数校验：入参不能为null、appcode必传
            3. 设置大区：传入则以传入为准，没传入取登陆人的
            4. 设置省直单：传入则以传入为准，没传入取登陆人的
            5. 设置查询范围默认我的机构statisticsWay=myInstitution
            6. 判断参数queryShareInstitutionScene，如果不是共享人员场景，会设置客户经理ID为登陆人ID
            7. 重点关注方法（和移动端机构管理列表list、移动端代理机构数统计agentCount是一个方法，和pc不是一个）
                1. 如果前端传入客户经理ID
                    1. 调用公共方法，传入客户经理ID和重点关注参数换取机构ID列表：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.FocusDataBusinessImpl#querySaleInstitutionIdList
                2. 如果前端没有传入客户经理ID
                    1. 获取入参orgCode，如果是查询下属的机构则查询数据权限范围下的客户经理，调用/common/departEmployeeList，传入前端传入的组织机构查询在职员工
                    2. 如果数据权限范围下的客户经理为空
                        1. 获取组织机构对应销售区域（会包含下级）：[cn.com](http://cn.com).servyou.market.facade.region.QueryRegionSaleAreaFacade#listByDepartCodeList
                        2. 再用市场划分返回的销售区域ID查询公共方法换取机构ID列表：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.FocusDataBusinessImpl#querySaleInstitutionIdList
                    3. 如果数据权限范围下的客户经理不为空
                        1. 调用公共方法，传入客户经理ID和重点关注参数换取机构ID列表：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.FocusDataBusinessImpl#querySaleInstitutionIdList
                3. 和pc机构管理的方法区别
                    1. 移动端多一步：当没有传入客户经理ID时，会用入参部门换取数据权限范围下的客户经理查询公共方法，当换取不到的时候才会调用市场划分接口去换销售区域ID列表
                    2. **本期直接统一为mob的逻辑，测试可以关注一下  @吴文毅
            8. 剩余处理和getTableData逻辑一致，之前代码备注写的也是：暂时方案，除了销售区域范围外都从原机构管理复制，目前看起来二者的差异仅只是参数queryShareInstitutionScene
                1. queryShareInstitutionScene参数影响的地方是这个场景会查询协同，并且排序时候会多一个创建时间
                2. 销售范围的差异是指机构管理会走公共池方法获取可见销售区域范围，而共享机构没有这个框定
        2. 新逻辑：
            1. 责任户管理，登陆者无大区直接返回空列表——————————保持不变
            2. 参数校验：入参不能为null、appcode必传——————————保持不变
            3. **设置大区、设置省直单、默认我的机构、重点关注方法————————————在这个接口中删除，这些逻辑机构管理都有**
            4. **判断参数queryShareInstitutionScene————————————删除，没有必要，之前前端调用这个接口传的始终是true，估计是直接换接口的时候保留的累赘参数**
            5. **给机构管理新增一个入参queryShareInstitutionScene=true ——————————之前是前端写死true传入的，调用该接口服务端直接写死传true**
            6. **给机构管理传查询api的场景shareInstitution（配置表可配可不配，不配就走默认，所有都支持查询）**
            7. 直接对接新机构管理[11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
                1. 之前的客户类型名称补充转换为了老模型，本次改造返回的是老模型
3. 客户盘点的统计（不涉及前端，仅后端重新对接机构管理）@裴华 
    1. 公共方法路径：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.BoardDataBusinessImpl#countNum
    2. **提供了一个测试方法看之前老接口的出参：/test/testOldBoardDataCountNum**
    3. 公共方法使用场景：
        1. 客户盘点：会员类型——统计各会员类型下的数量（VipTypeCountCardHandler）
            1. 会员总数、非会员总数、逾期会员总数
        2. 客户盘点-统计认领释放（ClaimDistributionCountCardHandler）
        3. 客户盘点-统计明日释放（TomorrowReleaseCountCardHandler）
            1. itcrm\_customer\_expected\_release\_data@release\_days
    4. 不涉及前端，仅后端重新对接机构管理
        1. 原逻辑：直接调用getTableData接口，传入参数
            1. statisticsWay：myInstitution（我的机构）
            2. appCode
            3. pageIndex、pageSize=1
            4. 差异参数
                1. 会员类型统计：vipTypeCode传入VIP、NON、EXPIRE
                2. 认领释放统计：managerDivideTimeFrom、managerDivideTimeTo，参数为前端传入的queryDateStart和queryDateEnd
                3. 统计明日释放：itcrm\_customer\_expected\_release\_data，设置releaseDateSoon
        2. 新逻辑：
            1. 替换为新参数，对接机构管理改为调用新接口 [11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
            2. 新增入参queryApiSceneCode传入institutionBasic，因为当前场景只会用到total，不需要那么多查询条件
        3. 使用到的出参只有total
4. 客户管理策略 （不涉及前端，仅后端重新对接机构管理）@裴华 
    1. 获取可见销售区域范围内的客户（即：获取客户释放范围）：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.customerManageSrategy.service.impl.CustomerManageStrategyBusinessImpl#getCustomers
        1. 财税代理客户管理策略预计释放
        2. 人资大客客户管理策略自动释放
    2. 提供了测试方法
        1. 看之前老方法的出参：/test/customerManageStrategyGetCustomers
        2. 看新方法：/test/customerManageStrategyGetCustomersNew
    3. 对接机构管理API使用入参
        1. 之前不是调用机构管理方法的，是直接调用机构管理API接口的
        2. 设置可见销售区域范围
            1. ——>之前的逻辑如果没有可见销售区域范围则直接返回不走后面逻辑
            2. 调用的是公共池提供的公共方法获取
        3. 设置参数queryHasManagerCustomer，查询有责任人的客户=true
            1. ——> 对应之前api接口的查询条件是：(${queryHasManagerFlag} = true and "mrcadi\_24@customer\_manager\_id"  is not null and "mrcadi\_24@customer\_manager\_id" !='' )
            2. 这里使用这个参数，机构管理没使用，所以这里要测一下
        4. 设置参数机构类型是中介和个代
            1. ———> 去除，因为机构管理本身就框定了只会查询中介和个代
        5. 设置经营中心参数
            1. ——> 对应之前api接口的查询条件是："mrcadi\_24@business\_center\_code" =  ${businessCenterCode} 
            2. 这里使用这个参数，机构管理没使用，所以这里要测一下
        6. 设置大区参数
            1. ——> 对应之前api接口的查询条件是：mrcadi\_24@big\_region\_code = ${bigRegionCode}
            2. 机构管理虽然会用到这个参数，但是客户管理策略需要特殊处理这个大区，因为配置中支持默认，若配置的是默认则此处大区参数传null
        7. 设置排序字段ukid
            1. ——> 保持
        8. 新增字段查询场景“customerManageStrategy”，可以用来控制查询什么字段
        9. 第一次查询分页参数：pageIndex=1、pageSize=2000，后面查询都会带上biggerUkid进行查询
    4. 使用出参：
        1. ukId
        2. 机构ID：institutionId
        3. 机构类型：institutionTypeCode
        4. 客户经理ID：customerManagerId
5. [根据客户名称模糊搜索机构责任户](/read/book/70/174900) /institution/searchMyGroupByFullName
    1. 之前是直接调用的api接口方法
    2. 使用入参 ————> 改动后
        1. customerManagerList写死传入的登陆人ID ————> 对接新机构管理传入customerManagerIdList
        2. institutionContent传入的前端传入的searchContent————> 对接新机构管理传入institutionName
        3. institutionType传入前端传入的代理类型————> 对接新机构管理传入institutionTypeCode
        4. bigRegionCode传入登陆人大区
        5. provinceCityAreaCode传入登陆人省直单
        6. available有效标志传入前端传入的status，前端未传入默认查有效————> 对接新机构管理传入validFlag
        7. confirmStatusList定位地址传入前端传入的ConfirmStatusList————> 对接新机构管理传入addressConfirmStatusCodeList
        8. ——————> 新增入参用来简化查询参数queryApiSceneCode=searchMyGroupByFullName
    3. 使用出参
        1. AgentCustomerInfoBO agentCustomerInfoBO = new AgentCustomerInfoBO();
agentCustomerInfoBO.setCustomerId(item.getInstitutionId());
agentCustomerInfoBO.setCustomerName(item.getInstitutionName());
agentCustomerInfoBO.setCustomerType(item.getInstitutionTypeCode());
agentCustomerInfoBO.setAreaCode(item.getRegion());
String areaName = mixRpc.getParentValueByCodeAndType(item.getRegion(), DictTypeEnum.AREA);
agentCustomerInfoBO.setAreaName(areaName);
agentCustomerInfoBO.setAddress(item.getAddress());
agentCustomerInfoBO.setLocationAddress(item.getLocationAddress());
agentCustomerInfoBO.setPoiAddress(item.getPoiAddress());
agentCustomerInfoBO.setStreetNumber(item.getStreetNumber());
agentCustomerInfoBO.setLng(item.getLng());
agentCustomerInfoBO.setLat(item.getLat());
agentCustomerInfoBO.setLocationAddressDetail(item.getLocationAddressDetail());
agentCustomerInfoBO.setConfirmStatus(item.getAddressConfirmStatusCode());
6. [10 大区下机构列表查询（大区下所有中介和个代）](/read/book/70/174591)/table/queryRegionInstitutionList
    1. 方法路径：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#queryCustomers
    2. 为了方便测试，原接口都更名没删
        1. queryRegionInstitutionListOld，可以对比数据
    3. 使用场景：
        1. 附近客户查询客户（使用的total）
        2. 全大区客户/queryRegionInstitutionList
    4. 使用的入参：
        1. appCode（入参appCode）
        2. institutionTypeList——传入的institutionType
        3. vipTypeCode
        4. institutionScale
        5. competitorCodeList————入参competitiveProductList
        6. bigRegionCode——————传入登陆人业务大区
        7. provinceCityAreaCode——————传入登陆人业务省直单
        8. pageSize——————IRIS配置：queryAllRegionCustomerLimit（全大区客户查询参数单次查询es上限）
        9. confirmStatusList——————默认Y+N，如果传入以传入为准confirmStatus
        10. available——————只获取未注销
        11. minlng、maxlng、minlat、maxlat
    5. 使用的出参
        1. 全大区客户使用
            1. 客户经理ID
            2. 设置距离distance
            3. 设置最后跟进时间
            4. 设置客户经理名称
            5. 接口文档描述的参数都需要支持[10 大区下机构列表查询（大区下所有中介和个代）](/read/book/70/174591)
        2. 附近客户使用total
7. [公共池列表查询](/read/book/70/174292) /publicPool/customer/list/query**核对出参**@陈禹吣 
    1. 之前的老接口没有下线，可以使用路径 /publicPool/customer/list/queryold查询，为方便测试时对比
    2. 接口逻辑
        1. **调用【公共方法1】，**传入参数isPoolPublic=true
            1. 这个接口虽然调用了【公共方法1】但是不涉及补偿逻辑
            2. 但是公共方法1其实是机构管理查询的逻辑，而公共池列表没有必要一起混用，因此会提供一个新的**【公共方法3】**在公共池场景下替代公共方法1
        2. 补充公共池操作按钮publicPoolActionBars
    3. 新逻辑：直接调用【公共方法3】
8. [公共池统计中介机构和个人代理](/read/book/70/174291)/publicPool/agency/statistics
    1. 之前的老接口没有下线，可以使用路径 /publicPool/agency/statisticsold 查询，为方便测试时对比
    2. 接口逻辑
        1. **调用【公共方法1】，相当于直接调用/publicPool/customer/list/query**
            1.  使用入参
                1. vipTypeCode，前端传入 
                2. queryNoManagerCustomer=true
                3. appCode，前端传入
                4. agentType传个代和中介分别进行统计
            2. 使用出参：total
    3. 新逻辑：
        1. **换调用【公共方法3】**，传入appcode、会员类型、代理类型
9. [公共池顶部搜索](/read/book/70/174290) /publicPool/customer/list/search
    1. 之前的老接口没有下线，可以使用路径 /publicPool/customer/list/searchold 查询，为方便测试时对比
    2. 接口原逻辑：
        1. 查询客户中心 → 根据机构ID查询机构管理调用的是【公共方法1】
        2. 使用的入参
            1. institutionIdList
            2. pageSize=20
            3. appCode
            4. 需要进行数据补偿，针对数据补偿提供了一个专门参数，当前只有这个接口需要进行数据补偿
        3. 使用的出参
            1. 机构ID
            2. 客户经理Id
        4. 其他逻辑的改动逻辑：
            1. **会员数据补充使用了标签，统一改为从宽表获取 ————————————> 暂时不动**
    3. 改动逻辑：改为调用【公共方法3】，并且该接口需要使用到补偿逻辑
10. 中介机构管理
    1. 方法路径：[cn.com.servyou.marketing.itcrmweb.business.service.impl.AgencyManageBusinessImpl#listAgency](/read/book/70/174996)
        1. 方法逻辑：
            1. 登陆人业务大区为空时直接返回空
            2. 获取当前员工可以查看的用户：登陆人大区团队管理权限组织机构查询出的人员ID列表，如果没有人员列表则直接返回空
            3. 如果传入CustomerManager的参数是all，则设置查询客户经理列表"mrcadi\_24@customer\_manager\_id" in ${permissionCustomerManagerList}
            4. 如果传入了CustomerManager，则要判断是否在权限范围内，如果不在范围内则直接报错
            5. 如果是跨区经营户，即crossRegionBusinessCustomerFlag=Y时，清空省直单
            6. 如果appCode是人资时，设置查询来源，用来控制公共池和机构管理的排序
            7. 调用【公共方法2】[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
    2. 影响点：
        1. [11-中介机构管理-列表查询](/read/book/70/174599)/agency/manage/listAgency
            1. 之前老的没删除，用来做对比 /agency/manage/listAgencyold
            2. 设置了大区和省直单是登陆人的
            3. 之前支持的出入参-- 出参
customerId
customerName
customerType
customerTypeName
areaCode
areaName
address
lastFollowTime
lastChanceStage
lastChanceStageName
stageThreshold
meeting
releaseTimeSoon
releaseDateSoon
claimUpper
actionTable
customerManager
customerManagerName
saleAreaName
customerManagerDepartCode
customerManagerDepartName
tagList
customerMark
masterGroupId
projectStatus
agencyAddress
createTime
servyouNumber
customerStatus
customerStatusName
businessCenter
businessCenterName
shareSynergy
extSourceCode
extSourceName
customerStratification
customerStratificationName
extIndustryCode
extIndustryName
employeeNum
notFollowDays
businessAction
businessActionName
specificItem
specificItemName
lastFollowContent
textContent
majorCustomerType
majorCustomerTypeName
locationAddressDetail
confirmStatus
customerSite
customerSiteName
lastFollowPersonTrueId
lastFollowPersonName
creatorId
creatorName
suspectedPartner
suspectedPartnerCode
institutionScale
competitorExpireName
competitorExpireMonth
competitorExpireMonthName
isJointOperation
isJointOperationName
vipTypeCode
vipTypeName
followResult
followResultName
signCreateTime
signInPerson
signInPersonName
businessPurpose
businessPurposeName
lastChanceType
lastChanceTypeName



-- 入参
appCode
crossRegionBusinessCustomerFlag
customerManager
areaId
lastChanceStage
lastFollowTimeStart
lastFollowTimeEnd
sort
sortType
customerName
agentType
orgCode
statisticsWay
focusScene
tagCodeList
customerMarkList
institutionContent
containsSlaveGroup
projectStatus
unFollowAfterClaim
releaseDateSoon
institutionIdList
queryShareInstitutionScene
shareSynergyId
managerDivideTimeFrom
managerDivideTimeTo
customerStatusList
institutionFromFlag
customerStratification
employeeNumStart
employeeNumEnd
extIndustryCode
extSourceCode
notFollowDaysStart
notFollowDaysEnd
type
department
majorCustomerType
contactMobile
addressConfirmStatus
invalidAddressUpdateTimeInterval
addressCollectionTime
expendAccountPriorityEnCode
institutionScale
competitorCodeList
taxFilingsFlag
lastFollowResult
establishDuration
locationAddressFirstDataSource
groupCode
competitorExpireMonth
lose
isJointOperation
vipTypeCode
followProgressSituation
        2. [14财代获取员工指定数据权限下员工信息以及是否占上限](/read/book/70/174996) /common/employeeListGroupByOrg
            1. 老方法没删除：可以调用测试方法 /test/getHoldUpperCountMapOld
            2. 占上限方法路径：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.AgencyManageBusinessImpl#getHoldUpperCountMap
            3. 入参：
                1. 截取入参员工数量为IRIS配置holdUpperCustomerManagerSize
                2. pageSize设置30000
                3. appCode设置为财税代理
                4. isClaimUpper设置Y
                5. upperFlag=true → 这个参数可以去掉了，没有用，已经改成了非会员
                6. bigRegionCode，传入的是登陆人业务大区
                7. 传入参数查询非会员**（此处需要包含的是：非会员标记和无会员类型的客户）**
            4. 使用出参：
                1. 根据客户经理ID进行分组统计
        3. [模糊搜索中介/个代（有中介公共池逻辑）](/read/book/70/174899) /common/searchGroup
            1. 老方法没删除：可以调用 /common/searchGroupold
            2. 逻辑是先查询客户中心 → 带着查询到的机构ID查询机构管理
            3. 查询机构管理的入参：
                1. pageIndex=1
                2. pageSize=100
                3. 机构ID列表=根据查询入参从客户中心获取到的代理id列表
                4. appCode=前端传入
                5. containsSlaveGroup是否包含从机构
                6. bigRegionCode传入登陆人业务大区
                7. ProvinceCityAreaCode传入登陆人省直单
            4. 使用的出参：
                1. 机构ID
                2. 机构名称
                3. 税号
                4. 客户状态"oci\_1@valid\_flag" = ${validFlag}
                5. 机构类型
                6. **机构地址：agencyManageBO.setAgencyAddress(agencyManageBO.getAreaName()+agencyManageBO.getAddress());** @李文武 **是否已经无用**
                7. 客户经理ID
                8. 客户经理名称
                9. 主机构ID
                10. 省直单code、名称（名称是从缓存中获取的）
11. 移动端涉及到的两个公共方法
    1. **【公共方法1】**：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.PublicPoolMyCustomerBusiness#queryAgencyList
        1. 如果是人资应用则设置查询来源是人资公共池（ptcrmPublicPool）
        2. 如果是财税应用则设置查询来源是财税公共池（agencyPublicPool）
        3. 调用【公共方法2】[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
            1. -- 查询条件补充
1、可见销售区域范围
	a、查询公共池公共方法获取可见销售区域范围，以下传入参数
		appCode
		businessCenterCode传入null	
	    bigRegionCode传入入参大区
		departCode传入入参departmentCode
		如果传入了公共池层级参数则传入参数publicPoolLevelCode
			设置参数publicPoolLevelCodeList
			如果部门不为空departmentCode并且公共池层级传入的是大区不包含下级（bigRegionExcludeSubordinate）或者大区包含下级（bigRegionIncludeSubordinate）则设置大区参数为部门departmentCode
	b、调用公共方法获取可见销售区域范围
2、如果是公共池查询（isPoolPublic=true）
	a、换取省直单：若为大区用户则返回大区对应的所有省直单，若为省直单用户则直接返回所属业务省直单
	b、设置为查询机构api接口参数入参【ProvinceCityAreaCodeList】
3、判断是否是网点机构：网点的机构：数据权限范围下的组织机构对应的销售区域
	a、根据入参orgCode查询市场划分接口根据组织机构 code 获取销售区域列表 cn.com.servyou.market.facade.region.QueryRegionSaleAreaFacade#listByDepartCodeList
	b、设置为查询机构api接口参数入参【areaIdList】
4、参数整理
	a、设置跟进时间开始结束补充时分秒00:00:00和23:59:59
	b、处理行政区划参数areaId去末尾00
	c、如果查询我的机构并且是共享机构查询场景则根据登陆人trueid补充协同参数
	d、如果查询下属的机构需要根据入参orgCode换取员工列表
		如果是共享人员场景则以这些客户经理ID补充协同参数
		如果不是共享人员场景则设置客户经理参数到api查询接口【permissionCustomerManagerList】
	e、如果传入了客户经理ID设置到api查询接口【customerManagerList】
	f、如果传入了共享人员参数shareSynergyId则根据这个参数补充协同参数
	g、如果是大客appCode则设置客户类型为中介
	h、设置客户类型为传入agentType否则写死传入1、2
	I、设置来源标识mobileInstitution，用于排序区分
5、下属查询如果参数整理处的d处没有换到员工列表参数则直接返回空
6、分群逻辑处理
7、查询机构管理api接口

--宽表查询不到数据时的补偿逻辑：目前只有/publicPool/customer/list/search需要进行补偿
--当分群企业数大于配置值时，设置返回的分页统计数以分群返回为准
--参数填充
    2. **【公共方法2】**：[cn.com](http://cn.com).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
    3. **【公共方法3】** 
        1. -- 查询条件补充
1、可见销售区域范围
	a、查询公共池公共方法获取可见销售区域范围，以下传入参数
		appCode
		businessCenterCode传入null	
	    bigRegionCode传入入参大区
		departCode传入入参departmentCode
		如果传入了公共池层级参数则传入参数publicPoolLevelCode
			设置参数publicPoolLevelCodeList
			如果部门不为空departmentCode并且公共池层级传入的是大区不包含下级（bigRegionExcludeSubordinate）或者大区包含下级（bigRegionIncludeSubordinate）则设置大区参数为部门departmentCode
	b、调用公共方法获取可见销售区域范围
	c、设置为查询机构api接口参数入参【saleAreaIdList】
2、
	a、换取省直单：若为大区用户则返回大区对应的所有省直单，若为省直单用户则直接返回所属业务省直单
	b、设置为查询机构api接口参数入参【ProvinceCityAreaCodeList】
3、分群逻辑处理
4、参数设置整理
	a、设置isPoolPublic=true（可以直接在api配置中查看使用方式）
	b、设置机构ID（来源：前端传入和分群换取）
5、查询机构管理api接口

-- 查询数据后处理
0、没有查询成功的时候会走补偿逻辑
1、参数补充
2、当分群企业数大于配置值时，设置返回的分页统计数以分群返回为准
3、补充操作参数
12. 下线接口：
    1. [责任户管理-获取企业id列表用于翻页](/read/book/70/174707) /customer/listCustomerIdForPage
        1. 直接调用getTableData方法
        2. 前端排查后无使用，直接下线
13. 后面迭代下线接口@陈禹吣 
    1. [00-责任户列表信息获取（老的接口）](/read/book/70/173046) /table/getTableData 
        1. 老的机构管理接口，使用新接口替代 [11 责任户管理-机构列表查询](/read/book/70/174590) /table/queryInstitutionList
    2. [03-移动端机构管理-代理机构数统计](/read/book/70/173044) /agency/manage/agentCount
    3.  [04 机构管理-共享机构列表查询](/read/book/70/174583) /table/queryShareInstitution
    4.  [04-移动端机构管理-顶部查询](/read/book/70/173043) /agency/manage/top
    5. [02-移动端机构管理-列表查询](/read/book/70/173045) /agency/manage/list 







## **三、不同场景对接机构管理使用出入参**

调用分析（代码角度）

1. pc机构管理使用分析
    1. 使用[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#myInstitution场景
        1. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.BoardDataBusinessImpl#countNum，查询我的机构，传入参数为appcode，仅统计
            1. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.BoardDataBusinessImpl#countReleaseSoon 客户盘点-明日释放
    2. 直接调用getTableData
        1. [责任户管理-获取企业id列表用于翻页](/read/book/70/174707) /customer/listCustomerIdForPage ————————————————前端排查后无使用，直接下线
        2. [待办-我的机构支持跨页创建客户待办](/read/book/70/174949) /todo/myInstitutionDimensionBatchCreateTodo
2. 直接使用api接口
    1. api接口：[https://datark.dc.servyou-it.com/#/service/development/detail?apiCode=bigRegionInstitutionManageQuery](https://datark.dc.servyou-it.com/#/service/development/detail?apiCode=bigRegionInstitutionManageQuery)
    2. 使用场景分析（[cn.com](http://cn.com/).servyou.marketing.itcrmweb.manager.rpc.impl.MySearchRpcImpl#listMyInstitutionByDataApi）
        1. 机构管理
        2. 获取可见销售区域范围内的客户（即：获取客户释放范围）
            1. 查询API接口使用入参
                1. queryHasManagerCustomer，自动释放查询-有责任人的客户，true
                2. institutionTypeList，客户类型，[2,3]，中介&个代
                3. permissionAreaSet，销售区域ID列表
                4. pageIndex=1
                5. pageSize=2000
                6. orderBy=ukId
                7. businessCenterCode，经营中心code
                8. bigRegionCode，如果配置表中配置的是default那么参数传null，不然就正常传大区
                9. ————————后面的循环查询时设置参数biggerUkId
            2. 方法：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.customerManageSrategy.service.impl.CustomerManageStrategyBusinessImpl#getCustomers
                1. 财税代理客户管理策略预计释放：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.customerManageSrategy.service.impl.CustomerManageStrategyBusinessImpl#releaseAgencycrmweb
                2. 人资大客客户管理策略自动释放：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.customerManageSrategy.service.impl.CustomerManageStrategyBusinessImpl#autoRelease
        3. 移动端机构管理方法
            1. 方法：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
                1. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.AgencyManageBusinessImpl#list                      ————————————————————能不能排查出使用了哪些查询入参
                    1. [待办-我的机构支持跨页创建客户待办](/read/book/70/174949) /todo/myInstitutionDimensionBatchCreateTodo                  
                        1. 如果入参terminalType不为pc时会走到该逻辑
                    2. [02-移动端机构管理-列表查询](/read/book/70/173045) /agency/manage/list 
                    3. [04-移动端机构管理-顶部查询](/read/book/70/173043) /agency/manage/top
                2. [03-移动端机构管理-代理机构数统计](/read/book/70/173044) /agency/manage/agentCount
                3. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.AgencyManageBusinessImpl#listAgency
                    1. [14财代获取员工指定数据权限下员工信息以及是否占上限](/read/book/70/174996) /common/employeeListGroupByOrg，补充占上限
                    2. [模糊搜索中介/个代（有中介公共池逻辑）](/read/book/70/174899) /common/searchGroup
                    3. [11-中介机构管理-列表查询](/read/book/70/174599) /agency/manage/listAgency
                4. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.PublicPoolMyCustomerBusinessImpl#queryAgencyList
                    1. [公共池统计中介机构和个人代理](/read/book/70/174291) /publicPool/agency/statistics
                    2. [公共池顶部搜索](/read/book/70/174290) /publicPool/customer/list/search
                    3. [公共池列表查询](/read/book/70/174292) /publicPool/customer/list/query
        4. [04 机构管理-共享机构列表查询](/read/book/70/174583) /table/queryShareInstitution
        5. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#queryCustomers
            1. 附近客户使用：查询客户、全大区客户
            2. 查询参数：
                1. appCode（入参appCode）
                2. institutionTypeList——传入的institutionType
                3. vipTypeCode
                4. institutionScale
                5. competitorCodeList————入参competitiveProductList
                6. bigRegionCode——————传入登陆人业务大区
                7. provinceCityAreaCode——————传入登陆人业务省直单
                8. pageSize——————IRIS配置：queryAllRegionCustomerLimit（全大区客户查询参数单次查询es上限）
                9. confirmStatusList——————默认Y+N，如果传入以传入为准confirmStatus
                10. available——————只获取未注销
                11. minlng、maxlng、minlat、maxlat
        6. [cn.com](http://cn.com/).servyou.marketing.itcrmweb.manager.rpc.impl.MySearchRpcImpl#listMyInstitutionNew
            1. [根据客户名称模糊搜索机构责任户](/read/book/70/174900) /institution/searchMyGroupByFullName
                1. 查询参数
        queryBO.setCustomerManagerList(Lists.newArrayList(userBO.getTrueId()));
        queryBO.setInstitutionContent(searchInstitutionBO.getSearchContent());
        queryBO.setInstitutionType(searchInstitutionBO.getAgentType());
        queryBO.setBigRegionCode(userBO.getBizBigRegionCode());
        queryBO.setProvinceCityAreaCode(userBO.getBizProvinceCityAreaCode());
        queryBO.setAvailable(StringUtils.isNotEmpty(searchInstitutionBO.getStatus()) ? searchInstitutionBO.getStatus() : AvailableEnum.YES.getCode());
        queryBO.setPageIndex(1);
        queryBO.setPageSize(searchInstitutionBO.getLimit());
        queryBO.setConfirmStatusList(searchInstitutionBO.getConfirmStatusList());
            2. 附近客户，登陆者私海客户+当前登陆者公海客户。

## **四、接口逻辑（原pc、移动逻辑）**

1. pc端接口：[00-责任户列表信息获取（老的接口）](/read/book/70/173046) /table/getTableData
    1. ************************************************
******* 第一部分：查询参数设置
************************************************
1、登陆人无业务大区时返回空列表
2、设置排序逻辑（入参orderBy）
    传入openNotBuyNumber、productNotUsedNumber、dqrqNumber时，设置orderBy为companyNumber
    传入personalAgentLevel时，设置orderBy为person_agent_level
    需要前端帮忙分析：入参orderBy是不是已经没有地方回传入openNotBuyNumber、productNotUsedNumber、dqrqNumber、personalAgentLevel
3、设置参数：判断是否是多个客户经理的场景（multCustomer）
    根据是否传入入参customerManager判断，如果没有传入customerManager则认为是多客户经理场景，multCustomer=true                           ————————————？？？
4、customerManager取值设置为，如果前端传入type是manager，那么设置为登陆人trueId，不然则设置为前端传入的customerManager
5、特殊处理条件参数设置（cn.com.servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#setPublicParam）  —————————————— 企业管理公用方法
    设置wechatCustomerManager、synergyId参数为登陆人trueid（虽然代码设置了customerManager为登陆人，但是在外面的下一步覆盖了该参数）
    设置pageIndex、pageSize、orderyBy、orderType
    如果前端传入lastFollowTime参数，则用英文逗号隔开，设置lastFollowTimeFrom，lastFollowTimeTo【对应筛选项：最近跟进时间，前端传入格式为年月日时分秒】
    如果前端传入followTimeRecently参数，则用英文逗号隔开，设置lastFollowTimeFrom，lastFollowTimeTo
    如果前端传入nextContactTime参数，则用英文逗号隔开，设置nextContactTimeFrom，nextContactTimeTo
    statisticsWay默认设置为statisticsWay，我的机构
    设置appCode（多余操作，从param取了appCode再设置一遍）
    如果前端传入vatConfirmationDate参数，则用英文逗号隔开，设置vatConfirmationDateFrom、vatConfirmationDateTo
    如果前端传入divideTime参数，则用英文逗号隔开，设置divideTimeFrom、divideTimeTo
    如果前端传入recentlyReleaseTime参数，则用英文逗号隔开，设置divideTimeFrom、divideTimeTo
    如果前端传入cpbIdList参数，则用英文逗号隔开，设置cpbIdList为列表格式
    如果前端传入industryTopCategoryList参数，则用英文逗号隔开，设置industryTopCategoryList为列表格式
    如果前端传入industryTopCategory参数，则用英文逗号隔开，设置industryTopCategory为列表格式，设置给参数industryTopCategoryList（备注写的是移动端传参兼容）
    如果前端传入dqrq参数，则用英文逗号隔开，设置dqrqFrom、dqrqTo
    如果前端传入bzsj参数，则用英文逗号隔开，设置bzsjMin、bzsjMax
    如果前端传入statisticsPattern、statisticsPatternTime————————————————之前的产品未购，应该是下架了，需要前端排查一下，如果有使用再罗列逻辑，暂时当做不用，直接舍弃该逻辑（1873-1897）
    如果前端传入region，则用英文逗号隔开，设置cityCode、countyCode【对应筛选项：地区】
    如果前端传入agentCustomerNum，则用英文逗号隔开，设置agentCustomerNumFrom、agentCustomerNumTo
    如果前端传入agentVipCustomerNum，则用英文逗号隔开，设置agentVipCustomerNumFrom、agentVipCustomerNumTo    
    如果前端传入agentNonVipCustomerNum，则用英文逗号隔开，设置agentNonVipCustomerNumFrom、agentNonVipCustomerNumTo
    如果前端传入relatedCustomerNum，则用英文逗号隔开，设置relatedCustomerNumFrom、relatedCustomerNumTo
    如果前端传入relatedVipCustomerNum，则用英文逗号隔开，设置relatedVipCustomerNumFrom、relatedVipCustomerNumTo    
    如果前端传入relatedNonVipCustomerNum，则用英文逗号隔开，设置relatedNonVipCustomerNumFrom、relatedNonVipCustomerNumTo    
    如果前端传入releaseCountDown，应该是已经下了，设置expect_release_date、expect_release_date_to     
    协同类型参数设置及排序参数
        只针对tableKey为mySynergyCustomer、mySynergyPersonalAgent，因此可以暂时无视，不考虑进机构管理的变更中（1975-1998）
    如果前端传入memberExpireTime，则用英文逗号隔开，设置memberExpireTimeStart、memberExpireTimeEnd      
    如果前端传入customerMemberExpireTime，则用英文逗号隔开，设置customerMemberExpireTimeStart、customerMemberExpireTimeEnd      
    如果前端传入agentDqrq，则用英文逗号隔开，设置agentDqrqStart、agentDqrqEnd
    如果前端传入prepaidRechargeAmountYear，则用英文逗号隔开，设置prepaidRechargeAmountYearFrom、prepaidRechargeAmountYearTo【对应筛选项：预存款充值金额(当年)】
    如果前端传入deductedAmountYear，则用英文逗号隔开，设置deductedAmountYearFrom、deductedAmountYearTo【对应筛选项：预存款抵扣金额(当年)】
    如果前端传入lastRiskFollowTime，则用英文逗号隔开，设置lastRiskFollowTimeFrom+00:00:00、lastRiskFollowTo+23:59:59
    如果前端传入expireTime，则用英文逗号隔开，设置validCpbLastExpireTimeStart、validCpbLastExpireTimeEnd   
    如果前端传入majorCustomerType，设置majorCustomerType为list格式【对应筛选项：大客类型】
    如果前端传入groupCode，设置groupCode【对应筛选项：所属分群】
    如果前端传入competitorExpireMonth，设置competitorExpireMonth【对应筛选项：竞品到期月】
    如果前端传入lose，设置lossRisk，备注是流失风险，没有在机构管理筛选配置中找到该参数
    如果前端传入institutionIdList，设置institutionIdList
6、设置currUserId为登陆人trueId
7、设置appId（根据入参appCode换取）
 
 
 
************************************************
******* 第二部分：查询
******* cn.com.servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#listMyInstitution
************************************************
1、设置available=Y，只查询未注销的机构
2、判断查询范围（根据入参机构类型statisticsWay进行区分）
    【我的机构】
        statisticsWay=myInstitution
        1、判断是否查询共享人员场景（入参queryShareInstitutionScene）——————————————应该是不用了吧，因为共享机构单独拆出来了
            A、是共享人员场景（queryShareInstitutionScene=true）
                a、调用【公共方法1】构造查询的协同类型及人员：cn.com.servyou.marketing.itcrmweb.business.service.CommonBusiness#buildShareSynergyIdList
                b、查询参数被清空为只剩下需要查询的协同类型和协同人员ID                                                                                       ——————————————————————感觉有点问题，测试一下是不是共享场景下筛选参数失效了
            B、非共享人员场景（queryShareInstitutionScene=false或不传，默认false）：
                设置参数customerManagerList为登陆人trueId
    【下属的机构】
        statisticsWay=underInstitution，并且，customerManagerList为空
        1、获取入参department（筛选项：部门）传入/common/departEmployeeList，获取当前登录人大区团队管理数据权限下大区组织机构员工列表
            如果员工列表不为空，则判断是否查询共享人员场景
                是共享人员：同我的机构
                非共享人员：将查询到的员工ID列表设置进参数customerManagerList中
            如果员工列表为空，则直接返回空
    【网点的机构】
        statisticsWay=orgInstitution
        1、获取入参department（筛选项：部门），调用市场划分接口换取销售区域列表：cn.com.servyou.market.facade.region.QueryRegionSaleAreaFacade#listByDepartCodeList，将销售区域ID列表设置进areaIdSetTemp参数中
        2、如果没有传入department或者没有换取到对应销售区域列表，则直接返回空列表
3、参数设置
    1、参数customerManager不为空，设置customerManagerList为传入customerManager
    2、参数shareSynergyId不为空，设置shareSynergyId为传入shareSynergyId，调用公共方法1组装协同id并清空了其他查询条件
    3、重点关注查询场景参数设置
        A、如果参数customerManagerList为空
            1、获取入参department（筛选项：部门），调用市场划分接口换取销售区域列表：cn.com.servyou.market.facade.region.QueryRegionSaleAreaFacade#listByDepartCodeList
            2、如果销售区域列表不为空则查询api接口，换取机构ID列表：重点关注-查询代理id-销售区域维度 
            3、设置机构ID列表给institutionIdList
        B、如果参数customerManagerList不为空
            1、根据参数customerManagerList查询api接口，换取机构ID列表：重点关注-查询代理id-客户经理维度
            2、设置机构ID列表给institutionIdList
        C、如果前端传入参数focusScene并且没有成功换取到机构ID列表，则直接返回空列表，此处无论前端是否传入重点关注查询参数都会走一遍AB逻辑
    4、前端传入参数institutionId时，会一起放进参数institutionIdList中做后续逻辑
    5、前端传入contactMobile时，根据手机号和登陆人信息查询有效人企关系，如果没有查询到则直接返回空列表，如果查询到则和现在的institutionIdList参数取交集，取完交集后为空也直接返回空列表
4、分群逻辑
    1、使用的是初始的institutionIdList参数（即前端传入的institutionIdList，非后面服务端补充的参数）
    2、将institutionIdList从初始json参数parameter中移除（如果存在的话）
    3、判断是否传入分群code（groupCode），若传入，则走分群的逻辑
        调用【公共方法2】获取中介分群下的数据cn.com.servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#getAgentTableDataBOByGroup
        如果初始参数不为空，并且包含了查询groupCode，并且institutionIdList为空时直接返回空列表————————————————————分群逻辑下没查询到机构则直接返回
    4、如果分群逻辑查询到了机构ID列表，则和我们之前其他的institutionIdList取交集，交集不为空继续往下走，交集为空则直接返回空列表
5、对接财代客户盘点看板模块，如果前端传了institutionIdList就用前端的，没有就按原来的，前端传的不为空，就把它和之前组装好的institutionIdList取交集，交集为空返回空，不为空继续往后走
6、如果前端传入地区（region，服务端自己在前面拆分成了cityCode和countyCode）
    这里的逻辑是如果countyCode为空则取cityCode，如果不为空则用countyCode作为region参数
    如果传入了countyCode或者cityCode，则判断是否是“00”结尾，如果有的话要截掉，去掉末尾的2个0
    将处理好的参数设置到region职工
7、如果appCode是ptcrm人资大客，只查询中介机构，设置参数institutionType=1
8、获取可见销售区域范围，调用公共池公共方法，传入appcode和登陆人信息
    如果销售区域范围为空，则直接返回空列表
    如果销售区域范围不为空，则设置参数areaIdSet
9、销售区域为空&&客户经理为空直接返回空列表
    判断areaIdSet、areaIdSetTemp、customerManagerList、customerManager是否同时为空
10、如果没有指定客户类型则默认中介和个代，设置到参数institutionTypeList=[1,2]
11、设置bigRegionCode为登陆人所属业务大区
12、非跨区经营户（crossRegionBusinessCustomerFlag）需要设置省直单为当前登陆用户
14、设置入口标识institutionFromFlag=myInstitution                    ——————————————————排序类型，区别不同入口排序条件
15、处理最近跟进时间（组合入参最近跟进时间和未跟进天数起止进行计算）—— 前端需要排查下，未跟进天数是否还有传入
    时间无交集->直接返回空列表
16、特殊处理ads拓展表查询参数
    会员纳入率vipPercentBroadStart、vipPercentBroadEnd，需要/100
17、查询API接口
  
 
 
************************************************
******* 第三部分：数据补充
************************************************
1、API查询方法中补充数据
    1、servyouNumber（区分中介、个代，个代使用servyouNumIndividual，中介使用servyouNumInstitution）
    2、实时查询客户中心接口补充机构规模（不做默认值设置，没有就是null）
    3、设置疑似合作机构中文suspectedPartner，从管理端获取（模块小二当家、枚举项suspectedPartner、无论是否有效）
    4、设置竞品到期月competitorExpireMonthName，从管理端获取（模块小二当家、枚举项competitorExpireMonth、无论是否有效）
    5、税局备案taxFilingsFlagName，从管理端获取（模块小二当家、枚举项taxFilingsFlag、无论是否有效）
    6、是否有成交订单：orderDealName，判断orderDeal=Y？“有成交”:“无成交”
    7、跟进结果：followResultName，从管理端获取（模块跟进记录、枚举项followResult、无论是否有效）
    8、最后商机阶段：lastChanceStageName，从管理端获取（模块商机、枚举项stageCode、无论是否有效）
    9、设置主营mainBusinessTypeName，从管理端获取（模块小二当家、枚举项mainBusinessType、无论是否有效）
    10、设置联合经营isJointOperationName，从管理端获取（模块公共、枚举项yesOrNo、无论是否有效）
    11、会员类型vipTypeName，从管理端获取（模块小二当家、枚举项vipFlag、无论是否有效）
    12、设置推荐地址，如果locationAddressFirstDataSource不为空，用/隔开获取列表补充名称，从管理端获取（模块小二当家、枚举项locationAddressFirstDataSource、无论是否有效）
    13、设置目标户标记，如果targetCustomerTypeStatisticsCode不为空，用,隔开获取列表补充名称，从管理端获取（模块小二当家、枚举项targetCustomerTypeStatistics、无论是否有效）
    14、设置成立时长establishDuration，如果establishTime不为空时解析补充
    15、补充距离参数，如果结果经纬度和查询经纬度不为空则设置距离参数
    16、补充竞品信息，如果competitorCodes不为空，,隔开，从管理端获取（模块小二当家、枚举项competitor_code、无论是否有效）
2、查询后数据补充
    1、addExtraInformation=true，需要补充额外数据时
    A、基础信息
        设置客户经理名称customerManagerName，查询的是员工账户中心的http接口
        设置部门名称customerManagerDepartName，缓存获取
        设置机构类型（是把新模型类型转换成了老模型）
        设置机构类型名称（目前设置的是老模型类型名称）
        如果region不为空，则设置regionName，从字典服务中获取，每次都是单个调用
        设置lastFollowTimeHMS、lastFollowTime，处理了胰腺癌数据格式，hms是时分秒格式，lastFollowTime是转换为了日期类型
        设置未跟进天数：最后一次跟进时间不为空时计算
        计算抵扣率deductionRate，需要处理为百分比形式，deductDepositAmount/preDepositAmount
        跟进记录相关，补充经营动作、具体事项、跟进结果，管理端获取枚举值（模块跟进记录，枚举项businessAction、followResult、specificItem）
        最近一次跟进人不为空lastFollowPersonTrueId，补充名称lastFollowPersonName，查询的是员工账户中心的http接口
        补充客户所属网点customerSite，从市场划分实时获取补充，对应参数manageTeamCode
        补充大客分层customerStratification、customerStratificationName
            取的是API返回的extLayerCode作为customerStratification，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.layer.enum.key）
        补充大客行业名称extIndustryName，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.industry.enum.key）
        补充大客来源名称extSourceName，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.source.enum.key）
        补充大客类型majorCustomerTypeName，名称从管理端获取（模块小二当家，枚举项majorCustomerType）
        补充所属网点名称customerSiteName，缓存中获取                                                                          ————————————————可以改为直接从市场划分获取
        设置合作类型名称cooperationEnTypeName（模块客户中心，枚举项配置在IRIS的cooperationEnType.enum.key）
        设置共享人员（协同人员列表）shareSynergy，实时从市场划分获取，cn.com.servyou.market.facade.region.QueryRegionCustomerSynergyDivideFacade#listByCustomerIdList，所有类型的协同数据，协同人员名称是从员工账户中心的http接口补充获取
            返回前端以中文分号隔开返回
        设置签到人signInPersonName，signInPerson不为空时补充，从员工账户中心的http接口补充获取
        设置businessPurposeName签到名称，最后返回以中文逗号隔开返回给前端，businessPurpose不为空时，英文逗号隔开，中文从管理端补充（模块签到管理，枚举项signBusinessPurpose）
        设置最后商机阶段名称lastChanceStageName，管理端获取（模块签到管理，枚举项stageCode）
        设置最后商机类型名称lastChanceTypeName，管理端获取（模块签到管理，枚举项saleChanceType）
    B、组装财税代理标签值
        获取IRIS配置agencycrmweb.query.key的枚举项code从管理端获取枚举值，模块小二当家，设置参数tagList
    C、拓展信息
        金额续费率-收款（狭义）renewedAmountCollectionRate，处理为百分比的展示形式
        会员纳入率（广义）vipPercentBroad，处理为百分比的展示形式
        会员纳入率（一般人）vipPercentGeneral，处理为百分比的展示形式
3、当分群企业数大于配置值时，设置返回的分页统计数以分群返回为准
 

 
 
************************************************
******* 第四部分：需要前端排查内容
************************************************
1、机构管理是否有使用入参：followTimeRecently、nextContactTime、vatConfirmationDate、divideTime、recentlyReleaseTime、cpbIdList、industryTopCategoryList、industryTopCategory、dqrq、bzsj、statisticsPattern、statisticsPatternTime、agentCustomerNum、agentVipCustomerNum、agentNonVipCustomerNum、relatedCustomerNum、relatedVipCustomerNum、relatedNonVipCustomerNum、releaseCountDown、memberExpireTime、customerMemberExpireTime、agentDqrq、lastRiskFollowTime、expireTime、lose、queryShareInstitutionScene、shareSynergyId、notFollowDaysStart、notFollowDaysEnd、vipPercentBroadStart、vipPercentBroadEnd
2、机构管理什么场景下传入该参数：institutionIdList、customerManagerList、institutionId
 
 
 
 
************************************************
******* 第五部分：公共方法逻辑
************************************************
【公共方法1】构造查询的协同类型及人员：cn.com.servyou.marketing.itcrmweb.business.service.CommonBusiness#buildShareSynergyIdList
    1、方法入参：appCode、员工ID列表、登陆人信息
    2、如果未传入员工ID列表则直接返回空参数
    3、查询登陆者大区-协同类型已开启的配置-目前只有人资查询所以只查中介的类型
        调用管理端接口：cn.com.servyou.operation.manageweb.sdk.service.ModuleEnumSdkService#getModuleEnumSceneList
            传入参数
                condition
                  businessApplications=传入appCode
                  bigRegionCode=传入登陆人所属业务大区
                  scene=default
                  customerType=2（中介机构）
                moduleCode=market-divide
                formCode=null
                available=Y
                defaultFlag=true
    4、将需要查询的员工id设置到每一个配置了的协同类型下        
【公共方法2】获取中介分群下的数据cn.com.servyou.marketing.itcrmweb.business.table.impl.TableBusinessImpl#getAgentTableDataBOByGroup
    1、方法入参：机构管理初始入参（前端传入格式）、客户经理ID列表、组织机构code列表
    2、判断前端是否传入参数groupCode
        如果没有传入则不做逻辑处理
        如果传入则调用数据组接口查询分群下机构cn.com.servyou.datastar.sdk.facade.GroupFacade#listAgentGroupResult
            没查询到数据则直接返回
            如果查询到了数据
                但是数据总数超出了IRIS配置上限（my.customer.group.customer.num）
                    如果入参中只包含了groupCode，清空所有查询条件，将查询页数设置为第一页，将查询到的数据设置进结果中
                    如果入参中还包含了其他参数则抛出错误“该分群数据量超出上限，无法查询”
                如果查询到数据没有超出配置上限时，需要查出全部企业，按照每次查询1000条的逻辑进行查询
                将所有查询到的结果集中的agentId设置到参数institutionIdList中
2. 移动端接口，方法：[cn.com](http://cn.com/).servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
    1. 1、调用公共方法获取销售区域返回
    a、公共方法逻辑见：https://docs.dc.servyou-it.com/pages/viewpage.action?pageId=485362248
    b、传入方法参数：
        前端传入的appCode
        经营中心传null
        登陆人大区
        登陆人网点（登陆人信息中的departmentCode）
        层级查询
            如果前端传入层级
                1、查询指定层级
                2、特殊处理：如果前端传入了部门（departmentCode）并且查询的是大区层级时（大区不包含下级、大区包含下级）时，查询市场划分时要使用部门而非大区
                    要把查询销售区域方法入参的大区参数改为前端传入的部门departmentCode
            如果前端没有传入层级则不传
    c、传入api的参数：permissionAreaSet
2、传入方法isPoolPublic，是否公共池，若为公共池时，查询机构管理需要限定省直单，provinceCityAreaCodeList
    换取省直单：若为大区用户则返回大区对应的所有省直单，若为省直单用户则直接返回所属业务省直单
3、如果无销售区域范围则直接返回空
4、如果传入机构类型statisticsWay=orgInstitution网点的机构
    需要根据传入的orgCode参数，循环查询cn.com.servyou.market.facade.region.QueryRegionSaleAreaFacade#listByDepartCodeList，根据组织机构 code 获取销售区域列表信息，为空直接返回——————获取每个部门对应的销售区域ID列表
    不为空，设置到参数，areaIdSet
5、调用preBuildParam方法整理参数（cn.com.servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#preBuildParam）
    - 设置跟进开始结束时分秒：
        - 如果lastFollowTimeFrom不为空，则追加" 00:00:00"
        - 如果lastFollowTimeTo不为空，则追加" 23:59:59"
    - 客户行政区划code处理：
        - 如果传入areaId，循环去除末尾的"00"，设置region参数
    - 客户经理/协同人员处理：
        - **我的机构 && 查询共享人员场景**：
            - 调用commonBusiness.buildShareSynergyIdList方法构造协同查询参数
            - 将协同查询参数复制到myInstitutionQueryBo中
        - **下属的机构**：
            - 如果传入了orgCode，调用commonBusiness.departEmployeeList获取部门下的员工列表
            - 如果员工列表不为空：
                - 如果查询共享人员场景：调用buildShareSynergyIdList构造协同查询参数
                - 否则：设置permissionCustomerManagerList为员工ID列表
    - 页面筛选客户经理：
        - 如果传入customerManager，设置customerManagerList为包含该customerManager的列表
    - 共享人员-页面筛选协同人员：
        - 如果传入shareSynergyId，调用buildShareSynergyIdList方法构造协同查询参数
    - appCode=大客 -> 只查询机构：
        - 如果appCode是ptcrm，设置queryBO.setAgentType(AgentTypeEnum.AGENCY.getCode())
    - 客户类型设置：
        - 如果传入agentType且不为"all"，设置institutionTypeList为包含该agentType的列表
        - 否则默认设置为中介和个代[1,2]
    - 来源标识：
        - 设置institutionFromFlag为"mobileInstitution"
6、下属的机构额外校验
    - 如果statisticsWay为underInstitution（下属的机构）且employeeUserIds为空，直接返回空列表
 
 
 
 
 
 
************************************************
******* 第二部分：查询
******* cn.com.servyou.marketing.itcrmweb.business.service.impl.MySearchBusinessImpl#queryAgentManageList
************************************************
1、分群逻辑处理
    - 创建GetTableDataBO对象，将queryBO转换为JSONObject作为parameter
    - 如果parameter中包含institutionIdList，则移除（因为分群逻辑会重新设置）
    - 根据statisticsWay确定customerManagerIdList：
        - 如果是"我的机构"：customerManagerIdList = [queryBO.getCustomerManager()]
        - 如果是"下属的机构"：customerManagerIdList = myInstitutionQueryBo.getPermissionCustomerManagerList()
        - 其他情况：customerManagerIdList = null
    - 调用tableBusiness.getAgentTableDataBOByGroup方法获取分群数据
        - 传入参数：getTableDataBO、customerManagerIdList、如果是"网点的机构"则传入orgCode列表
    - 分群结果处理：
        - 如果传入了groupCode但分群查询结果中没有institutionIdList，直接返回空列表
        - 如果传入了groupCode且分群查询结果中有institutionIdList：
            - 从分群结果中获取institutionIdList
            - 如果前端也传入了institutionIdList，则取交集
            - 如果交集为空，直接返回空列表
            - 设置myInstitutionQueryBo.setInstitutionIdList(institutionIdList)
        - 如果没有传入groupCode：
            - 如果前端传入了institutionIdList，直接设置到myInstitutionQueryBo中
 
2、查询API接口（mySearchRpc.listMyInstitutionByDataApi）
    - 调用mySearchRpc.listMyInstitutionByDataApi(myInstitutionQueryBo)查询数据
    - 该方法内部会：
        - 设置available=Y，只查询未注销的机构
        - 构建查询条件和排序条件
        - 调用数据API接口查询
        - 补充竞品信息、客户信息等基础数据
 
3、宽表查询不到数据时的补偿逻辑（compensateData方法）
    - 如果前端传入isCompensateFlag为true，则执行补偿逻辑
    - compensateData方法逻辑：
        - 如果institutionIdList为空，直接返回原结果
        - 收集所有销售区域ID（areaIdSet、permissionAreaSet、areaIdSetTemp）
        - 如果销售区域为空，直接返回原结果
        - 从API查询结果中提取已查询到的机构ID列表
        - 找出需要补偿的机构ID（在institutionIdList中但不在API结果中）
        - 如果不需要补偿，直接返回原结果
        - 查询市场划分信息：marketDivideRegionManager.customerIdAndRegionDivideMap
        - 查询客户信息：operationCustomerManager.mapCustomerIdAndBOInfo
        - 遍历需要补偿的机构ID：
            - 检查市场划分信息中的销售区域是否在权限范围内
            - 如果在权限范围内，创建MyInstitutionResultBo对象并补充基础信息
            - 添加到结果列表中
        - 更新结果总数并返回
 
4、结果校验
    - 如果API查询结果为空，直接返回空列表（total=0）
 
 
 
 
************************************************
******* 第三部分：数据补充
************************************************
 
1、API查询方法中补充数据（MySearchRpc#listMyInstitutionByDataApi内部处理）
    - 1、servyouNumber（区分中介、个代，个代使用servyouNumIndividual，中介使用servyouNumInstitution）
    - 2、实时查询客户中心接口补充机构规模（不做默认值设置，没有就是null）
    - 3、设置疑似合作机构中文suspectedPartner，从管理端获取（模块小二当家、枚举项suspectedPartner、无论是否有效）
    - 4、设置竞品到期月competitorExpireMonthName，从管理端获取（模块小二当家、枚举项competitorExpireMonth、无论是否有效）
    - 5、税局备案taxFilingsFlagName，从管理端获取（模块小二当家、枚举项taxFilingsFlag、无论是否有效）
    - 6、是否有成交订单：orderDealName，判断orderDeal=Y？"有成交":"无成交"
    - 7、跟进结果：followResultName，从管理端获取（模块跟进记录、枚举项followResult、无论是否有效）
    - 8、最后商机阶段：lastChanceStageName，从管理端获取（模块商机、枚举项stageCode、无论是否有效）
    - 9、设置主营mainBusinessTypeName，从管理端获取（模块小二当家、枚举项mainBusinessType、无论是否有效）
    - 10、设置联合经营isJointOperationName，从管理端获取（模块公共、枚举项yesOrNo、无论是否有效）
    - 11、会员类型vipTypeName，从管理端获取（模块小二当家、枚举项vipFlag、无论是否有效）
    - 12、设置推荐地址，如果locationAddressFirstDataSource不为空，用/隔开获取列表补充名称，从管理端获取（模块小二当家、枚举项locationAddressFirstDataSource、无论是否有效）
    - 13、设置目标户标记，如果targetCustomerTypeStatisticsCode不为空，用,隔开获取列表补充名称，从管理端获取（模块小二当家、枚举项targetCustomerTypeStatistics、无论是否有效）
    - 14、设置成立时长establishDuration，如果establishTime不为空时解析补充
    - 15、补充距离参数，如果结果经纬度和查询经纬度不为空则设置距离参数
    - 16、补充竞品信息，如果competitorCodes不为空，,隔开，从管理端获取（模块小二当家、枚举项competitor_code、无论是否有效）
 
 
2、数据补充（buildAgentManage方法，仅在onlyCount=false时执行）
    - **A、基础信息补充（buildAgencyManage方法）**
        - 设置客户经理名称customerManagerName，查询的是员工账户中心的http接口
        - 设置部门名称customerManagerDepartName，缓存获取
        - 设置机构类型（是把新模型类型转换成了老模型）
        - 设置机构类型名称（目前设置的是老模型类型名称）
        - 如果region不为空，则设置regionName，从字典服务中获取，每次都是单个调用
        - 设置lastFollowTimeHMS、lastFollowTime，处理了数据格式，hms是时分秒格式，lastFollowTime是转换为了日期类型
        - 设置未跟进天数：最后一次跟进时间不为空时计算
        - 计算抵扣率deductionRate，需要处理为百分比形式，deductDepositAmount/preDepositAmount
        - 跟进记录相关，补充经营动作、具体事项、跟进结果，管理端获取枚举值（模块跟进记录，枚举项businessAction、followResult、specificItem）
        - 最近一次跟进人不为空lastFollowPersonTrueId，补充名称lastFollowPersonName，查询的是员工账户中心的http接口
        - 补充客户所属网点customerSite，从市场划分实时获取补充，对应参数manageTeamCode
        - 补充大客分层customerStratification、customerStratificationName
            - 取的是API返回的extLayerCode作为customerStratification，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.layer.enum.key）
        - 补充大客行业名称extIndustryName，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.industry.enum.key）
        - 补充大客来源名称extSourceName，名称从管理端获取（模块客户中心，枚举项配置在IRIS的ptcrm.source.enum.key）
        - 补充大客类型majorCustomerTypeName，名称从管理端获取（模块小二当家，枚举项majorCustomerType）
        - 补充所属网点名称customerSiteName，缓存中获取                                                                            ————————————————可以改为直接从市场划分获取
        - 设置合作类型名称cooperationEnTypeName（模块客户中心，枚举项配置在IRIS的cooperationEnType.enum.key）
        - 设置共享人员（协同人员列表）shareSynergy，实时从市场划分获取，cn.com.servyou.market.facade.region.QueryRegionCustomerSynergyDivideFacade#listByCustomerIdList，所有类型的协同数据，协同人员名称是从员工账户中心的http接口补充获取
            - 返回前端以中文分号隔开返回
        - 设置签到人signInPersonName，signInPerson不为空时补充，从员工账户中心的http接口补充获取
        - 设置businessPurposeName签到名称，最后返回以中文逗号隔开返回给前端，businessPurpose不为空时，英文逗号隔开，中文从管理端补充（模块签到管理，枚举项signBusinessPurpose）
        - 设置最后商机阶段名称lastChanceStageName，管理端获取（模块签到管理，枚举项stageCode）
        - 设置最后商机类型名称lastChanceTypeName，管理端获取（模块签到管理，枚举项saleChanceType）
        - 如果是ptcrm（人资大客），补充释放时间相关信息：
            - 获取最近一次客户经理划分日志
            - 补充上一次客户经理ID和名称
            - 补充释放时间
    - **B、补充操作按钮（buildActionBars方法）**
        - 从管理端获取按钮配置，根据客户类型和客户经理权限判断是否显示释放按钮
        - 释放按钮显示条件：客户类型为非会员 && (客户经理为登录人 || 登录人是该客户经理的主管)
    - **C、组装财税代理标签值（buildAgencyKeyTag方法）**
        - 获取IRIS配置agencycrmweb.query.key的枚举项code从管理端获取枚举值，模块小二当家，设置参数tagList
    - **D、补充跟进记录和主要信息（buildFollowRecordAndMainInfo方法）**
        - 补充跟进人名称、创建人名称
        - 补充经营动作、具体事项、跟进结果名称
    - **E、补充划分信息（buildDivideInfo方法）**
        - 补充客户所属网点customerSite和customerSiteName
    - **F、补充签到信息（buildSignInfo方法）**
        - 补充签到人名称signInPersonName
        - 补充业务目的名称businessPurposeName
    - **G、补充商机信息（buildSaleChanceInfo方法）**
        - 补充最后商机阶段名称lastChanceStageName
        - 补充最后商机类型名称lastChanceTypeName











