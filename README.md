# Superstore Sales Analysis - SQL

**Business Question:** Which regions, product categories and customer segments are driving revenue - and where are we losing money through discounting?

## Project Overview
This project uses SQL to analyse four years of retail sales data (2014 = 2017) across 120 orders, 50 customers and 40 products. The analysis covers revenue performance, profitability by category, customer segmentation, shipping behaviour and the impact of discounts on profit margins.

This is the SQL companion to the [Python Superstore EDA](https://github.com/marvalex4/superstore-eda), demonstrating the same business problem solved with a different tool - a deliberate choice to show that the right tool depends on the context, not habit.

## Tools Used
- **SQLite** - database engine (runs locally with no setup)
- **DBeaver** - GUI for running queries and viewing results
- **SQL** - window functions, JOINs, subqueries, CASE statements, date functions

## Database Schema
Four tables connected in a star schema:


| Table        | Rows| Description                                     |
|              |     |                                                 |
| `customers`  | 50  | Customer name, segment, city, state, region     |
| `products`   | 40  | Product name, category, sub-category            |
| `orders`     | 120 | Order date, ship date, ship mode, customer      |
| `order_items`| 240 | Sales, quantity, discount, profit per line item |

## Business Questions Answered
### 1. Revenue Overview
- What are total sales, profit and margin across the dataset?
- How did sales trend year-over-year from 2014 to 2017?
### 2. Regional Performance
- Which regions generate the most revenue and profit?
- Which states are the strongest performers?
### 3. Category & Product Analysis
- How do the three categories (Technology, Furniture, Office Supplies) compare on sales and profit?
- Which sub-categories are the most and least profitable?
- Which products are losing money despite generating sales?
### 4. Customer Analysis
- Who are the top 10 customers by revenue?
- Which customer segment (Consumer, Corporate, Home Office) is most valuable?
- What is the average order value per segment?
### 5. Shipping Analysis
- How does shipping mode affect order volume and revenue?
- What is the average fulfilment time per shipping method?
### 6. Discount Impact
- How do different discount levels affect profit margin?
- Are heavy discounts destroying profitability in specific categories?
### 7. Window Functions
- Products ranked by sales within each category using `RANK() OVER (PARTITION BY ...)`
- Year-over-year growth with running totals using `SUM() OVER` and `LAG()`

## Key Findings

**Technology drives the most profit** despite not having the highest order volume. Networking equipment and phones deliver strong margins when sold without discounts.

**Furniture is a margin risk.** Tables and chairs sold with 20% discounts flip profitable orders into losses. The data shows a clear pattern: discount above 10% on Furniture and profit turns negative.

**The West region leads in sales volume**, driven by California customers in the Corporate and Home Office segments.

**Standard Class shipping handles the majority of orders** but First Class customers tend to place higher-value orders.

**Discounting above 20% consistently destroys profit** across all categories. The no-discount cohort has the strongest margin.

## Query Results

### Annual Sales Trend
![Annual Trend](screenshots/Screenshot_2026-06-30_003441.png)

### Sales by Region
![Regional Performance](screenshots/Screenshot_2026-06-30_003305.png)

### Sales by Category
![Category Analysis](screenshots/Screenshot_2026-06-30_003201.png)

### Loss-Making Products
![Loss Making Products](screenshots/Screenshot_2026-06-30_003040.png)

### Products Ranked Within Category (Window Function)
![Window Function](screenshots/Screenshot_2026-06-30_004753.png)

## How to Run
1. Download [DBeaver](https://dbeaver.io/) — free
2. Create a new SQLite connection and save the database as `superstore.db`
3. Open `01_create_database.sql` and run it to build and populate all tables
4. Open `02_analysis_queries.sql` and run any query

## Files
superstore-sql-analysis/
01_create_database.sql    # Schema creation + all seed data
02_analysis_queries.sql   # 15 business queries with comments
screenshots/              # Query result screenshots
README.md

## What I Learned

**Schema design matters.** Splitting order headers from order line items made every aggregation query cleaner than a flat file would allow.
**Window functions are powerful.** `RANK() OVER (PARTITION BY category)` in a single query replaces what would take multiple dataframes and merges in pandas.
**SQL forces you to be explicit.** Every JOIN, GROUP and filter is visible, which makes the logic easier to audit and explain to stakeholders.

---

*Part of the [Marvis Obanor Data Analyst Portfolio](https://github.com/marvalex4)*
