select 
    c.city,
    c.lnbtsid,
    c.lncel_lcr_id
    
from 
    (select
        *
    from
        (select 
            lcellt.lncel_id,
            --to_char(lcellt.period_start_time,'D') as we,
            max(decode(to_char(lcellt.period_start_time,'D'),'1', 1,NULL)) as  we_1, 
            max(decode(to_char(lcellt.period_start_time,'D'),'2', 1,NULL)) as  we_2, 
            max(decode(to_char(lcellt.period_start_time,'D'),'3', 1,NULL)) as  we_3, 
            max(decode(to_char(lcellt.period_start_time,'D'),'4', 1,NULL)) as  we_4, 
            max(decode(to_char(lcellt.period_start_time,'D'),'5', 1,NULL)) as  we_5, 
            max(decode(to_char(lcellt.period_start_time,'D'),'6', 1,NULL)) as  we_6, 
            max(decode(to_char(lcellt.period_start_time,'D'),'7', 1,NULL)) as  we_7
          
        from
            (                      
                select 
                    lcellt.lncel_id,
                    to_date(to_char(lcellt.period_start_time,'yyyymmdd'),'yyyymmdd') as period_start_time,
                    SUM(lcellt.PDCP_SDU_VOL_DL + lcellt.PDCP_SDU_VOL_UL)/1024/1024/1024 AS 空口业务字节数

                from
                    NOKLTE_PS_LCELLT_LNCEL_DAY lcellt
                    
                where
                        lcellt.period_start_time >= to_date(&start_time,'yyyymmdd')
                    AND lcellt.period_start_time <  to_date(&end_time,'yyyymmdd')
                    and (lcellt.PDCP_SDU_VOL_DL + lcellt.PDCP_SDU_VOL_UL) is not null 
            
                group by 
                    lcellt.lncel_id,
                    to_date(to_char(lcellt.period_start_time,'yyyymmdd'),'yyyymmdd')
            
                having
                    SUM(lcellt.PDCP_SDU_VOL_DL + lcellt.PDCP_SDU_VOL_UL)/1024/1024/1024 > 7
            
            ) lcellt

        where
                lcellt.period_start_time >= to_date(&start_time,'yyyymmdd')
            AND lcellt.period_start_time <  to_date(&end_time,'yyyymmdd')


        group by
            lcellt.lncel_id
            
        )    
        
        
        
    where 
        (we_2 + we_3 + we_4 + we_5 + we_6 >= 4 and (we_3 is not null and we_4 is not null and we_5 is not null)  ) or (we_7 +  we_1) =2 
        
      )  tab
        
     
    inner join c_lte_custom c on c.lncel_objid = tab.lncel_id



  