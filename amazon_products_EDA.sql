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
    round(avg(discount_percentage), 2) as avg_discount
from [dbo].[amazon_cleaned]
group by round(rating, 1)
order by rating_level desc;

select *
from [dbo].[amazon_cleaned];

--string functions & Case
select 
    substring(product_name, 1, 50) as short_name,
    LEN(product_name) as name_length,
    upper(category) as category_upper
from [dbo].[amazon_cleaned]
where LEN(product_name) > 50;

-- rating categories
select
    COUNT(*) as counts,
    case 
        when rating >= 4.5 then 'Excellent'
        when rating >= 4.0 then 'Very Good'
        when rating >= 3.5 then 'Good'
        else 'Below Average (<3.5)'
    end as rating_category
from [dbo].[amazon_cleaned]
group by 
    case 
        when rating >= 4.5 then 'Excellent'
        when rating >= 4.0 then 'Very Good'
        when rating >= 3.5 then 'Good'
        else 'Below Average (<3.5)'
    end
order by counts ;

-- Price segmentation
select 
    CASE 
        WHEN discounted_price < 200 then 'Budget (<₹200)'
        when discounted_price < 500 then 'Mid-Range (₹200-500)'
        when discounted_price < 1000 then 'Premium (₹500-1000)'
        else 'Luxury (₹1000+)'
    end as price_category,
    count(*) as product_count,
    round(avg(rating), 2) as avg_rating,
    round(avg(discount_percentage), 2) as avg_discount
from [dbo].[amazon_cleaned]
GROUP by 
    CASE 
        WHEN discounted_price < 200 then 'Budget (<₹200)'
        when discounted_price < 500 then 'Mid-Range (₹200-500)'
        when discounted_price < 1000 then 'Premium (₹500-1000)'
        else 'Luxury (₹1000+)'
    end
order by product_count DESC;


--subqueries , Above average rating
select 
    product_name,
    rating,
    discount_percentage,
    actual_price
from [dbo].[amazon_cleaned]
where rating > (select avg(rating) from [dbo].[amazon_cleaned])
order by rating desc;


--Price range 
select 
    product_name,
    discounted_price,
    actual_price,
    discount_percentage,
    rating,
    rating_count
from [dbo].[amazon_cleaned]
where actual_price between 500 and 1000
order by discount_percentage desc;


SELECT 
    CASE 
        WHEN rating_count > (SELECT AVG(rating_count) FROM products) THEN 'High Reviews'
        ELSE 'Low Reviews'
    END as review_level,
    CASE 
        WHEN rating > 4.0 THEN 'High Rating'
        ELSE 'Low Rating'
    END as rating_level,
    COUNT(*) as count
FROM [dbo].[amazon_cleaned]
GROUP BY 2;

WITH avg_rc as (
    SELECT AVG(rating_count) as avg_count FROM [dbo].[amazon_cleaned]
)
SELECT 
    CASE 
        WHEN a.rating_count > ar.avg_count THEN 'High Reviews'
        ELSE 'Low Reviews'
    END as review_level,
    CASE 
        WHEN a.rating > 4.0 THEN 'High Rating'
        ELSE 'Low Rating'
    END as rating_level,
    COUNT(*) as count
FROM [dbo].[amazon_cleaned] a
CROSS JOIN avg_rc ar
GROUP BY 
    CASE 
        WHEN a.rating_count > ar.avg_count THEN 'High Reviews'
        ELSE 'Low Reviews'
    END,
    CASE 
        WHEN a.rating > 4.0 THEN 'High Rating'
        ELSE 'Low Rating'
    END;





