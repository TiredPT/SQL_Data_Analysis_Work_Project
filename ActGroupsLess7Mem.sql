-- Finds active groups with fewer than 7 members

with ActiveGroups as (
    select g.id as groupId,
           g.name as name,
           CONCAT(gt.nickname, '-', g.groupTypeCount) as groupNickname,
           g.startDate as start,
           g.endDate as end,
           g.isPopUp as isPopUp,
           count(distinct(gm.id)) as numMembers

    from paceprod.Groups g
        join paceprod.GroupTypes gt on g.groupTypeId = gt.id
        join paceprod.GroupMembers gm on g.id = gm.groupId and
            (
                gm.startDate is not null and
                gm.startDate < NOW()
            ) and
            (
                gm.endDate is null or
                gm.endDate > NOW()
            ) and
            gm.isFacilitator is not true
    where
        (
            g.startDate is not null and
            g.startDate < NOW()
        ) and
        (
            g.endDate is null or
            g.endDate > NOW()
        ) and
        g.isInternal is not true and
        g.skipInMetrics != 1 and
        g.isPopUp != 1 AND
        g.groupTypeId != 'a54e3abf-69be-4115-bfe5-dd04fdc7d049' AND
        g.groupTypeId != 'd8ef8e02-e666-47b1-ba5b-55b2d02b66d5' AND
        g.id != 'd67de29b-1dad-4a44-971b-2831ea49f47b' AND
        g.id != 'b8e98060-85ad-46bc-b546-4369351db09b' AND
        g.id != '6f711176-4ff1-4100-a3e3-14271a229b31'

    group by gm.groupId
    order by groupNickname

)

select ag.groupNickname,
       ag.numMembers,
       DATE(ag.start) as start,
       DATE(ag.end) as end,
       ag.groupId,
       ag.isPopUp
from ActiveGroups ag
where ag.numMembers < 7
group by ag.groupNickname
order by ag.groupNickname;