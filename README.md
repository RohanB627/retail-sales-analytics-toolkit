Retail Sales Analytics Toolkit

An end-to-end analytics project on 528,960 real e-commerce transactions, built to show Excel (formulas, Power Query, VBA, What-If Analysis, Solver) and Tableau (LOD expressions, table calculations, parameters, dashboard actions) working together on the same dataset.

I've worked mainly in Power BI. This was my first project built entirely in Tableau, and I made it to test which of my skills carry over from one BI tool to another.

📊 Live dashboard on Tableau Public

Data source

UCI Machine Learning Repository — Online Retail Data Set (Chen, D., 2015). Transactions from a UK-based online gift retailer, 1 Dec 2010 – 9 Dec 2011. Distributed under CC BY 4.0.

The full transaction CSV (~50 MB) isn't committed to this repo. Download it from the link above, or start from Data/real_monthly_sales_wide.xlsx, the smaller, ready-to-use version this project begins with.

Cleaning steps
Step	What was removed	Why
1	Non-product lines (postage, bank charges, manual adjustments)	They're fees and corrections, not product sales
2	Cancellation rows (invoice numbers starting with C, negative quantity)	They reverse earlier orders
3	Invoices 541431 and 581483	Each was a single very large order (74,215 storage jars, £77,184, and 80,995 paper craft kits, £168,470) that was cancelled within minutes. Step 2 removed the cancellation rows but left these original orders in, which added £245,653 of revenue that never happened

The third step was a lesson in itself. In the Revenue Trend chart, one product showed a perfectly flat line all year, and that's how the problem showed up. Removing cancellation rows isn't the same as removing cancelled orders. In Tableau, the exclusion is applied as a data source filter, so it takes effect before the Top 10 is calculated.

Key findings

All figures checked independently against the raw data in Python.

£10,040,292 in total revenue across 20,543 orders, 3,900+ products and 38 countries
84.8% of revenue comes from the United Kingdom (£8.52M). The Netherlands (2.8%), EIRE (2.7%), Germany (2.0%) and France (1.8%) follow.
Only 23% of orders are over £500, but they bring in 66% of revenue. A small group of large orders drives the business.
69% of orders are £400 or less. Average order value is £488.75, pulled up by a long tail of large orders.
November 2011 is the peak month at £1.46M. Revenue is slow from February to April 2011, then rises steadily into the September–November holiday period.
December 2011 is a partial month. The data stops on the 9th, so its lower total reflects the cutoff, not a real decline.
Top product: REGENCY CAKESTAND 3 TIER (£174,485). This is the product the Excel loan and Solver models are built around.
Project structure
retail-sales-analytics-toolkit/
├── Data/
│   └── real_monthly_sales_wide.xlsx       # Top 10 products × 13 months, wide format
├── Excel/
│   ├── portfolio_retail_toolkit.xlsx      # Monthly Sales (Wide/Long), Loan Amortization,
│   │                                      # Production Mix Solver
│   ├── Retail sales - modified.xlsm       # Macro-enabled workbook with the VBA module
│   └── FormatMonthlySalesReport.bas       # VBA macro (exported module)
├── Tableau/
│   ├── Online_Retail_Analytics.twbx       # Packaged Tableau workbook
│   └── Tableau_Dashboard_Spec.md          # Full build spec for the dashboard
└── README.md
Excel workbook

Monthly Sales (Wide → Long). I started from a pivoted report (top 10 products × 13 months) and used Power Query's Unpivot Other Columns to turn it into a clean Product / Month / Revenue table.

VBA automation. The FormatMonthlySalesReport macro formats the unpivoted table. It bolds the headers, autofits the columns, adds a dynamic Total row and currency formatting, and puts borders on the table. It finds the last row with Cells(Rows.Count, 1).End(xlUp).Row instead of a hardcoded row number, so it works however many rows the export contains.

Loan Amortization. A financing scenario sized from the top product's sales pattern (REGENCY CAKESTAND 3 TIER, about £13,400 average monthly revenue and a £27,870 peak): a £25,000, 12-month loan at 7.5% APR. PMT, IPMT and PPMT build the full schedule: £2,168.94 a month and £1,027.23 total interest, both checked independently in Python.

Production Mix (Solver). A linear programming model using the real average selling prices of the top two products, with a £15,000 budget and 350 sq ft of storage. It's solved with Simplex LP. The optimum puts the whole budget into jumbo bags: 10,080.65 units for £10,000 profit. Their profit per £ spent is slightly higher, so the model allocates nothing to cakestands.

Note: the top-10 snapshot in Data/real_monthly_sales_wide.xlsx was taken before step 3 of the cleaning, so it still includes the two products affected by the cancelled orders. The loan and Solver models are based on REGENCY CAKESTAND 3 TIER and JUMBO BAG RED RETROSPOT, which the cancelled orders don't affect.

Tableau dashboard

Built from the full cleaned transaction export (528,960 rows).

Feature	How it's built
Each product's all-time revenue	{FIXED [Description] : SUM([Revenue])}
A product's revenue share by country	SUM([Revenue]) / SUM({EXCLUDE [Country] : SUM([Revenue])})
High Value Order flag	IF {FIXED [InvoiceNo] : SUM([Revenue])} > [Order Value Threshold] THEN "Above" ELSE "Below" END. This compares the whole order's value, not individual line items, and is controlled by a parameter slider
Revenue Trend	Running total, partitioned by calendar month + year (not just month-of-year)
Order Value Distribution	Histogram of true per-order totals ({FIXED [InvoiceNo] : SUM([Revenue])})
Interactivity	Top 10 country filter. Clicking a country filters the trend and distribution charts, and clearing the selection shows all values again
Data quality	Data source filter that excludes the two cancelled orders before the Top N is calculated
Power BI → Tableau: what carried over
Concept	Power BI (DAX)	Tableau
Total that ignores the view's filters	CALCULATE(SUM(...), ALLEXCEPT(...))	{FIXED [dim] : SUM(...)}
Remove one dimension from the context	CALCULATE(SUM(...), ALL(Table[Country]))	{EXCLUDE [Country] : SUM(...)}
Running total	Measure with FILTER(ALL(Date), Date <= MAX(Date))	Table calculation (Running Total)
What-if input	What-if parameter	Parameter + calculated field
Tools used
Excel: formulas, Data Validation, Conditional Formatting, Power Query, VBA, Goal Seek, Scenario Manager, Solver
Tableau: calculated fields, LOD expressions, table calculations, parameters, sets, dashboard actions, data source filters
Python (pandas): data cleaning, and independent checks of every formula, total and optimisation result in this project
