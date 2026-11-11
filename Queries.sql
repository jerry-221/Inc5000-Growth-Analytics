-- ============================================================
-- Inc. 5000 Companies 2019 — SQL Analysis
-- Author: <PRANAV PATIL>
-- Date:   2026-11-09
-- Tools:  MySQL , database: inc5000_analytics, table: companies
-- Source: INC_5000_Companies_clean.csv (5,012 rows, 44 cols)
-- ============================================================

-- (setup used only once — keep commented for reference)
--  SHOW databases;
--  USE inc5000_analytics;
--  SHOW tables;
--  DESCRIBE companies;


-- ============================================================
-- Part 1 — Core Business Insights
-- ============================================================

-- QUESTION_1: What is the overall scale — how many companies, total revenue, total jobs?
SELECT COUNT(*)                                 AS total_companies,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS total_revenue_billions,
       SUM(workers)                             AS total_workers,
       ROUND(AVG(growth_pct), 1)                AS avg_growth_pct,
       MIN(founded)                             AS oldest_company_founded,
       MAX(founded)                             AS newest_company_founded
FROM companies;


-- QUESTION_2: How are companies distributed across growth bands?
SELECT growth_category,
       COUNT(*)                                                       AS companies,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM companies), 1)  AS pct_of_list
FROM companies
GROUP BY growth_category
ORDER BY companies DESC;


-- QUESTION_3: Which sectors have the highest number of companies and highest growth?
SELECT sector,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(AVG(revenue_per_worker), 0)        AS avg_rev_per_worker,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS revenue_billions,
       SUM(workers)                             AS total_workers
FROM companies
GROUP BY sector
ORDER BY avg_growth DESC;


-- QUESTION_4: Which 10 narrow industries grow fastest (min 10 companies)?
SELECT industry,
       sector,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth
FROM companies
GROUP BY industry, sector
HAVING COUNT(*) >= 10
ORDER BY avg_growth DESC
LIMIT 10;


-- QUESTION_5: Which states are the biggest hubs for Inc. 5000 companies?
SELECT state,
       region,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS revenue_billions
FROM companies
GROUP BY state, region
ORDER BY companies DESC
LIMIT 15;


-- QUESTION_6: Do coastal-state companies outperform inland ones?
SELECT CASE WHEN is_coastal = 1 THEN 'Coastal' ELSE 'Inland' END AS location_type,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(AVG(revenue_per_worker), 0)        AS avg_rev_per_worker
FROM companies
GROUP BY is_coastal;


-- QUESTION_7: Which macro-region dominates — Northeast, South, Midwest, West?
SELECT region,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS revenue_billions
FROM companies
GROUP BY region
ORDER BY companies DESC;


-- QUESTION_8: Do first-timers or veterans grow faster?
SELECT CASE WHEN is_veteran = 1 THEN 'Veteran (2+ yrs)' ELSE 'First-Timer' END AS list_status,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(AVG(worker_growth_pct), 1)         AS avg_hiring_pct,
       ROUND(AVG(growth_quality_score), 3)      AS avg_quality_score
FROM companies
GROUP BY is_veteran;


-- QUESTION_9: How does growth vary by company age cohort?
SELECT age_bucket,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth
FROM companies
GROUP BY age_bucket
ORDER BY avg_growth DESC;


-- QUESTION_10: Do small teams or large teams grow faster?
SELECT worker_bucket,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(AVG(revenue_per_worker), 0)        AS avg_rev_per_worker
FROM companies
GROUP BY worker_bucket
ORDER BY avg_growth DESC;


-- QUESTION_11: Efficient Scalers vs Brute Scalers — who wins?
SELECT scaling_type,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth,
       ROUND(AVG(revenue_per_worker), 0)        AS avg_rev_per_worker,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS revenue_billions
FROM companies
GROUP BY scaling_type
ORDER BY revenue_billions DESC;


-- QUESTION_12: Which companies have the best composite (growth + efficiency) score?
SELECT company_rank,
       name,
       sector,
       state,
       ROUND(growth_pct, 0)                     AS growth_pct,
       ROUND(revenue_usd / 1e6, 1)              AS revenue_millions,
       workers,
       ROUND(growth_quality_score, 3)           AS quality_score,
       scaling_type
FROM companies
ORDER BY growth_quality_score DESC
LIMIT 10;


-- QUESTION_13: Which companies beat their industry average by the most?
SELECT name,
       industry,
       ROUND(growth_pct, 0)                     AS company_growth,
       ROUND(industry_avg_growth, 0)            AS industry_avg,
       ROUND(growth_vs_ind_avg, 0)              AS outperformance
FROM companies
WHERE industry_avg_growth IS NOT NULL
ORDER BY growth_vs_ind_avg DESC
LIMIT 15;


-- QUESTION_14: Which sectors house the billion-dollar giants?
SELECT sector,
       COUNT(*)                                 AS billion_dollar_companies,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS combined_revenue_billions
FROM companies
WHERE is_billion_club = 1
GROUP BY sector
ORDER BY combined_revenue_billions DESC;


-- QUESTION_15: What's the total revenue contribution of the top 10% of companies?
WITH ranked AS (
    SELECT revenue_usd,
           NTILE(10) OVER (ORDER BY revenue_usd DESC) AS decile
    FROM companies
)
SELECT ROUND(SUM(revenue_usd) / 1e9, 2)                        AS top_10pct_revenue_billions,
       ROUND(100.0 * SUM(revenue_usd)
             / (SELECT SUM(revenue_usd) FROM companies), 1)    AS pct_of_total_revenue,
       COUNT(*)                                                AS companies_in_top_10pct
FROM ranked
WHERE decile = 1;


-- _______________________________________________________________________________________________________________


-- ============================================================
-- Part 2 — Deep-Dive Analytics
-- ============================================================

-- ============================================================
-- SECTION A — Descriptive Analytics
-- ============================================================

-- QUESTION_1: What is the full distribution across growth categories and sectors?
SELECT sector,
       growth_category,
       COUNT(*)                                 AS companies
FROM companies
GROUP BY sector, growth_category
ORDER BY sector, companies DESC;


-- QUESTION_2: What is the revenue distribution (small, mid, large, billion)?
SELECT revenue_category,
       COUNT(*)                                 AS companies,
       ROUND(SUM(revenue_usd) / 1e9, 2)         AS revenue_billions,
       ROUND(AVG(revenue_usd) / 1e6, 1)         AS avg_revenue_millions
FROM companies
GROUP BY revenue_category
ORDER BY revenue_billions DESC;


-- QUESTION_3: What are the top 10 most common industries (by company count)?
SELECT industry,
       sector,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth
FROM companies
GROUP BY industry, sector
ORDER BY companies DESC
LIMIT 10;


-- QUESTION_4: How many companies were founded in each decade?
SELECT founded_decade,
       COUNT(*)                                 AS companies,
       ROUND(AVG(growth_pct), 1)                AS avg_growth
FROM companies
WHERE founded_decade IS NOT NULL
  AND founded_decade >= 1970
GROUP BY founded_decade
ORDER BY founded_decade;


-- QUESTION_5: What are the top 10 metro areas by company count?
SELECT metro_clean                                AS metro,
       COUNT(*)                                  AS companies,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth
FROM companies
WHERE has_metro_data = 1
GROUP BY metro_clean
ORDER BY companies DESC
LIMIT 10;


-- QUESTION_6: What is the review of hiring velocity across sectors?
SELECT sector,
       ROUND(AVG(worker_growth_pct), 1)          AS avg_hiring_pct,
       ROUND(AVG(worker_growth_abs), 0)          AS avg_absolute_hires,
       SUM(worker_growth_abs)                    AS total_new_jobs
FROM companies
WHERE worker_growth_pct IS NOT NULL
GROUP BY sector
ORDER BY avg_hiring_pct DESC;


-- QUESTION_7: What is the distribution of companies by revenue-per-worker band?
SELECT CASE
           WHEN revenue_per_worker < 100000      THEN '<$100K/worker'
           WHEN revenue_per_worker < 500000      THEN '$100K-$500K'
           WHEN revenue_per_worker < 1000000     THEN '$500K-$1M'
           WHEN revenue_per_worker < 5000000     THEN '$1M-$5M'
           ELSE '>$5M'
       END                                       AS productivity_band,
       COUNT(*)                                  AS companies,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth
FROM companies
WHERE revenue_per_worker IS NOT NULL
GROUP BY productivity_band
ORDER BY avg_growth DESC;


-- QUESTION_8: How many companies have lean teams (under 20 workers)?
SELECT is_lean_team,
       COUNT(*)                                  AS companies,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth,
       ROUND(AVG(revenue_per_worker), 0)         AS avg_rev_per_worker
FROM companies
WHERE is_lean_team IS NOT NULL
GROUP BY is_lean_team;


-- ________________________________________________________________________


-- ============================================================
-- SECTION B — Advanced Analytics
-- ============================================================

-- QUESTION_1: Which sector × region combo generates the most revenue?
SELECT sector,
       region,
       COUNT(*)                                  AS companies,
       ROUND(SUM(revenue_usd) / 1e9, 2)          AS revenue_billions,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth
FROM companies
GROUP BY sector, region
HAVING COUNT(*) >= 20
ORDER BY revenue_billions DESC
LIMIT 15;


-- QUESTION_2: What is each region's share of total revenue?
SELECT region,
       ROUND(SUM(revenue_usd) / 1e9, 2)          AS revenue_billions,
       ROUND(100.0 * SUM(revenue_usd)
             / (SELECT SUM(revenue_usd) FROM companies), 2) AS pct_of_total
FROM companies
GROUP BY region
ORDER BY revenue_billions DESC;


-- QUESTION_3: Which companies rank in the top 10% by composite growth quality?
WITH ranked AS (
    SELECT company_rank, name, sector, state,
           growth_pct, revenue_per_worker, growth_quality_score,
           NTILE(10) OVER (ORDER BY growth_quality_score DESC) AS decile
    FROM companies
)
SELECT company_rank, name, sector, state,
       ROUND(growth_pct, 0)                      AS growth_pct,
       ROUND(revenue_per_worker, 0)              AS rev_per_worker,
       ROUND(growth_quality_score, 3)            AS quality_score
FROM ranked
WHERE decile = 1
ORDER BY growth_quality_score DESC
LIMIT 20;


-- QUESTION_4: What's the balance of efficient vs brute scalers within each sector?
SELECT sector,
       SUM(CASE WHEN scaling_type = 'Efficient Scaler'   THEN 1 ELSE 0 END) AS efficient_count,
       SUM(CASE WHEN scaling_type = 'Brute Scaler'       THEN 1 ELSE 0 END) AS brute_count,
       SUM(CASE WHEN scaling_type = 'Efficient but Slow' THEN 1 ELSE 0 END) AS efficient_slow_count,
       SUM(CASE WHEN scaling_type = 'Lagging'            THEN 1 ELSE 0 END) AS lagging_count,
       COUNT(*)                                                              AS total_companies,
       ROUND(100.0 * SUM(CASE WHEN scaling_type = 'Efficient Scaler' THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                                 AS pct_efficient_scalers
FROM companies
GROUP BY sector
ORDER BY pct_efficient_scalers DESC;


-- QUESTION_5: Which companies have grown the fastest AND hire the most?
SELECT name,
       sector,
       ROUND(growth_pct, 0)                      AS growth_pct,
       worker_growth_abs                         AS absolute_new_hires,
       ROUND(worker_growth_pct, 0)               AS hiring_pct,
       workers                                   AS current_workers
FROM companies
WHERE growth_pct > 500
  AND worker_growth_abs > 100
ORDER BY growth_pct DESC
LIMIT 15;


-- QUESTION_6: What's the correlation-style breakdown — growth vs productivity quadrants?
SELECT
    CASE
        WHEN growth_percentile > 0.75 AND rpw_percentile > 0.75 THEN 'Stars (Top growth + Top efficiency)'
        WHEN growth_percentile > 0.75 AND rpw_percentile <= 0.25 THEN 'Rockets (Top growth, Low efficiency)'
        WHEN growth_percentile <= 0.25 AND rpw_percentile > 0.75 THEN 'Cash Cows (Low growth, Top efficiency)'
        WHEN growth_percentile <= 0.25 AND rpw_percentile <= 0.25 THEN 'Dogs (Low both)'
        ELSE 'Middle'
    END                                           AS portfolio_quadrant,
    COUNT(*)                                      AS companies,
    ROUND(AVG(growth_pct), 1)                     AS avg_growth,
    ROUND(AVG(revenue_per_worker), 0)             AS avg_rev_per_worker,
    ROUND(SUM(revenue_usd) / 1e9, 2)              AS revenue_billions
FROM companies
GROUP BY portfolio_quadrant
ORDER BY revenue_billions DESC;


-- QUESTION_7: Which states over-index on hyper-growth companies?
SELECT state,
       COUNT(*)                                                         AS total_companies,
       SUM(CASE WHEN growth_category = 'Hyper (>1000%)' THEN 1 ELSE 0 END) AS hyper_growers,
       ROUND(100.0 * SUM(CASE WHEN growth_category = 'Hyper (>1000%)' THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                              AS hyper_grower_pct
FROM companies
GROUP BY state
HAVING COUNT(*) >= 50
ORDER BY hyper_grower_pct DESC;


-- QUESTION_8: Which companies are the biggest absolute job creators?
SELECT name,
       sector,
       state,
       worker_growth_abs                         AS new_jobs_added,
       previous_workers                          AS before_workers,
       workers                                   AS after_workers,
       ROUND(growth_pct, 0)                      AS growth_pct
FROM companies
WHERE worker_growth_abs IS NOT NULL
ORDER BY worker_growth_abs DESC
LIMIT 20;


-- QUESTION_9: What is the revenue concentration — how many companies drive 80% of revenue?
WITH cume AS (
    SELECT revenue_usd,
           SUM(revenue_usd) OVER (ORDER BY revenue_usd DESC)             AS running_total,
           SUM(revenue_usd) OVER ()                                      AS grand_total,
           100.0 * ROW_NUMBER() OVER (ORDER BY revenue_usd DESC)
                 / COUNT(*) OVER ()                                      AS cumulative_pct
    FROM companies
)
SELECT ROUND(MIN(cumulative_pct), 1)                                     AS pct_companies_for_80pct_revenue,
       COUNT(*)                                                          AS companies_needed
FROM cume
WHERE running_total <= 0.80 * grand_total;


-- QUESTION_10: Which sector is "young and fast" vs "old and slow"?
SELECT sector,
       ROUND(AVG(company_age), 1)                AS avg_company_age,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth,
       ROUND(AVG(growth_quality_score), 3)       AS avg_quality_score
FROM companies
WHERE company_age IS NOT NULL
GROUP BY sector
ORDER BY avg_company_age ASC;


-- QUESTION_11: Which industries have the most "hidden gems" (high revenue per worker but lower profile)?
SELECT industry,
       COUNT(*)                                  AS companies,
       ROUND(AVG(revenue_per_worker), 0)         AS avg_rev_per_worker,
       ROUND(AVG(growth_pct), 1)                 AS avg_growth,
       ROUND(AVG(workers), 0)                    AS avg_workers
FROM companies
WHERE revenue_per_worker IS NOT NULL
GROUP BY industry
HAVING COUNT(*) >= 20
ORDER BY avg_rev_per_worker DESC
LIMIT 10;