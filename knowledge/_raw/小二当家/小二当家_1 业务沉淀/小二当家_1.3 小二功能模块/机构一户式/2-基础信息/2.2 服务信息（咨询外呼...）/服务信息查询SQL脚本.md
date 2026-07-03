测试库，数据库连接类型：Oracle

```sql
--连接信息
#kfpt_测试库 user/pwd: [kfpt/kfpt schema:kfpt]
TEST_KFPT_138.6 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.199.138.6)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = kfpt)
   (SERVER = DEDICATED)
    )
  )
```

```sql
--查询远程详情数据
select
            jlid,
            rwbh,
            khjlid,
            khid,
            lxsj,
            yhmc,
            to_char(JDSJ, 'yyyy-mm-dd hh24:mi:ss') jdsj
        from
            khjl_yc t  
        where
            lxsj = '13632211382'
			-- lxsj：根据手机号查询，根据客户/机构查询替换查询字段：khid = 'b0d507dec28f4fcf859124727eb77e50'/yhdm = '3QBW4QWW'
            and JDSJ < SYSDATE
            AND JDSJ > = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM')||'-01','YYYY-MM-DD'),-11) 
            order by t.jdsj desc ;
      SELECT t.*,t.rowid from khjl_yc t where t.lxsj = '13212340001';
      
0 单位客户 1 中介 2 个人代理 造中介的远程或上门记录时：khid=yhdm
 
        
--查询上门数据-根据手机号查询
select
            JLID,
            KHID,
            YHMC,
            RWBH,
            to_char(JDSJ, 'yyyy-mm-dd hh24:mi:ss') jdsj,
            lxsj,
            KHJLID
        from
            KHJL_BD_SMDJBXX t 
        where
            lxsj = '13632211382'
            and JDSJ < SYSDATE
            AND JDSJ > = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM')||'-01','YYYY-MM-DD'),-11)
            order by t.jdsj desc for update ;

            
--查询外呼和回电数据-根据手机号查询
select
            ZXXH,
            RWBH,
            KHID,
            QYMC,
            ZXZID,
            WHQKJL,
            zx.hccgdhhm,
            sj,
            HWSJ
        from
            RWGL_ZXQK zx
        where
          zx.hccgdhhm = '13212340001'
           and hwsj < SYSDATE
            and hwsj > = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM')||'-01','YYYY-MM-DD'),-21)
            and exists(select 1 from rwgl_task t where t.rwbh = zx.rwbh
                        and t.whlx =0
                ) for update
               ;
 SELECT t.*,t.rowid from RWGL_ZXQK t where t.sj ='13212340002';

0 单位客户 1 中介 2 个人代理 造中介的外呼记录时：khid=yhdm
               
                
--查询咨询数据-根据手机号查询
select
            zxbh,
            bm,
            zxsj,
            wbzid,
            zjhm,
            jrhm,
            bjhm,
            qzhm,
            qysh,
            qymc,
            lxr,
            zxnr,
            zxhf,
            zxkssj,
            zjhm,
            khid
          from
            cc_zxjl t 
         where
            t.zjhm = '13212340006'
            and 
            zxkssj < SYSDATE
            AND zxkssj > = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYY-MM')||'-01','YYYY-MM-DD'),-11)
            order by t.zxkssj desc for update ;
      SELECT t.*,t.rowid from cc_zxjl t where t.zjhm = '13632211382';
```