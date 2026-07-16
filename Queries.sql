-- ============================================================
-- Slide 1
-- ============================================================

-- OVERALL CTR
SELECT 
    round((SELECT 
            COUNT(*)
        FROM
            ad_clicks) * 100.0 / (SELECT 
            COUNT(*)
        FROM
            ad_impressions),2) AS overall_ctr_percent;
            
-- Total ad impression
SELECT 
    COUNT(*)
FROM
    ad_impressions;
    
-- Total users
SELECT 
    COUNT(*)
FROM
    social_media_revenue.users;

-- TOTAL REVENUE (Subscriptions + Click Revenue + Impression Revenue)
SELECT
    ROUND(
        (SELECT SUM(monthly_fee) FROM subscriptions) +
        (SELECT SUM(a.cost_per_click) FROM ad_clicks c JOIN ads a ON c.ad_id = a.ad_id) +
        (SELECT SUM(a.cost_per_impression) FROM ad_impressions i JOIN ads a ON i.ad_id = a.ad_id),
    2) AS total_revenue;
    
-- ============================================================    
-- Slide 2
-- ============================================================

-- Total Ads
select count(*)
from ads;

-- Total ad clicks
select count(*)
from ad_clicks;

-- Total subscription
select count(*)
from subscriptions;

-- ============================================================
#Slide 5
-- ============================================================

-- USER REVENUE SEGMENTS
SELECT 
    'Premium Subscribers' AS segment,
    COUNT(DISTINCT user_id) AS user_count,
    COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(*) FROM users) AS pct_of_users,
    SUM(monthly_fee) AS revenue
FROM subscriptions

UNION ALL

SELECT 
    'High-CTR Clickers (Non-Premium)' AS segment,
    COUNT(DISTINCT c.user_id) AS user_count,
    COUNT(DISTINCT c.user_id) * 100.0 / (SELECT COUNT(*) FROM users) AS pct_of_users,
    SUM(a.cost_per_click) AS revenue
FROM ad_clicks c
JOIN ads a ON c.ad_id = a.ad_id
WHERE c.user_id NOT IN (SELECT DISTINCT user_id FROM subscriptions)

UNION ALL

SELECT 
    'Impression-Only (Non-Premium, Non-Clicker)' AS segment,
    COUNT(DISTINCT i.user_id) AS user_count,
    COUNT(DISTINCT i.user_id) * 100.0 / (SELECT COUNT(*) FROM users) AS pct_of_users,
    SUM(a.cost_per_impression) AS revenue
FROM ad_impressions i
JOIN ads a ON i.ad_id = a.ad_id
WHERE i.user_id NOT IN (SELECT DISTINCT user_id FROM subscriptions)
  AND i.user_id NOT IN (SELECT DISTINCT user_id FROM ad_clicks)

UNION ALL

SELECT 
    'Free / No Ad Activity' AS segment,
    COUNT(*) AS user_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users) AS pct_of_users,
    0.00 AS revenue
FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM subscriptions)
  AND user_id NOT IN (SELECT DISTINCT user_id FROM ad_clicks)
  AND user_id NOT IN (SELECT DISTINCT user_id FROM ad_impressions);
  
  -- ============================================================
  -- Slide 6
  -- ============================================================  

-- CTR & Click Revenue by Ad Category
WITH imp AS (
    SELECT 
        ad_id, 
        COUNT(*) AS impressions 
    FROM ad_impressions 
    GROUP BY ad_id
),
clk AS (
    SELECT 
        c.ad_id, 
        COUNT(*) AS clicks, 
        SUM(a.cost_per_click) AS click_revenue 
    FROM ad_clicks c 
    JOIN ads a ON c.ad_id = a.ad_id 
    GROUP BY c.ad_id
)
SELECT 
    a.category,
    SUM(imp.impressions)                                                    AS impressions,
    COALESCE(SUM(clk.clicks), 0)                                            AS clicks,
    ROUND(COALESCE(SUM(clk.clicks), 0) / SUM(imp.impressions) * 100, 2)    AS ctr_percent,
    ROUND(COALESCE(SUM(clk.click_revenue), 0), 2)                          AS click_revenue
FROM imp
JOIN ads a ON imp.ad_id = a.ad_id
LEFT JOIN clk ON imp.ad_id = clk.ad_id
GROUP BY a.category
ORDER BY ctr_percent DESC;

--  CTR BY GENDER
WITH imp AS (
    SELECT u.gender, COUNT(*) AS impressions
    FROM ad_impressions i JOIN users u ON i.user_id = u.user_id
    GROUP BY u.gender
),
clk AS (
    SELECT u.gender, COUNT(*) AS clicks
    FROM ad_clicks c JOIN users u ON c.user_id = u.user_id
    GROUP BY u.gender
)
SELECT 
    imp.gender,
    imp.impressions,
    COALESCE(clk.clicks, 0)                              AS clicks,
    COALESCE(clk.clicks, 0) / imp.impressions * 100      AS ctr_percent
FROM imp
LEFT JOIN clk ON imp.gender = clk.gender
ORDER BY ctr_percent DESC;

-- CTR BY COUNTRY
WITH imp AS (
    SELECT u.country, COUNT(*) AS impressions
    FROM ad_impressions i JOIN users u ON i.user_id = u.user_id
    GROUP BY u.country
),
clk AS (
    SELECT u.country, COUNT(*) AS clicks
    FROM ad_clicks c JOIN users u ON c.user_id = u.user_id
    GROUP BY u.country
)
SELECT 
    imp.country,
    imp.impressions,
    COALESCE(clk.clicks, 0)                              AS clicks,
    COALESCE(clk.clicks, 0) / imp.impressions * 100      AS ctr_percent
FROM imp
LEFT JOIN clk ON imp.country = clk.country
ORDER BY ctr_percent DESC;

-- ============================================================
-- Slide 7
-- ============================================================

-- TOTAL REVENUE BREAKDOWN
SELECT 
    'Subscriptions' AS stream, SUM(monthly_fee) AS revenue
FROM
    subscriptions 
UNION ALL SELECT 
    'Click Revenue' AS stream, SUM(a.cost_per_click) AS revenue
FROM
    ad_clicks c
        JOIN
    ads a ON c.ad_id = a.ad_id 
UNION ALL SELECT 
    'Impression Revenue' AS stream,
    SUM(a.cost_per_impression) AS revenue
FROM
    ad_impressions i
        JOIN
    ads a ON i.ad_id = a.ad_id;

-- ARPU (Average Revenue Per User)
SELECT 
    ((SELECT 
            SUM(monthly_fee)
        FROM
            subscriptions) + (SELECT 
            SUM(a.cost_per_click)
        FROM
            ad_clicks c
                JOIN
            ads a ON c.ad_id = a.ad_id) + (SELECT 
            SUM(a.cost_per_impression)
        FROM
            ad_impressions i
                JOIN
            ads a ON i.ad_id = a.ad_id)) / (SELECT 
            COUNT(*)
        FROM
            users) AS arpu;

-- ============================================================
#Slide 8
-- ============================================================

-- CTR BY AGE GROUP
WITH imp AS (
    SELECT 
        CASE 
            WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
            WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
            WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
            WHEN u.age BETWEEN 45 AND 59 THEN '45-59'
        END AS age_group,
        COUNT(*) AS impressions
    FROM ad_impressions i JOIN users u ON i.user_id = u.user_id
    GROUP BY age_group
),
clk AS (
    SELECT 
        CASE 
            WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
            WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
            WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
            WHEN u.age BETWEEN 45 AND 59 THEN '45-59'
        END AS age_group,
        COUNT(*) AS clicks
    FROM ad_clicks c JOIN users u ON c.user_id = u.user_id
    GROUP BY age_group
)
SELECT 
    imp.age_group,
    imp.impressions,
    COALESCE(clk.clicks, 0)                              AS clicks,
    COALESCE(clk.clicks, 0) / imp.impressions * 100      AS ctr_percent
FROM imp
LEFT JOIN clk ON imp.age_group = clk.age_group
ORDER BY imp.age_group;

# Monthly CTR trend:
SELECT month, impressions, clicks, round(clicks/impressions*100,2) AS ctr_percent
FROM (
  SELECT DATE_FORMAT(impression_time, '%Y-%m') AS month, COUNT(*) AS impressions
  FROM ad_impressions
  GROUP BY month
) AS imp
LEFT JOIN (
  SELECT DATE_FORMAT(click_time, '%Y-%m') AS month, COUNT(*) AS clicks
  FROM ad_clicks
  GROUP BY month
) AS clk USING (month)
ORDER BY month;