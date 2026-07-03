1. 右上角查询
    1. /publicPool/customer/list/search
2. 列表查询：
    1. 接口：publicPool/customer/list/query
3. 筛选项
    1. 


会员状态下拉枚举：全部、非会员、逾期会员、会员。前端取到枚举值后，拼接【全部】。默认【全部】数据查询：匹配  ads\_itcrm\_institution\_other\_info\_new.vip\_type中介专员14财代获取员工指定数据权限下员工信息以及是否占上限/common/employeeListGroupByOrg返回：【权限范围内 当前业务大区下的客户经理】和登录人

4.  列表字段
    1. 


会员状态








5. 操作项
    1. 转公共池：02-责任户释放接口/customerManage/release
    2. 分配：有【公共池分配按钮权限customer\_manager\_allot】，展示分配按钮；分配接口：/agency/manage/distribute，场景：分配
    3. 分配时获取客户经理和占上限数据
        1. [14财代获取员工指定数据权限下员工信息以及是否占上限](/read/book/70/174996) /common/employeeListGroupByOrg
        2. 返回权限范围内本大区的客户经理+登录人自己，及非客户占上线的数量。占上限统计逻辑[6.4 占上限统计](/read/book/167/200210)


