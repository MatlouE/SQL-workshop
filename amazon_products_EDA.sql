select product_id,
         product_name,
         category, discounted_price
         actual_price, discount_percentage
from [dbo].[amazon_cleaned]

--Count 
select
    count(*) as total_products,
    count(DISTINCT product_id) as unique_products,
    count(distinct category) as total_categories,
    count(DISTINCT user_id) as total_reviewers
from [dbo].[amazon_cleaned]

--Price statistics
select round(avg(actual_price),2) as avg_actual_price,
        round(min(actual_price),2) as min_actual_price,
        round(max(actual_price), 2) as max_price,
        round(avg(discount_percentage), 2) as avg_discount_pct
from [dbo].[amazon_cleaned]

--high discount products
select distinct top 5
    product_name,
    actual_price,
    discounted_price,
    discount_percentage,
    rating
from [dbo].[amazon_cleaned]
where discount_percentage > 50
ORDER BY discount_percentage DESC;

--high rated + high discounted products
select top 5 product_name, 
    rating, discount_percentage,
    rating_count
from [dbo].[amazon_cleaned]
where discount_percentage > 50 and rating >= 4.0
order by rating desc, discount_percentage desc;

--Products per category
select category,
    count(distinct product_id) as product_count,
    round(avg(rating), 2) as avg_rating,
    round(avg(discount_percentage), 2) as avg_discount
from [dbo].[amazon_cleaned]
GROUP by category
order by product_count desc;

--Categories with high rating
select category,
    count(DISTINCT product_id) as product_count,
    ROUND(avg(rating), 2) as avg_rating,
    round(avg(actual_price), 2) as avg_price
from [dbo].[amazon_cleaned]
GROUP by category
HAVING count(DISTINCT product_id) > 5
    and avg(rating) >= 4.0
order by avg_rating desc;

--Rating analysis
select round(rating, 1) as rating_level,
    count(DISTINCT product_id) as product_count,
    ROUND(avg(rating_count), 0) as avg_reviews,
    round()