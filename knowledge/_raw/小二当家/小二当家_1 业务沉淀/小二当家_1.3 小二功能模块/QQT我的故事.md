查询范围：当前登录者有权限的故事

按数据在接口返回的空间展示对应的页签和目录，目录下报表不存在，则不展示

- 调用获取空间和目录接口/datastar/getMyStorySpaceAndCatalogList
- 所有目录下的报表默认最多只查8个，点击更多，可分页获取更多报表

我的收藏页签，存在收藏的故事即展示，不分组

调用查询用户收藏的表 /datastar/getMyFavouriteStoryList

故事明细查询字段均取自QQT

- 调用接口：查询报表明细列表 /datastar/getMyStoryList
- 展示：缩略图，创建人，报表名称，创建时间等

支持按故事名称搜索

- 搜索后点击故事，自动定位到对应的空间和目录下
- 搜索的故事自动展示在对应目录下第一个，边框标识

点击对应的故事，可抽屉打开QQT故事详情

造数：wmg/123，zwz/123，xxbyw\_hb/123，xqy\_admin/123任一账号登录[http://bi-ep-management.qqt-test.sit.91lyd.com/#/story](http://bi-ep-management.qqt-test.sit.91lyd.com/#/story)，选择故事分享给测试用的账号，也可以直接用以上账号测试

线上环境由数据组开发或测试分享故事给测试账号验证