select product_id,
         product_name,
         category, discounted_price,
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

--Rating vs review count coorelation #1
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


--Calculations 
--What is Saving Amount the (bargain)

select 
    product_name,
    actual_price,
    discounted_price,
    round(actual_price - discounted_price,2) as savings_amount,
    discount_percentage,
    rating
from [dbo].[amazon_cleaned]
order by savings_amount desc;

-- Rating effiency score


--calculates a rating effiency score that measures how high a 
--a product's rating is relative to how many people have rated it
--products with high ratings but few reviews get a higher score

SELECT
    product_name,
    rating,
    rating_count,
    round(rating/(rating_count + 1), 4) as rating_efficiency,
    category
FROM [dbo].[amazon_cleaned]
where rating_count < 100 and rating >= 4.0
order by rating_efficiency desc;


-- ROI Analysis (discount vs rating)
-- calcuates a discount rating score
-- basically what is the high rating for high discount products 

SELECT
    product_name,
    discount_percentage,
    rating,
    round(discount_percentage * rating, 2) as discount_rating_score,
    category
FROM [dbo].[amazon_cleaned]
order by discount_rating_score desc
;

--Category summary
select  category,
    count(*) as total,
    round(avg(rating), 2) as avg_rating,
    round(avg(discount_percentage), 2) as avg_discount,
    round(avg(actual_price), 2) as avg_price,
    round(avg(rating_count), 0) as avg_reviews
from [dbo].[amazon_cleaned]
GROUP BY category
order by total desc;

--Top Products with a  30% discount
select top 5
    product_name,
    category,
    rating,
    rating_count,
    discount_percentage,
    actual_price,
    discounted_price
from [dbo].[amazon_cleaned]
where rating >= 4.5 and discount_percentage > 30
ORDER BY rating_count DESC;

--Market analysis

select
    case
        when discount_percentage < 30 then 'Low Discount'
        when discount_percentage < 60 then 'Medium Discount'
        else 'High Discount'
    end as discount_level,
    case
        when rating >= 4.3 then 'Premium Quality'
        else 'Standard Quality'
    end as quality_level,
    count(*) as product_count,
    round(AVG(actual_price), 2) as avg_price
from [dbo].[amazon_cleaned]
GROUP BY 
    case
        when discount_percentage < 30 then 'Low Discount'
        when discount_percentage < 60 then 'Medium Discount'
        else 'High Discount'
    end ,
    case
        when rating >= 4.3 then 'Premium Quality'
        else 'Standard Quality'
    end 
ORDER BY product_count;

select top 5 *
from [dbo].[amazon_cleaned]
;
--User Behavior analysis
select
    user_name,
    count(*) as reviews_written,
    count(DISTINCT product_id) as products_reviewed,
    round(avg(rating), 2) as avg_rating_given,
    case
        when count(*) > 50 then 'Prolific Reviewer'
        when count(*) > 20 then 'Active Reviewer'
        else 'Casual Reviewer'
    end as reviewer_type
from [dbo].[amazon_cleaned]
group by user_name
having count(*) > 5 --only users that more then 5 reviews
order by reviews_written desc;

--Price-Quality relationship

select 
    CASE
        WHEN actual_price <= 200 THEN '0-200'
        WHEN actual_price <= 500 THEN '201-500'
        WHEN actual_price <= 1000 THEN '501-1000'
        WHEN actual_price <= 5000 THEN '1001-5000'
        ELSE '5000+'
    end as price_bucket,
    count(*) as product_count,
    round(avg(rating), 2) as avg_rating,
    round(avg(discount_percentage), 2) as avg_discount
from products
group by price_bucket
order by CAST(substr(price_bucket, 1, INSRT(price_bucket, '-')-1) as integer)