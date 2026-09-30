# Tableau Dashboard — Build Specification

**Data source:** `real_online_retail_transactions.csv` (528,962 real transactions, UCI Online Retail dataset, connect as a Live connection or Extract)

This file lists every field, calculation, and dashboard element to build in Tableau Desktop. Build order matches the logical dependency chain — earlier items are needed by later ones.

## 1. Connect & inspect
- Data → New Data Source → Text File → `real_online_retail_transactions.csv`
- Confirm 8 fields: InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, Revenue, CustomerID, Country
- `InvoiceDate` should auto-detect as a Date field (real dates, not text — no month-ordering workaround needed this time)

## 2. Calculated Fields

**Product Annual Revenue** (FIXED LOD)
```
{FIXED [Description] : SUM([Revenue])}
```
Use case: tooltip or reference line showing a product's full-period total regardless of the current date/country filter.

**% of Country Total** (EXCLUDE LOD)
```
SUM([Revenue]) / SUM({EXCLUDE [Country] : SUM([Revenue])})
```
Use case: what share of a product's global revenue comes from each country.

**High Value Order** (Parameter-driven)
1. Create Parameter `Order Value Threshold` — Integer, Range 0–500, default 50
2. Calculated field:
```
IF [Revenue] > [Order Value Threshold] THEN "Above" ELSE "Below" END
```

## 3. Sheet 1 — Revenue Trend (Running Total)
- Columns: `InvoiceDate` (set to continuous Month)
- Rows: `SUM(Revenue)`
- Add Table Calculation: Running Total, Compute Using → Specific Dimensions → check only Month (not Description) if broken out by product on Color
- Color: `Description` (filter to Top 10 products first, via a Set — see below)

## 4. Sheet 2 — Country Contribution
- Rows: `Country`
- Columns: `SUM(Revenue)`
- Sort descending
- Filter: Top 10 by Sum of Revenue (right-click Country → Create → Set → Top tab)

## 5. Sheet 3 — Top Products Set
- Right-click `Description` → Create → Set → Top tab → Top 10 by Sum(Revenue)
- Name: `Top 10 Products`
- Use as a filter across other sheets for consistency

## 6. Dashboard
- New Dashboard → drag Sheet 1 and Sheet 2 onto the canvas
- Show Parameter control: right-click `Order Value Threshold` → Show Parameter
- Dashboard → Actions → Add Action → Filter: Source = Sheet 2 (Country), Target = Sheet 1 → click a country, Sheet 1 filters to it

## 7. Publish
- Server → Tableau Public → Save to Tableau Public (or Save to your Tableau Server if using Desktop with a license)
- Grab the public embed link for the portfolio README

## Real-data notes worth calling out in the dashboard
- December 2010 is the true seasonal peak (verify: filter to United Kingdom, Month = Dec-2010)
- Data ends 09/12/2011 — the final month is a **partial month**, not a real decline; worth a text annotation on the dashboard so it isn't misread
- "PAPER CRAFT, LITTLE BIRDIE" has a single extreme month (Dec-2011) — worth excluding or footnoting if using this product in any averaged metric
