--Pull total_tasks by date and user_id (account_id not necessary - multiple lines per user_id, but account_id does not impact total_tasks)
SELECT date,user_id,SUM(sum_tASks_used) AS total_tASks
INTO jmcelhenny.tASks_used_da
FROM source_data.tASks_used_da
GROUP BY date,user_id;

COMMIT;

--Determine approrpiate length of active period based on first of next active period/active period plus 28 days
--Determine whether a churn period occurs based on whether next active date extends beyond active period
--Determine churn start and end period based on END of last active period and beginning of next active period

SELECT *
              ,CASE 
                    WHEN churn_exists=1 THEN date+29
                    ELSE null
               END AS churn_start
               ,CASE
                    WHEN churn_exists=1 AND date+57 < NVL(lead(date,1) over (partition by user_id order by date),date+58) THEN date+57
                    WHEN churn_exists=1 THEN lead(date,1) over (partition by user_id order by date)-1
                    ELSE null
                END AS END_churn_period
INTO jmcelhenny.user_id_timeline
FROM (SELECT *       ,CASE 
                    WHEN date+28 < lead(date,1) over (partition by user_id order by date)-1 OR lead(date,1) over (partition by user_id order by date) is null THEN date+28
                    ELSE lead(date,1) over (partition by user_id order by date)-1
               END AS END_active_period
              ,CASE 
                    WHEN date+28 < lead(date,1) over (partition by user_id order by date)-1 OR lead(date,1) over (partition by user_id order by date) is null THEN 1
                    ELSE 0
               END AS churn_exists    
FROM jmcelhenny.tasks_used_da
ORDER BY user_id,date) t;

COMMIT;

--Organize data by user_id, period type (active or churn), and period length
SELECT user_id,date AS start_period, END_active_period AS END_period,'Active' AS period_type
INTO jmcelhenny.user_log
FROM jmcelhenny.user_id_timeline
UNION
SELECT user_id,churn_start AS start_period, END_churn_period AS END_period,'Churn' AS period_type
FROM jmcelhenny.user_id_timeline
WHERE churn_exists=1;

COMMIT;

--Determine when customer is new based on first active date, and cohort (by month) based on first active date
SELECT t.*,date_part(month,start_date) AS cohort
INTO #temp
FROM (SELECT user_id,min(date) AS start_date
FROM jmcelhenny.tASks_used_da
GROUP BY user_id) t;

SELECT l.*,t.start_date,t.cohort
INTO jmcelhenny.user_log_daily_final
FROM jmcelhenny.user_log l
LEFT JOIN #temp t
ON l.user_id = t.user_id;

DROP TABLE jmcelhenny.user_log;

COMMIT;

--Pull time period for reporting
SELECT DISTINCT t.date
INTO jmcelhenny.time_period
FROM jmcelhenny.tASks_used_da t;

COMMIT;


--Perform similar analysis by month
--user_id contributes to churn if they ended the month as churned
--For each user_id, determine status on last day of the month
SELECT *
INTO jmcelhenny.user_log_monthly_final
FROM jmcelhenny.user_log_daily_final l
INNER JOIN (SELECT max(date) as last_day_of_month
FROM jmcelhenny.tasks_used_da
GROUP BY date_part(month,date)
ORDER BY date_part(month,date)) d
ON l.start_period <= d.last_day_of_month
AND l.end_period >= d.last_day_of_month;

COMMIT;
