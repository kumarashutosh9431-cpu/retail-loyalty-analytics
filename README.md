Retail Commercial Strategy & Loyalty Diagnostics

📌 Business Problem Statement

A multi-format grocery retailer operates 20 stores across three formats — Hypermarket, Supermarket, and Submarket — with a loyalty program that allows enrolled customers to earn and redeem benefits across all formats.
Despite having 1,000 enrolled loyalty members, loyalty sales contribute only 24.9% of total revenue (₹51.83L) — far below the industry benchmark of 35–40%. This represents a potential revenue gap of ₹2.1–₹3.1 Crore.

Two core business problems were investigated:

Loyalty Underperformance — Identify which customers to target to increase loyalty revenue contribution, and how to convert high-value unknown customers into the program
Brand Underperformance — Identify brands with <0.5% revenue contribution and develop a targeted customer list for promotional intervention

🛠️ Tools Used

Microsoft Excel - Data cleaning, column engineering, RFM scoring, pivot tables; MySQL(via DBeaver) - SQL aggregations, RFM NTILE scoring, customer segmentation queries; Power BI Desktop -Interactive 3-page dashboard — KPIs, RFM visuals, brand performance

SQL Concepts Applied

WITH CTEs · NTILE(4) window functions · DATEDIFF · CASE/WHEN · HAVING · Subqueries · Window aggregations (SUM() OVER())
Excel Features Used
IFS · SUMIF / COUNTIF / AVERAGEIF · ISBLANK · Conditional Formatting · PivotTables · Named Ranges
Power BI Features Used
DAX measures · Data Modeling (relationships) · Slicers · Drill-through · Conditional formatting on visuals · Constant reference lines

❓ Key Business Questions Answered

What is the current loyalty revenue contribution vs the expected benchmark?
Which loyalty customers are Champions, Active, At-Risk, or Dormant?
Which store formats have the lowest loyalty penetration?
Which non-loyalty customers are high-value and worth enrolling?
Which brands contribute less than 0.5% of total revenue?
Which loyalty customers have never purchased underperforming brands?
Is there a seasonal pattern in loyalty engagement?

🔍 Top 5 Findings

Finding 1 — The Loyalty Gap Is an Enrollment Problem, Not a Spend Problem
Loyalty customers and non-loyalty customers spend almost the same per visit — yet loyalty contributes only 24.9% of revenue.
Finding 2 — Loyalty Penetration Is Uniformly Low Across All Store Formats
Finding 3 — Elite Customers (26.3%) Drive 44.4% of Loyalty Revenue
RFM segmentation using NTILE(4) quartile scoring was applied to all 1,000 loyalty customers.
Finding 4 — 28 Brands Contribute Less Than 0.5% Each to Total Revenu
Finding 5 — Basket Size Distribution Reveals a Large Mid-Tier Opportunity

💡 Recommendations

Opportunity 1 — Re-engage At-Risk & Lost Customers
Target: 388 customers (232 At-Risk + 156 Lost/Inactive)
Estimated Revenue Impact: ₹2.76L
Send personalized re-engagement mailers to 232 At-Risk customers with a time-limited 15% discount voucher
Offer double loyalty points for the next 3 purchases to 156 Lost/Inactive customers
20% spend uplift on At-Risk (₹1.59L) + 30% reactivation of Lost/Inactive (₹1.17L) = ₹2.76L incremental revenue

Opportunity 2 — Convert High-Value Non-Loyalty Customers
Target: 10,694 non-loyalty transactions with basket ≥ ₹500
Estimated Revenue Impact: ₹1.55Cr (if 10% enrolled)
Deploy loyalty enrollment drives at top non-loyalty revenue stores (identified via SQL Query 7 — stores with high anonymous footfall across 6+ months)
Offer instant ₹50 cashback on enrollment for transactions above ₹300
Converting just 10% of non-loyalty customers at the average loyalty spend rate adds ₹1.55 Crore in identifiable revenue

Opportunity 3 — Promote Underperforming Brands to Targeted Customers
Target: Loyalty customers who have never purchased any of the 28 underperforming brands
Estimated Revenue Impact: ₹14.93L uplift
Run 2-week "brand discovery" promotions via the loyalty app — 3× points on first purchase of flagged brands
Target list generated via SQL cross-reference of loyalty customers vs underperforming brand purchase history
If all 28 brands reach the 0.5% threshold: revenue from this group grows from ₹14.26L → ₹29.19L (+₹14.93L)

⚠️ Limitations

Single category analysis — The dataset covers only the Food category. Findings may not generalize to other product categories the retailer carries.
No customer demographics — Without age, gender, or location data, customer segmentation is limited to behavioral (RFM) dimensions only. Demographic targeting could further sharpen campaign precision.
Loyalty program mechanics unknown — The dataset does not contain information on points earned, redemptions, or tier structures. This limits the ability to assess whether the loyalty program design itself is contributing to low engagement.
Non-loyalty customers are untracked — The 50,259 non-loyalty transactions have no customer identifier, making it impossible to distinguish between one-time visitors and frequent anonymous shoppers. Repeat visit behavior cannot be confirmed.
No competitor or external data — The analysis is based solely on internal transaction data. External benchmarks (market share, competitor loyalty performance) were not available for comparison.
