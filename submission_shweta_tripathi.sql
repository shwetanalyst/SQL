-- Q.1 What is the distribution of customers across states?
select state,count(customer_id) as Customer
from customer_t
group by state
order by Customer desc
limit 5;

-- Q.2 What is the average rating in each quarter?
select t.quarter_number, avg(t.rating_score) as average_rating_score from (SELECT
    quarter_number, customer_feedback,
    case when customer_feedback = 'Very Good' then 5
		when customer_feedback = 'Good' then 4
        when customer_feedback = 'Okay' then 3
        when customer_feedback = 'Bad' then 2
        when customer_feedback = 'Very Bad' then 1
        end
        as rating_score
FROM
    order_t) as t
GROUP BY
    t.quarter_number;
  
-- Q.3 Are customers getting more dissatisfied over time?
select t.customer_feedback , t.quarter_number,t.Total_feedback_per_rating,t2.Total_feedback,
 (t.Total_feedback_per_rating/t2.Total_feedback)*100 as percentage_of_feedback_each_quarter
 from 
(select customer_feedback , quarter_number, count(customer_id) as Total_feedback_per_rating
from order_t
group by customer_feedback, quarter_number
order by quarter_number) as t
inner join
(select quarter_number,count(customer_id) as Total_feedback
from order_t
group by quarter_number) as t2
on t.quarter_number = t2.quarter_number;


-- Q.4 Which are the top 5 vehicle makers preferred by the customer
select p.vehicle_maker, count(o.customer_id) as Total_customer
from order_t as o inner join product_t as p 
on o.product_id=p.product_id
group by p.vehicle_maker
order by Total_customer desc;

-- Q.5 What is the most preferred vehicle make in each state?
select t1.state_name, t1.vehicle_manufacturer, t1.sales_count from
(select t.state_name, t.vehicle_manufacturer, t.sales_count,
rank() over(partition by t.state_name order by t.sales_count desc) as sales_rank
 from (select c.state as state_name, p.vehicle_maker as vehicle_manufacturer, count(c.customer_id) as sales_count
from customer_t as c
inner join order_t as o on  c.customer_id = o.customer_id
inner join product_t as p on o.product_id = p.product_id
group by c.state,p.vehicle_maker) as t) as t1
where sales_rank = 1;

select t1.vehicle_manufacturer, count(t1.state_name) as number_of_states_with_first_rank from
(select t.state_name, t.vehicle_manufacturer, t.sales_count,
rank() over(partition by t.state_name order by t.sales_count desc) as sales_rank
 from (select c.state as state_name, p.vehicle_maker as vehicle_manufacturer, count(c.customer_id) as sales_count
from customer_t as c
inner join order_t as o on  c.customer_id = o.customer_id
inner join product_t as p on o.product_id = p.product_id
group by c.state,p.vehicle_maker) as t) as t1
where sales_rank = 1
group by t1.vehicle_manufacturer
order by number_of_states_with_first_rank desc;

-- Q.6 What is the trend of number of orders by quarters?
select quarter_number, sum(quantity) as number_of_orders_per_quater
from order_t
group by quarter_number
order by quarter_number;

-- Q7  What is the quarter over quarter % change in revenue?
select *, 
(t1.total_revenue_per_quarter - coalesce(t1.previous_quarter_value,0))/ t1.total_revenue_per_quarter * 100 as Qtr_over_Qtr_revenue_change
from (select *, LAG(t.total_revenue_per_quarter) over(order by t.quarter_number) as previous_quarter_value from (select a.quarter_number, sum(a.vehicle_price * ((100 - a.discount)/100) * a.quantity) as total_revenue_per_quarter from 
order_t a inner join product_t b on a.product_id = b.product_id
group by a.quarter_number) as t) as t1;

-- Q8 What is the trend of revenue and orders by quarters?
select a.quarter_number, sum(a.vehicle_price * ((100 - a.discount)/100) * a.quantity) as total_revenue_per_quarter, sum(a.quantity) as total_orders_per_quater from 
order_t a inner join product_t b on a.product_id = b.product_id
group by a.quarter_number
order by a.quarter_number;

-- Q.9 What is the average discount offered for different types of credit cards?
select credit_card_type,avg(discount) as Average_discount
from customer_t as T1 inner join order_t as T2 on T1.customer_id=T2.customer_id
group by credit_card_type
order by Average_discount desc;

-- Q.10 What is the average time taken to ship the placed orders for each quarters?
select quarter_number,avg (datediff(ship_date,order_date)) 
from order_t
group by quarter_number
order by quarter_number;
