use retail_analytics;
select count(*) from transactions;
select * from transactions limit 10;
select count(*) from transactions where cust_id is null;
select count(*) from transactions where cust_id is not null;

#1.Overall Revenue and Loyalty Split
#Business question: How bad is the loyalty gap?

SELECT 
    Loyalty_Flag,
    COUNT(Trans_ID)                                     AS Total_Transactions,
    COUNT(DISTINCT Cust_ID)                             AS Unique_Customers,
    ROUND(SUM(Amount), 2)                               AS Total_Revenue,
    ROUND(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER(), 2) AS Revenue_Pct,
    ROUND(AVG(Amount), 2)                               AS Avg_Basket_Size
FROM transactions
GROUP BY Loyalty_Flag;

#2.Revenue by Store Type
#Business question: Which store format has the worst loyalty penetration? That's where acquisition drives should focus.

SELECT 
    Store_Type,
    Loyalty_Flag,
    COUNT(Trans_ID)               AS Transactions,
    ROUND(SUM(Amount), 2)         AS Revenue,
    ROUND(AVG(Amount), 2)         AS Avg_Basket,
    ROUND(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER(PARTITION BY Store_Type), 2) AS Pct_Within_Store_Type
FROM transactions
GROUP BY Store_Type, Loyalty_Flag
ORDER BY Store_Type, Loyalty_Flag;

#3.Customer RFM Base Table
#Business question: Which loyalty customers are Champions, which are At Risk, which are dormant?

SELECT
    Cust_ID,
    COUNT(Trans_ID)                                  AS Frequency,
    ROUND(SUM(Amount), 2)                            AS Monetary,
    ROUND(AVG(Amount), 2)                            AS Avg_Basket,
    MAX(Trand_Dt)                                    AS Last_Purchase_Date,
    MIN(Trand_Dt)                                    AS First_Purchase_Date,
    DATEDIFF('2021-01-31', MAX(Trand_Dt))            AS Recency_Days,
    COUNT(DISTINCT Store_Type)                       AS Store_Formats_Visited,
    COUNT(DISTINCT Brand)                            AS Unique_Brands_Bought
FROM transactions
WHERE Cust_ID IS NOT NULL
GROUP BY Cust_ID
ORDER BY Monetary DESC;

#4.RFM Scoring with Segments
#Business question: Give every loyalty customer a segment label.

WITH customer_rfm AS (
    SELECT
        Cust_ID,
        COUNT(Trans_ID)                        AS Frequency,
        ROUND(SUM(Amount), 2)                  AS Monetary,
        DATEDIFF('2021-01-31', MAX(Trand_Dt))  AS Recency_Days
    FROM transactions
    WHERE Cust_ID IS NOT NULL
    GROUP BY Cust_ID
),
rfm_quartiles AS (
    SELECT *,
        -- Recency: lower days = more recent = better, so reverse the order
        NTILE(4) OVER (ORDER BY Recency_Days DESC)  AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency ASC)      AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC)       AS M_Score
    FROM customer_rfm
),
rfm_combined AS (
    SELECT *,
        (R_Score + F_Score + M_Score) AS RFM_Total_Score
    FROM rfm_quartiles
)
SELECT *,
    CASE
        WHEN RFM_Total_Score >= 10                          THEN 'Elite'
        WHEN RFM_Total_Score BETWEEN 7 AND 9               THEN 'Active & Engaged'
        WHEN RFM_Total_Score BETWEEN 5 AND 6               THEN 'At-Risk'
        ELSE                                                     'Lost/Inactive'
    END AS Customer_Segment
FROM rfm_combined
ORDER BY RFM_Total_Score DESC;

#5.Segment Summary
#Business question: How many customers and how much revenue is in each segment?

WITH customer_rfm AS (
    SELECT
        Cust_ID,
        COUNT(Trans_ID)                        AS Frequency,
        ROUND(SUM(Amount), 2)                  AS Monetary,
        DATEDIFF('2021-01-31', MAX(Trand_Dt))  AS Recency_Days
    FROM transactions
    WHERE Cust_ID IS NOT NULL
    GROUP BY Cust_ID
),
rfm_quartiles AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Recency_Days DESC)  AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency ASC)      AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC)       AS M_Score
    FROM customer_rfm
),
segments AS (
    SELECT *,
        (R_Score + F_Score + M_Score) AS RFM_Total_Score,
        CASE
            WHEN (R_Score + F_Score + M_Score) >= 10               THEN 'Elite'
            WHEN (R_Score + F_Score + M_Score) BETWEEN 7 AND 9     THEN 'Active & Engaged'
            WHEN (R_Score + F_Score + M_Score) BETWEEN 5 AND 6     THEN 'At-Risk'
            ELSE                                                         'Lost/Inactive'
        END AS Customer_Segment
    FROM rfm_quartiles
)
SELECT
    Customer_Segment,
    COUNT(Cust_ID)                                                        AS Customer_Count,
    ROUND(COUNT(Cust_ID) * 100.0 / SUM(COUNT(Cust_ID)) OVER(), 1)        AS Customer_Pct,
    ROUND(SUM(Monetary), 2)                                               AS Total_Revenue,
    ROUND(SUM(Monetary) * 100.0 / SUM(SUM(Monetary)) OVER(), 1)          AS Revenue_Pct,
    ROUND(AVG(Monetary), 2)                                               AS Avg_Revenue_Per_Customer,
    ROUND(AVG(Frequency), 1)                                              AS Avg_Transactions,
    ROUND(AVG(Recency_Days), 0)                                           AS Avg_Recency_Days
FROM segments
GROUP BY Customer_Segment
ORDER BY FIELD(Customer_Segment, 'Elite', 'Active & Engaged', 'At-Risk', 'Lost/Inactive');

#6. Non-Loyalty Customer Acquisition Targeting
#Business question: Which unknown customers behave like loyalty members and should be enrolled first?

SELECT
    Store_Type,
    Store_Name,
    Basket_Size_Category,
    COUNT(Trans_ID)           AS NonLoyalty_Transactions,
    ROUND(SUM(Amount), 2)     AS NonLoyalty_Revenue,
    ROUND(AVG(Amount), 2)     AS Avg_Basket,
    ROUND(MAX(Amount), 2)     AS Max_Basket
FROM transactions
WHERE Cust_ID IS NULL
GROUP BY Store_Type, Store_Name, Basket_Size_Category
ORDER BY NonLoyalty_Revenue DESC;

#7.Repeat Non-Loyalty Behavior by Store
#Business question: Are unknown customers returning to the same store? Repeat visits = prime enrollment candidates.

SELECT
    Store_Name,
    Store_Type,
    COUNT(Trans_ID)                    AS Total_NonLoyalty_Txns,
    ROUND(SUM(Amount), 2)              AS Total_Revenue,
    ROUND(AVG(Amount), 2)              AS Avg_Basket,
    COUNT(DISTINCT Month)         AS Active_Months
FROM transactions
WHERE Cust_ID IS NULL
GROUP BY Store_Name, Store_Type
HAVING Active_Months >= 6             
ORDER BY Total_Revenue DESC;

#8.Underperforming Brands Revenue Analysis
#Business question: Confirm the 28 brands below 0.5% and quantify the gap.

WITH brand_revenue AS (
    SELECT
        Brand,
        ROUND(SUM(Amount), 2)                                            AS Revenue,
        ROUND(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER(), 4)         AS Revenue_Pct,
        COUNT(Trans_ID)                                                  AS Transactions,
        COUNT(DISTINCT Cust_ID)                                          AS Unique_Customers
    FROM transactions
    GROUP BY Brand
)
SELECT *,
    CASE WHEN Revenue_Pct < 0.5 THEN 'Underperforming' ELSE 'Normal' END AS Brand_Status
FROM brand_revenue
ORDER BY Revenue_Pct ASC;

#9.Target Customers for Underperforming Brands
#Business question: Which loyalty customers buy in the same categories but haven't tried the weak brands? These are your promotion targets.

SELECT DISTINCT
    t.Cust_ID,
    COUNT(DISTINCT t.Brand)     AS Total_Brands_Purchased,
    ROUND(SUM(t.Amount), 2)     AS Total_Spend,
    ROUND(AVG(t.Amount), 2)     AS Avg_Basket
FROM transactions t
WHERE t.Cust_ID IS NOT NULL
AND t.Cust_ID NOT IN (
    SELECT DISTINCT Cust_ID
    FROM transactions
    WHERE Cust_ID IS NOT NULL
    AND Brand IN (
        'Al islami','Alsafa','Amul','Britannia','Carla',
        'Fresh express','Innov Asian','Kapol','LA CHOY','Little kids',
        'Maidamar','Mambalam iyer','Mother dairy','Mr. chewy','Naturals',
        "Nature's Fresh",'Priano','RNA','SARAS','Safal',
        'Shakti','Swad','Tandoor chef','Tang','Wanchai ferry',
        'Wellness','Yummiez','Zabiha halal'
    )
)
GROUP BY t.Cust_ID
HAVING Total_Spend > 5000           
ORDER BY Total_Spend DESC;

#10.Monthly Revenue Trend
#Business question: Is there seasonality? Which months peak? Useful for timing promotions.

SELECT
    Month,
    COUNT(Trans_ID)                                                                    AS Transactions,
    ROUND(SUM(Amount), 2)                                                              AS Total_Revenue,
    ROUND(SUM(CASE WHEN Cust_ID IS NOT NULL THEN Amount ELSE 0 END), 2)               AS Loyalty_Revenue,
    ROUND(SUM(CASE WHEN Cust_ID IS NULL     THEN Amount ELSE 0 END), 2)               AS NonLoyalty_Revenue,
    ROUND(SUM(CASE WHEN Cust_ID IS NOT NULL THEN Amount ELSE 0 END) * 100.0
          / SUM(Amount), 2)                                                            AS Loyalty_Pct
FROM transactions
GROUP BY Month
ORDER BY FIELD(Month,
    'January','February','March','April','May','June',
    'July','August','September','October','November','December');
