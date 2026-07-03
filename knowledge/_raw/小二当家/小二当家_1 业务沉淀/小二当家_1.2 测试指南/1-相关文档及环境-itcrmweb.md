每个迭代可直接根据禅道需求链接里的原型地址打开

现在的文档[小二需求文档](/read/book/70/177470)

之前的文档[http://proto.dc.servyou-it.com/UIfiles](http://proto.dc.servyou-it.com/UIfiles)进入小二当家目录

# 开发设计文档

服务端：

[02 小二当家-分析设计](/read/book/70/173461)

前端：

[前端设计（小二当家）](/read/book/70/176547)

# 访问地址及数据库配置

测试：[http://boss-manage-pc.boss-test.sit.91lyd.com/boss-manage-pc/#/login](http://boss-manage-pc.boss-test.sit.91lyd.com/boss-manage-pc/#/login)
release：[http://boss-manage-pc.servyou-release.devops.91lyd.com/boss-manage-pc/#/](http://boss-manage-pc.servyou-release.devops.91lyd.com/boss-manage-pc/#/)
pre: [http://pre-boss.dc.servyou-it.com/boss-manage-pc/#/login](http://pre-boss.dc.servyou-it.com/boss-manage-pc/#/login?redirectUrl=http%3A%2F%2Fpre-boss.dc.servyou-it.com%2Fboss-manage-pc%2F%23%2Fshell%2Fhome-mangement)
正式：[http://boss.dc.servyou-it.com/#/](http://boss.dc.servyou-it.com/#/)




小二当家及运营平台其他后端应用都是以下连接（包括待办、中介、线索等）

测试环境数据库地址：jdbc:[mysql://10.199.139.23:3306/itcrm](mysql://192.168.110.25:3306/spider?useUnicode)web

release环境数据库地址：jdbc:[mysql://10.199.156.145:3306/](mysql://192.168.110.25:3306/spider?useUnicode)[itcrm](mysql://192.168.110.25:3306/spider?useUnicode)[web](mysql://192.168.110.25:3306/spider?useUnicode)

账号：root 

密码：servyou

### 数据组oracle库地址




测试环境：(HOST = 10.199.134.10)(PORT = 1521) 数据库yyptdw user/pwd:yyfx/yyfx

beta环境：与测试环境的地址相同，账密不同 ods\_nbgl2/ods\_nbgl2

### 数据组mysql库地址

#### 1、servyou\_ads

jdbc:[mysql://10.199.156.144:3306/servyou\_ads](mysql://10.199.156.144:3306/servyou_ads)
admin
test\_admin\_123

#### 2、test\_servyou\_ob\_ads

jdbc:[mysql://obtest42.dc.servyou-it.com:3306/test\_servyou\_ob\_ads](mysql://obtest42.dc.servyou-it.com:3306/test_servyou_ob_ads)
test\_servyou\_ob\_ads@yanfa\_test
test\_servyou\_ob\_ads\_123

#### 3、cctest\_not\_delete

10.199.141.67:9030
库：cctest\_not\_delete
root/test\_user\_pass66

#### 4、servyou\_ads

10.199.141.67:9030
库：servyou\_ads
root/test\_user\_pass66

### 数据组hue/impala/hive平台

[http://10.199.151.41:8889/hue/editor/?type=impala](http://10.199.151.41:8889/hue/editor/?type=impala)

![image2023-5-30_17-7-2.png](https://snack.dc.servyou-it.com/snack/257/5003e4f4b7204086bf986632dfa4e0e6.png)




### 商务各数据库地址

[新商务相关应用基础信息表](/read/book/100/103212)

### 数据组观星阁地址

test:[http://datastar-manage-pc.qqt-test.sit.91lyd.com/#/tag/personal](http://datastar-manage-pc.qqt-test.sit.91lyd.com/#/tag/personal)

beta:[http://datastar-manage-pc.servyou-release.devops.91lyd.com/#/tag/enterprise](http://datastar-manage-pc.servyou-release.devops.91lyd.com/#/tag/enterprise)

prod:[https://datastar-manage-pc.dc.servyou-it.com/#/noAuthor](https://datastar-manage-pc.dc.servyou-it.com/#/noAuthor)

### 数据组clickhouse地址-目前用于大客流量

10.199.141.62:8123-选择clickhouse数据库连接，不是mysql
库：default
账密：clickhouse/clickhouse

也可通过datark离线节点执行脚本[http://datark-manage-pc.servyou-release.devops.91lyd.com/#/team/iit\_test/offline/node](http://datark-manage-pc.servyou-release.devops.91lyd.com/#/team/iit_test/offline/node)

![image-2026-2-2_16-23-16.png](https://snack.dc.servyou-it.com/snack/257/3dd6376a35914b8989913fe9792cbfe3.png)














