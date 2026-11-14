create database project;
use project;
set sql_safe_updates=0;
show tables;
desc additional_fields;
Alter table additional_fields rename column ï»¿Agent_ID to Agent_ID;
desc claims;
alter table claims rename column ï»¿Claim_ID to Claim_ID;
desc policy_details;
Alter table policy_details rename column ï»¿Policy_ID to Policy_ID;
desc customer_information;
Alter table customer_information rename column ï»¿Customer_ID to Customer_ID;
desc customer_information;
desc policy_details;
select * from policy_details;
Alter table policy_details modify Policy_Start_Date date;
Update policy_details set policy_start_Date = str_to_date(policy_start_date, '%d-%m-%Y'), policy_end_date = str_to_date(policy_end_date, '%d-%m-%Y');
select * from payment_history;
update payment_history set Date_of_Payment = str_to_date(Date_of_Payment, '%d-%m-%Y');
select * from customer_information;
select * from claims;
update claims set Date_of_Claim = str_to_date(Date_of_Claim, '%d-%m-%Y');
update claims set Settlement_Date = str_to_date(Settlement_Date, '%d-%m-%Y') where settlement_date is not null and Settlement_Date != "";
desc claims;
select * from additional_fields;
describe additional_fields;
select * from claims;
desc claims;
update claims set settlement_date = null where settlement_date = "";
Alter table claims modify date_of_claim date , modify settlement_date date;
select * from customer_information;
desc customer_information;
select * from payment_history;
desc payment_history;
alter table payment_history rename column ï»¿Payment_ID to Payment_ID;
alter table payment_history modify date_of_payment date;
select * from policy_details;
desc policy_details;
alter table policy_details modify policy_start_date date, modify policy_end_date date;

/* Q1. What is the total number of customers available in the policy database? */
select * from policy_details;
select count(customer_ID) from Policy_details;

/* Q2. What is the total number of policies issued? */
select * from policy_details;
select count(distinct policy_ID) from policy_details;

/* Q3. What is the total claim amount generated from all policies? */
select * from claims;
select sum(claim_amount) from claims;

/* Q4. What is the average coverage amount per policy? */
select * from policy_details;
select avg(coverage_amount) from policy_details;

/* Q6. What is the average premium amount collected per policy? */
Select avg(Premium_Amount) from policy_details;

/* Q7 What percentage of policies are currently active? */
select * from policy_details;
select round((sum(status = "Active")/count(status))*100,2) as "Active %" from policy_details;

/* Q8. How many policies are in active, lapsed, and terminated status? */
Select * from policy_details;
select sum(status = "Active") as Active, sum(status = "Lapsed") as Lapsed, sum(status = "Terminated") as "Terminated" from policy_details;
select status,count(*) 'Policy Count' from policy_details  group by status;

/* Q9. Which policy status has the highest number of policies?  */

select status , count(*) policy_count from policy_details  group by status order by policy_count desc limit 1;

/* Q10 What is the ratio between active policies and inactive policies?  */

Select sum(status ='Active') Active_Policies, sum(status <> 'Active') Inactive_Policies ,
 (sum(status='Active')/sum(status <> 'Active')) 'Ratio Between Active And Inactive Policies' from policy_details;
 
with Policies as (select sum(status='Active') Active_Policy , sum(status <> 'Active') Inactive_Policy from policy_details)
	select (Active_Policy/Inactive_Policy) 'Ratio Between Active and Inactive Policy' from policies;
    
/* Q11 Which age group has the highest number of policies?  */

Select * from customer_information;
select * from policy_details;
select case
			when c.age between 18 and 27 then '18-27'
            when c.age between 28 and 37 then '28-37'
            when c.age between 38 and 47 then '38-47'
            when c.age between 48 and 57 then '48-57'
            when c.age between 58 and 67 then '58-67'
            when c.age between 68 and 77 then '68-77'
            else '78-87' end as Age_Group,
            count(*) policy_count from customer_information c 
            left join policy_details p
            on p.customer_ID = c.customer_ID
            group by age_group order by policy_count desc limit 1;
            
/* Q12.  Identify the top three age groups by policy count */

select case
			when c.age between 18 and 27 then '18-27'
            when c.age between 28 and 37 then '28-37'
            when c.age between 38 and 47 then '38-47'
            when c.age between 48 and 57 then '48-57'
            when c.age between 58 and 67 then '58-67'
            when c.age between 68 and 77 then '68-77'
            else '78-87' end as Age_Group,
            count(*) policy_count from customer_information c 
            left join policy_details p
            on p.customer_ID = c.customer_ID
            group by age_group order by policy_count desc limit 3;
            
/* Q13. Which gender has the highest policy participation?  */
select * from customer_information;
select Gender, count(*) Policy from customer_information group by Gender order by Policy desc limit 1;

/* Q14 What is the difference between male and female policy counts? */ 
With Gender_diff as (select sum(gender = 'Male') Male , sum(gender = 'Female') Female from customer_information)
 select Male,Female,(Male-Female) 'Difference Btween Male and Female Policy Counts' from gender_diff;
 
/* Q15. Which policy type has the maximum number of policies?  */
Select Policy_type,count(*) Policy_count from Policy_details group by Policy_type order by policy_count desc limit 1;


/*  Q16. Which policy type has the minimum number of policies? */
Select Policy_type,count(*) Policy_count from Policy_details group by Policy_type order by policy_count asc limit 1;

/* Q17 Compare Auto and Health policy counts. */
select sum(policy_type = 'Health') Health,sum(policy_type='Auto') Auto ,
	( sum(policy_type = 'Health') - sum(policy_type='Auto')) 'Compare Auto and Health Policy Counts' from policy_details;

/* Q18. What is the total number of policies across all policy types?  */
 Select  count(policy_type) from policy_details;
 
 
 -- KPI 19
-- What is the average premium growth rate over all years?
-- ============================================================
WITH yearly_premium AS (
    SELECT
        YEAR(policy_start_date) AS policy_year,
        SUM(premium_amount) AS total_premium
    FROM policy_details
    GROUP BY YEAR(policy_start_date)
),
growth_rates AS (
    SELECT
        policy_year,
        total_premium,
        LAG(total_premium) OVER (ORDER BY policy_year) AS previous_premium
    FROM yearly_premium
)
SELECT
    ROUND(
        AVG(
            ((total_premium - previous_premium) / previous_premium) * 100
        ), 2
    ) AS average_premium_growth_rate
FROM growth_rates
WHERE previous_premium IS NOT NULL
  AND previous_premium <> 0;


-- ============================================================
-- KPI 20
-- Is the premium growth trend increasing or decreasing over time?
-- ============================================================
WITH yearly_premium AS (
    SELECT
        YEAR(policy_start_date) AS policy_year,
        SUM(premium_amount) AS total_premium
    FROM policy_details
    GROUP BY YEAR(policy_start_date)
),
growth_rates AS (
    SELECT
        policy_year,
        total_premium,
        LAG(total_premium) OVER (ORDER BY policy_year) AS previous_premium
    FROM yearly_premium
)
SELECT
    policy_year,
    ROUND(
        ((total_premium - previous_premium) / previous_premium) * 100,
        2
    ) AS premium_growth_rate
FROM growth_rates
WHERE previous_premium IS NOT NULL
  AND previous_premium <> 0
ORDER BY policy_year;


-- ============================================================
-- KPI 21
-- Difference between highest and lowest premium growth rates.
-- ============================================================
WITH yearly_premium AS (
    SELECT
        YEAR(policy_start_date) AS policy_year,
        SUM(premium_amount) AS total_premium
    FROM policy_details
    GROUP BY YEAR(policy_start_date)
),
growth_rates AS (
    SELECT
        policy_year,
        ((total_premium - previous_premium) / previous_premium) * 100
            AS growth_rate
    FROM (
        SELECT
            policy_year,
            total_premium,
            LAG(total_premium) OVER (ORDER BY policy_year) AS previous_premium
        FROM yearly_premium
    ) x
    WHERE previous_premium IS NOT NULL
      AND previous_premium <> 0
)
SELECT
    ROUND(MAX(growth_rate), 2) AS highest_growth_rate,
    ROUND(MIN(growth_rate), 2) AS lowest_growth_rate,
    ROUND(MAX(growth_rate) - MIN(growth_rate), 2)
        AS difference_highest_lowest
FROM growth_rates;


 
 
 
 /* Q22. What is the yearly trend of policies ending from 2016 to 2034? */
 select year(policy_end_date),count(*) POlicy_count from policy_details group by year(policy_end_date) order by Year(policy_end_date) asc;

