-- Finds all members placed in new groups the last 12 wks


WITH PlacedMembers AS (

select 
    g.id as groupId,
    gm.id as group_member_id,
    g.name as groupName,
    CONCAT(u.firstName, " ",u.lastName) as memberName,
    g.startDate as startDate,
    gm.startDate as memberStartDate,
    #COUNT(DISTINCT gm.id) as totalPlaced,
    DATE_SUB(DATE(gm.startDate), INTERVAL DAYOFWEEK(gm.startDate)-1 DAY) as weekCohort

from paceprod.Groups g 
join paceprod.GroupMembers gm on gm.groupId = g.id
left join paceprod.Users u on u.id = gm.userId
where
    -- we don't want internal groups
    g.isInternal is not true and 
    g.skipInMetrics != 1 and 
    g.groupTypeId != 'a54e3abf-69be-4115-bfe5-dd04fdc7d049' and 
    g.groupTypeId != 'd8ef8e02-e666-47b1-ba5b-55b2d02b66d5' and
    g.groupTypeId != '59d5603c-f112-4687-8cb9-516467c91ae5' and 
    g.id != 'd67de29b-1dad-4a44-971b-2831ea49f47b' and
    g.id != 'b8e98060-85ad-46bc-b546-4369351db09b' and
    g.id != '6f711176-4ff1-4100-a3e3-14271a229b31' and 
    g.id != '8a184429-eb42-48b4-a3ea-1c7658524aa5' and 
    g.id != '22531d56-d5f7-4a27-8fae-cf79e07941b7' and 

    -- we don't want facilitators
    gm.isFacilitator IS NOT TRUE  


-- we want those placed prior to group start (new groups)
having gm.startDate <= g.startDate+INTERVAL 1 HOUR -- interval to make up for UTC/PST time differences if member was added the day of session (or readded)

order by
    g.startDate desc 
)

select 
    pm.weekCohort as "Week",
    COUNT(DISTINCT pm.group_member_id) as "Total Placed in NG"

from PlacedMembers pm 

group by 
    pm.weekCohort 

order by 
    pm.weekCohort desc 

LIMIT 12