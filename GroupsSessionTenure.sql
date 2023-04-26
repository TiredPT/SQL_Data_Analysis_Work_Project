-- Finds the groups and respective session tenure
--	Groups @ L1 (first session)
--	Groups @ L2 - L12 (2nd and 12th session)
--	Groups @ L13+ (13th up sessions) 


WITH GroupSessions as (
    
    select 
        s.groupId as groupId,
        CASE 
             WHEN ROW_NUMBER() OVER(PARTITION BY g.id ORDER BY s.date ASC) = 1 THEN "L1"
             WHEN ROW_NUMBER() OVER(PARTITION BY g.id ORDER BY s.date ASC) between 2 and 13 THEN "L2-L12"
             ELSE "L13+"
             END as tenure,

        CONCAT('https://pace.group/admin/group/',g.id) as groupLink,
        g.name as groupName,
        DATE(s.date) as sessionDate,
        s.start as sessionStartTime,
        ROW_NUMBER() OVER(PARTITION BY g.id ORDER BY s.date ASC) AS nthGroupSession,
        DATE_SUB(DATE(s.date), INTERVAL DAYOFWEEK(s.date)-1 DAY) as weekCohort

    from paceprod.Sessions s
    join paceprod.Groups g on g.id = s.groupId 

    where
        s.start <= NOW() and 
        g.startDate IS NOT NULL and   
        s.isPopUp = 0 and 
        g.isInternal is not true and 
        g.skipInMetrics != 1 and 
        g.groupTypeId != 'a54e3abf-69be-4115-bfe5-dd04fdc7d049' and 
        g.groupTypeId != 'd8ef8e02-e666-47b1-ba5b-55b2d02b66d5' and
        g.id != 'd67de29b-1dad-4a44-971b-2831ea49f47b' and
        g.id != 'b8e98060-85ad-46bc-b546-4369351db09b' and
        g.id != '6f711176-4ff1-4100-a3e3-14271a229b31' and 
        g.id != '8a184429-eb42-48b4-a3ea-1c7658524aa5' and 
        g.id != '22531d56-d5f7-4a27-8fae-cf79e07941b7'

    group by   
        s.id 

    order by 
        s.date desc  
    
)

select
   gs.weekCohort as 'Week Cohort',
   SUM(case when gs.Tenure = "L1" then 1 else 0 end) as "L1",
   SUM(case when gs.Tenure = "L2-L12" then 1 else 0 end) as "L2-L12",
   SUM(case when gs.Tenure = "L13+" then 1 else 0 end) as "L13+",
   COUNT(gs.Tenure) as "Weekly Total"

from 
    GroupSessions gs 
group by
    gs.weekCohort
 
order by 
    gs.weekCohort desc 

LIMIT 12 