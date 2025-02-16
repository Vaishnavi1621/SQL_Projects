create database E_Commerce;
select 
Kpi1.day_end,
concat(round(kpi1.total_Payment/(select sum(payment_value) from olist_order_payments_dataset)*100,2)
, '%') as percentage_values

from
(select ord.day_end , sum(pmt.payment_value) as "total payments"
from olist_order_payments_dataset as pmt
join
(select distinct order_id,
case
when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else
"Weekday"
end as Day_end
from olist_orders_dataset) as ord on ord.order_id=pmt.order_id group by ord.Day_End)
as kpil;
-- ---------------------------------------------------------------------------------------------------------------------------------
#KPI2-Number of Orders with review score 5 and payment type as credit card.
SELECT 
    pmt.payment_type, COUNT(pmt.order_id)
FROM
    olist_order_payments_dataset AS pmt
        JOIN
    (SELECT DISTINCT
        ord.order_id, rws.review_score
    FROM
        olist_orders_dataset AS ord
    JOIN olist_order_reviews_dataset AS rws ON ord.order_id = rws.order_id
    WHERE
        rws.review_score = 5) AS rw5 ON pmt.order_id = rw5.order_id
WHERE
    pmt.payment_type = 'credit_card'
GROUP BY pmt.payment_type;
Alter table product_category_name_translation
Rename column ï»¿product_category_name to product_category_name;
-- -----------------------------------------------------------------------------------------------------------------------------------
#KPI3-Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 
    prod.product_category_name,
    ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date,
                    ord.order_purchase_timestamp)),
            0) AS avg_delivery_date
FROM
    olist_orders_dataset AS ord
        JOIN
    (SELECT 
        product_id, order_id, product_category_name
    FROM
        olist_products_dataset
    JOIN olist_order_items_dataset USING (product_id)) AS prod ON ord.order_id = prod.order_id
WHERE
    prod.product_category_name = 'pet_shop'
GROUP BY prod.product_category_name;
-- ------------------------------------------------------------------------------------------------------------------------------
#KPI4-Average price and payment values from customers of sao paulo city
#AVERAGE_PRICE
Select cust.customer_city, round (avg(pmt_price.price)) as avg_price
from olist_customers_dataset as cust
join (select pymnt.customer_id,pymnt.payment_value,item.price from olist_order_items_dataset as item join
(Select ord.order_id,ord.customer_id,pmt.payment_value from olist_orders_dataset as ord
join olist_order_payments_dataset as pmt on ord.order_id=pmt.order_id) as pymnt
on item.order_id=pymnt.order_id) as pmt_price on cust.customer_id=pmt_price.customer_id where cust.customer_city="sao paulo";
#AVERAGE_PAYMENT_VALUE
Select cust.customer_city, round (avg(pmt.payment_value),0) as avg_payment_value
from olist_customers_dataset cust inner join olist_orders_dataset ord
on cust.customer_id=ord.customer_id inner join
olist_order_payments_dataset as pmt on ord.order_id=pmt.order_id
where customer_city="sao paulo";
---------------------------------------------------------------------------------------------------------------------------------
#KPI5 - Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT 
    product_category_name_english,
    ROUND(SUM(payment_value), 0) AS total_revenue
FROM
    product_category_name_translation a
        INNER JOIN
    olist_products_dataset b ON a.product_category_name = b.product_category_name
        JOIN
    olist_order_items_dataset c ON b.product_id = c.product_id
        JOIN
    olist_order_payments_dataset d ON c.order_id = d.order_id
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 5;
-- ---------------------------------------------------------------------------------------------------------------------------------------
Select rw.review_score, round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0)
as avg_Shipping_Days
from olist_orders_dataset as ord join olist_order_reviews_dataset as rw on 
rw.order_id=ord.order_id group by rw.review_score order by rw.review_score;
-- ---------------------------------------------------------------------------------------------------------------------------------------
select * from product_category_name_translation;
select * from olist_products_dataset;
select * from olist_order_items_dataset;
select * from olist_order_payments_dataset;
select * from olist_orders_dataset;
alter table olist_orders_dataset
drop column day_end;
select * from olist_order_reviews_dataset;
select * from olist_geolocation_dataset;



















