Retail Sales Analytics Toolkit

An end-to-end analytics project on 528,962 real e-commerce transactions, built to demonstrate Excel (formulas, Power Query, VBA, What-If Analysis, Solver) and Tableau (LOD expressions, table calculations, parameters, dashboard actions) working together on the same dataset.

Data source

UCI Machine Learning Repository — Online Retail Data Set (Chen, D., 2015). Transactions from a UK-based online gift retailer, 1 Dec 2010 – 9 Dec 2011. Distributed under CC BY 4.0. Non-product line items (postage, bank charges, manual adjustments) were excluded during cleaning.

Note: the full transaction CSV (~50MB) is not committed to this repo — download it from the source above, or use data/real_monthly_sales_wide.xlsx for the smaller, ready-to-use version this project starts from.

Key findings (verified against the raw data)
£10,285,945.56 in total revenue across 20,545 orders, 4,073 products, 38 countries
85.2% of revenue comes from the United Kingdom (£8.76M); Netherlands, Ireland, Germany and France follow, each under 3%
November 2011 is the true peak month at £1.46M — revenue climbs steadily from a slow Feb–Apr 2011, then accelerates into the Sep–Nov holiday build-up
December 2011 (the final month) is a partial month — data stops on the 9th — so its lower total is a data cutoff, not a real decline
Top product by revenue: REGENCY CAKESTAND 3 TIER (£174,485), which anchors the Excel loan and Solver models below
Average order value: £500.65
Order value was concentrated at the lower end — most orders fell between £0–£400, with far fewer orders at the higher end of the range

Project structure
retail-sales-analytics-toolkit/
├── excel/
│   ├── portfolio_retail_toolkit.xlsx      # README, Monthly Sales (Wide/Long),
│   │                                       # Loan Amortization, Production Mix Solver
│   └── FormatMonthlySalesReport.bas       # VBA macro (dynamic LastRow formatting)
├── tableau/
│   └── Tableau_Dashboard_Spec.md          # Full build spec for the dashboard
├── data/
│   └── real_monthly_sales_wide.xlsx       # Top 10 products x 13 months, wide format
└── README.md

Excel workbook — what's inside

Monthly Sales (Wide → Long). Started from a pivoted top-10-products × 13-months report and unpivoted it with Power Query (Unpivot Other Columns), producing a clean Product/Month/Revenue table — verified total: £969,922.

VBA automation. FormatMonthlySalesReport formats that unpivoted table: bolds headers, autofits columns, adds a dynamic Total row and currency formatting, and borders the table — all using a LastRow pattern (Cells(Rows.Count, 1).End(xlUp).Row) instead of hardcoded row numbers, so it adapts to however many rows the export contains.

Loan Amortization. A real financing scenario sized off the top product's sales pattern (REGENCY CAKESTAND 3 TIER, ~£13,400 avg monthly revenue, £27,870 peak): a £25,000, 12-month facility at 7.5% APR. PMT/IPMT/PPMT build a full amortization schedule — £2,168.94/month, £1,027.23 total interest, both independently verified in Python.

Production Mix (Solver). A linear-programming model using the real average selling prices of the top two products (REGENCY CAKESTAND 3 TIER, JUMBO BAG RED RETROSPOT), a £15,000 budget and 350 sqft storage constraint. Solved with Simplex LP. True optimum: 0 cakestands, 10,080.65 jumbo bags, £10,000 profit — the jumbo bag's marginal profit-per-£-spent is very slightly higher, so budget concentrates entirely there.

Tableau dashboard

Built from the full 528,962-row cleaned transaction export. Includes:

{FIXED [Description] : SUM([Revenue])} for each product's all-time total
{EXCLUDE [Country] : SUM([Revenue])} for % of a product's revenue by country
A High Value Order calculated field driven by an Order Value Threshold parameter
A Running Total revenue trend (correctly partitioned by calendar month + year, not just month-of-year)
An Order Value Distribution chart (binned, built on {FIXED [InvoiceNo] : SUM([Revenue])} to get true per-order totals), showing most orders cluster in the £0–£400 range with a long tail of larger, less frequent orders
A Top 10 Country filter and cross-filter dashboard action between the country and trend views

Analysis summary: Among the top 10 countries, the UK had the highest revenue, crossing £8 million — over 85% of total revenue. "Regency Cakestand 3 Tier" had the strongest cumulative revenue of any product across the Dec 2010–Dec 2011 period. Order value was concentrated at the lower end, between £0–£400, with fewer orders at the higher end of the range.

Live dashboard: [Online Retail Analytics (UCI Dataset) — Tableau Public](https://public.tableau.com/app/profile/rohan.b2206/viz/OnlineRetailAnalyticsUCIDataset/Dashboard1)

Tools used

Excel (formulas, Data Validation, Conditional Formatting, Power Query, VBA, Goal Seek, Scenario Manager, Solver), Tableau (Calculated Fields, LOD expressions, Table Calculations, Parameters, Sets, Dashboard Actions), Python (pandas, for data cleaning and independent verification of every formula and optimization result in this project).
