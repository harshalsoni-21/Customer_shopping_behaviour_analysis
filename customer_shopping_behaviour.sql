select * from customer limit 20

--1. Calculate the total revenue earned separately from male and female customers.

select gender, 
       SUM(purchase_amount) as total_revenue
from customer
group by gender;

--2. Find the customers who received a discount but still spent more than the overall average purchase amount.

SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (
      SELECT AVG(purchase_amount)
      FROM customer
  );

--3. List the top 5 products based on their average customer review ratings.

select item_purchased, round(AVG(review_rating::numeric),2) as "Average Product rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

--4. Show a comparison of the average purchase amount for Standard Shipping and Express Shipping.

select shipping_type,
round(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--5. Analyze whether subscribed customers spend more than non-subscribers by comparing their average spending and total revenue.

select subscription_status,
count(customer_id) as total_customers,
round(avg(purchase_amount),2) as avg_spend,
round(sum(purchase_amount),2) as total_revenue
from customer 
group by subscription_status
order by total_revenue, avg_spend desc;

--6. Identify the top 5 products with the highest percentage of purchases where a discount was applied.

SELECT 
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN LOWER(discount_applied) = 'yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--7.Classify customers as New, Returning, or Loyal according to their previous purchase count, and display the number of customers in each group.

WITH customer_type AS (
    SELECT customer_id,
           previous_purchases,
           CASE
               WHEN previous_purchases = 1 THEN 'New'
               WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer
)
SELECT customer_segment,
       COUNT(*) AS "Number of Customers"
FROM customer_type
GROUP BY customer_segment;

--8. Determine the three most frequently purchased products in every category.

WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (
               PARTITION BY category 
               ORDER BY COUNT(customer_id) DESC
           ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,
       category,
       item_purchased,
       total_orders
FROM item_counts;

--9. Check whether customers with more than five previous purchases are more likely to have a subscription.

SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--10. Calculate the percentage contribution of each age group to the overall revenue.

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

ALTER TABLE customer
ADD COLUMN age_group VARCHAR(10);

SELECT *,
CASE
    WHEN age <= 18 THEN '0-18'
    WHEN age BETWEEN 19 AND 30 THEN '19-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group
FROM public.customer;



