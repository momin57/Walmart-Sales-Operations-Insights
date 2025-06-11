# 🛒 Walmart Sales Operations Insights

This project analyzes 9,000+ sales records from Walmart using **Python**, **SQL**, and **Power BI** to uncover key business insights and improve operational decision-making.

## 📂 Dataset Source

- [Kaggle: Walmart 10k Sales Dataset](https://www.kaggle.com/datasets/najir0123/walmart-10k-sales-datasets)

---

## 🔧 Data Processing (Python)

- Imported the dataset and performed initial inspection (`.info()`, `.describe()`, `.head()`)
- Removed duplicates and rows with missing `quantity` or `unit_price`
- Cleaned `unit_price` column (removed `$` and converted to float)
- Created `total` column = `unit_price * quantity`
- Standardized column names to lowercase
- Uploaded cleaned dataset to SQL Server using `SQLAlchemy` and `pyodbc`

---

## 🧮 Data Analysis (SQL Server)

Solved the following business problems:

1. **Payment Method Analysis**  
2. **Top-Rated Category per Branch**  
3. **Busiest Day per Branch**  
4. **Items Sold by Payment Method**  
5. **Category Ratings by City**  
6. **Total Profit by Category**  
7. **Most Common Payment Method per Branch**  
8. **Sales Shifts Throughout the Day**  
9. **Branches with Highest Revenue Decline YoY (2022–2023)**

Techniques used: CTEs, Window Functions (RANK), `TRY_PARSE`, `DATENAME`, conditional `CASE`, and `JOIN`s.

---

## 📊 Dashboard & DAX Logic (Power BI)

### ➕ Calculated Columns
```DAX
SalesYear = YEAR(walmart_sales[formatted_date])

DayName = FORMAT(walmart_sales[formatted_date], "dddd")

TimeOfDay = 
VAR t = TIMEVALUE(walmart_sales[time])
RETURN
    SWITCH(
        TRUE(),
        t >= TIME(6, 0, 0) && t < TIME(12, 0, 0), "Morning",
        t >= TIME(12, 0, 0) && t < TIME(18, 0, 0), "Afternoon",
        t >= TIME(18, 0, 0) && t <= TIME(23, 59, 59), "Evening",
        "Night"
    )
```

### 📐 DAX Measures
```DAX
Average_Rating = ROUND(AVERAGE(walmart_sales[rating]), 2)
Max_Rating = MAX(walmart_sales[rating])
Min_Rating = MIN(walmart_sales[rating])

Revenue2022 = 
CALCULATE(
    SUM(walmart_sales[total]),
    walmart_sales[SalesYear] = 2022
)

Revenue2023 = 
CALCULATE(
    SUM(walmart_sales[total]),
    walmart_sales[SalesYear] = 2023
)

RevenueDeclinePercent = DIVIDE([Revenue2023] - [Revenue2022], [Revenue2022])

Total_Items_Sold = SUM(walmart_sales[quantity])
Total_Profit = ROUND(SUM(walmart_sales[profit]), 2)
Total_Revenue = ROUND(SUM(walmart_sales[total]), 2)
Total_Transactions = COUNT(walmart_sales[invoice_id])
```

### 📊 Summary Tables
```DAX
CategoryRatings =
SUMMARIZE(
    walmart_sales,
    walmart_sales[branch],
    walmart_sales[category],
    "AvgRating", ROUND(AVERAGE(walmart_sales[rating]), 2)
)

TransactionsByDay =
SUMMARIZE(
    walmart_sales,
    walmart_sales[branch],
    walmart_sales[DayName],
    "NumTransactions", COUNTROWS(walmart_sales)
)
```

### 🏆 Rankings
```DAX
RankByBranch = 
RANKX(
    FILTER(
        TableName, 
        TableName[branch] = EARLIER(TableName[branch])
    ),
    TableName[Metric], , DESC
)
```

---

## 📷 Dashboard Preview

![Dashboard](Images/Dashboard.png)

---

## 📁 Project Files

- `walmart_project.ipynb` – Python data prep notebook
- `SQLQuery1.sql` – Contains all SQL analysis
- `Dashboard.png` – Final Power BI visual
- `README.md` – Project documentation
- `Walmart.csv` – Original dataset
- `Walmart Business Problems.pdf` – Problem statements

---

## 💡 Key Insights

- Branch-specific customer preferences and transaction volumes
- Category performance varies by region and time
- Revenue drop analysis helps identify underperforming branches

---

## 🧰 Tools Used

- **Python**: pandas, sqlalchemy, pyodbc
- **SQL Server**: SQL queries, CTEs, functions
- **Power BI**: DAX measures, calculated columns, summary tables, KPI cards, bar charts

---
