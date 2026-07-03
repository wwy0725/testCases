## 中小企业一户式

参考：[【PC】中小支持PC端查看某个企业的附近客户](https://chuangtzu.dc.servyou-it.com/AxureDetail?productId=659&branchId=2412&moduleName=2025%E5%B9%B4%E9%9C%80%E6%B1%82%E6%B1%87%E6%80%BB&axurePageCode=msv1kg)

### 入口

1、只支持中小itcrmweb入口

2、展示入口逻辑：有待确认/已确认定位地址的企业，展示“查看附近客户”

3、进入附近客户页面需要前置页面带入appcode参数，需要根据appcode展示对应的配置

- 若无appcode参数，则默认appcode是“小二当家”
- appcode=小二：展示地图
- appcode=财税/政务：本期不支持，直接缺省页提示“暂不支持” — 目前无入口

4、需要前置页面带入参数：客户的定位地址（经纬度）

### 附近客户组件（地图+列表）

参考移动端 [企业附近客户（中小/政务）](/read/book/167/200217) ，基本一致

1、左边地图

- 有放大和缩小的图标

2、右边筛选项和列表

- 搜索地址：
    - 移动端是个“放大镜”的图标，PC端常驻在列表最上方
- 提示数量文案“找到附近N个”后面不展示问号以及提示文案
    - 移动端是根据当前定位的提示文案，pc端不展示
- 列表展示客户信息与移动端一致
    - PC端不展示导航入口

![image-2025-10-17_14-17-43.png](https://snack.dc.servyou-it.com/snack/257/8fb350d585a944759f19e6b8d7da11dc.png)