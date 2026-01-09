-- Understanding Delivery Partner Strikes at Blinkit (Hypothetical Case Study)

-- we have assume  hypothesis accross diffrent angles such as low pay, store issue, complains, etc
-- this will help us find the root cause of the problem.

-- Partners who earn less per km and travel longer distances are more likely to get complaints and leave the company.

select * from orders;
select * from partners;

-- Average earning per km

select round(avg(earning_per_km),2) as avg_earning_per_km,
	round(min(earning_per_km),2) as min_earning_per_km,
    round(max(earning_per_km),2) as max_earning_per_km
from orders;


-- Complaints by earning level

select
	case
		when earning_per_km < 8 then 'low earning'
        when earning_per_km between 8 and 15 then 'medium earning'
        when earning_per_km between 12 and 20 then 'high earning' 
        else 'higher earning group'
	end as earning_group,
    count(*) as total_orders,
    sum(case when complaint_raised = 'Yes' then 1 else 0 end) as complaints,
    round(sum(case when complaint_raised = 'Yes' then 1 else 0 end) * 100 / count(*),2) as complaint_rate_pct
from orders
group by earning_group
order by complaint_rate_pct desc;

-- this shows high earning group have high complaint rate


-- Does long distance reduce earnings per km?

select case
		when total_distance_km < 2 then 'short distance'
        when total_distance_km between 2 and 8 then 'medium distance'
        when total_distance_km between 8 and 10 then 'long distance'
        else 'longer distance'
	end as distance_group,
    count(*) as total_orders,
    round(avg(earning_per_km),2) as avg_earning_per_km
from orders
group by distance_group
order by avg_earning_per_km;


select avg(total_distance_km) as avg_distance,
	min(total_distance_km) as min_distance,
    max(total_distance_km) as max_distance
from orders;

select case
         when total_distance_km < 2 then 'short distance'
         when total_distance_km between 2 and 8 then 'medium distance'
         when total_distance_km between 8 and 10 then 'long distance'
         else 'longer distance'
       end as distance_group,
       city,
       count(*) as total_orders
from orders
group by distance_group, city
having distance_group in ('longer distance' , 'long distance')
order by total_orders desc;


-- the above query shows that the longer orders are more and pay per km are much less than short distance.
-- also the delhi and mumbai location is having more longer distance issue (as the strike also happpenig among those area partner)



-- now Are Low Earners More Likely to Churn?

select 
	p.churned, 
    round(avg(o.earning_per_km),2) as avg_earning_per_km,
    count(*) as total_orders
from orders o
join partners p on o.partner_id = p.partner_id
group by p.churned;


select count(*) as total_partner, 
	(sum(case when churned = 'Yes' then 1 else 0 end) / count(*)) *100 as churn_pct
from partners;

select * from orders;

select complaint_reason, count(*) as total_count, count(*) *100 / (select count(*) from orders) as pct
from orders
group by complaint_reason;

SELECT 
    delay_reason,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE delay_time > 0), 2) AS pct_of_delays
FROM orders
WHERE delay_time > 0
GROUP BY delay_reason
ORDER BY total_orders DESC;

SELECT 
    CASE 
        WHEN delay_time <= 0 THEN 'On Time'
        WHEN delay_time BETWEEN 1 AND 10 THEN 'Small Delay'
        WHEN delay_time BETWEEN 11 AND 25 THEN 'Medium Delay'
        ELSE 'High Delay'
    END AS delay_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(late_penalty), 2) AS avg_penalty
FROM orders
GROUP BY delay_group
ORDER BY avg_penalty DESC;


-- Question: Are partners in some areas doing more distance for less value?

SELECT 
    city,
    ROUND(AVG(total_distance_km), 2) AS avg_distance,
    ROUND(AVG(final_earning), 2) AS avg_earning,
    ROUND(AVG(earning_per_km), 2) AS avg_earning_per_km,
    COUNT(*) AS total_orders
FROM orders
GROUP BY city
ORDER BY avg_distance DESC;


-- Question: Are a few stores creating most of the distance, delays, or complaints?

SELECT 
    store_id, city,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_distance_km), 2) AS avg_distance,
    ROUND(AVG(delay_time), 2) AS avg_delay,
    SUM(CASE WHEN complaint_raised = 'YES' THEN 1 ELSE 0 END) AS total_complaints
FROM orders
GROUP BY store_id,city
ORDER BY avg_distance DESC, avg_delay desc
LIMIT 15;

SELECT 
    p.churned,
    ROUND(AVG(o.total_distance_km), 2) AS avg_distance,
    ROUND(AVG(o.delay_time), 2) AS avg_delay,
    ROUND(AVG(o.final_earning), 2) AS avg_earning,
    ROUND(AVG(o.late_penalty), 2) AS avg_penalty,
    SUM(CASE WHEN o.complaint_raised = 'YES' THEN 1 ELSE 0 END) AS total_complaints
FROM orders o
JOIN partners p ON o.partner_id = p.partner_id
GROUP BY p.churned;



