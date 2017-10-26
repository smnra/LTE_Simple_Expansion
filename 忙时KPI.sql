
select tab1.sdate,tab1.PDCP_thp/*,tab2.UE_AVG,tab2.UE_MAX*/,tab1.num_row,tab1.city, 
count(distinct tab2.lnbts_id) as lnbts_count,
count(distinct tab2.lncel_id) as lncel_count
from (select * from (
select t.*,
row_number() over(partition by t.city order by t.PDCP_thp desc) as num_row
from (
select 
    to_char(luest.period_start_time,'yyyymmddHH24') as sdate,
    c.city as city,
    sum(luest.PDCP_SDU_VOL_DL)/1024 as PDCP_thp
from 
    NOKLTE_P_LUESD_LNCEL_HOUR luest,
    c_lte_custom c 
where 
    luest.LNCEL_ID = c.lncel_objid 
    AND luest.period_start_time >= to_date(&start_time,'yyyymmddHH24')
    AND luest.period_start_time <  to_date(&end_time,'yyyymmddHH24')
group by 
      c.city,
      to_char(luest.period_start_time,'yyyymmddHH24')
      
order by 
c.city) t
) 
where  num_row=1
)tab1,
(
select 
    to_char(LCELLD.period_start_time,'yyyymmddHH24') as sdate,
    c.city as city,
    LCELLD.lnbts_id as lnbts_id,
    LCELLD.lncel_id as lncel_id,
    LCELLD.RRC_CONN_UE_AVG as UE_AVG,
    LCELLD.RRC_CONN_UE_MAX as UE_MAX
from 
    NOKLTE_PS_LCELLD_LNCEL_HOUR LCELLD,
    c_lte_custom c 
where 
    LCELLD.LNCEL_ID = c.lncel_objid 
    AND LCELLD.period_start_time >= to_date(&start_time,'yyyymmddHH24')
    AND LCELLD.period_start_time <  to_date(&end_time,'yyyymmddHH24')
group by 
      c.city,
      to_char(LCELLD.period_start_time,'yyyymmddHH24'),
      LCELLD.lnbts_id,
      LCELLD.lncel_id,
      LCELLD.RRC_CONN_UE_AVG,
      LCELLD.RRC_CONN_UE_MAX
      
order by 
c.city
) tab2
where tab1.sdate=tab2.sdate and tab2.city=tab1.city
and tab2.UE_MAX>40

group by tab1.sdate,tab1.PDCP_thp/*,tab2.UE_AVG,tab2.UE_MAX*/,tab1.num_row,tab1.city--,
 /*tab2.lnbts_id,
tab2.lncel_id*/
