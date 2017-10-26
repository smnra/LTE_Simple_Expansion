select 
    c.city,
    c.lnbtsid,
    c.lncel_lcr_id
    
    
from 
    (select
        *
    from
        (select 
            lcellr.lncel_id,
            --to_char(lcellr.period_start_time,'D') as we,
            
            max(decode(to_char(lcellr.period_start_time,'D'),'1', 1,NULL)) as  we_1, 
            max(decode(to_char(lcellr.period_start_time,'D'),'2', 1,NULL)) as  we_2, 
            max(decode(to_char(lcellr.period_start_time,'D'),'3', 1,NULL)) as  we_3, 
            max(decode(to_char(lcellr.period_start_time,'D'),'4', 1,NULL)) as  we_4, 
            max(decode(to_char(lcellr.period_start_time,'D'),'5', 1,NULL)) as  we_5, 
            max(decode(to_char(lcellr.period_start_time,'D'),'6', 1,NULL)) as  we_6, 
            max(decode(to_char(lcellr.period_start_time,'D'),'7', 1,NULL)) as  we_7
          
        from
            (                      
                select 
                    lcellr.lncel_id,
                    to_date(to_char(lcellr.period_start_time,'yyyymmdd'),'yyyymmdd') as period_start_time,
                    round(avg(DL_PRB_UTIL_TTI_MEAN),2) AS 下行PRB平均利用率

                from
                    NOKLTE_PS_LCELLR_LNCEL_DAY lcellr
                    RIGHT JOIN c_lte_lncel lncel ON lncel.obj_gid = lcellr.lncel_id 
                    
                where
                        lcellr.period_start_time >= to_date(&start_time,'yyyymmdd')
                    AND lcellr.period_start_time <  to_date(&end_time,'yyyymmdd')

                group by 
                    lcellr.lncel_id,
                    to_date(to_char(lcellr.period_start_time,'yyyymmdd'),'yyyymmdd')

                having
                     avg(DL_PRB_UTIL_TTI_MEAN) > 50
            
            ) lcellr

        where
                lcellr.period_start_time >= to_date(&start_time,'yyyymmdd')
            AND lcellr.period_start_time <  to_date(&end_time,'yyyymmdd')
            and  lcellr.下行PRB平均利用率 is not null

        group by
            lcellr.lncel_id
            
        )    
        
        
        
    where 
        (we_2 + we_3 + we_4 + we_5 + we_6 >= 4 and (we_3 is not null and we_4 is not null and we_5 is not null)  ) or (we_7 +  we_1) =2 
        
      )  tab
        
     
    inner join c_lte_custom c on c.lncel_objid = tab.lncel_id



  