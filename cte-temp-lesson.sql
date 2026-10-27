/*
CTE Subquery TempTable Comparison 

Calculate the total price of all properties sold in each financial year,which starts on 1st April.
We implement this in three ways using 
- a temporary table
- a common table expression (CTE) and the WITH statement
- a simple (self-contained) subquery

*/
-- We use a CASE statement to create a FinancialYear column

-- Return up to 100 property transactions with their transaction details, calendar year,
-- and financial year. The financial year starts in April: April–December use the
-- transaction year and following year; January–March use the previous and current years.
SELECT TOP 100 pp.TransactionID,
               pp.TransactionDate,
               pp.Price,
               DATEPART(YEAR, pp.TransactionDate) AS CalendarYear,
            -- In plain English: if the sale happened in April or later, label it with the current year
            -- and the following year (for example, April 2023 becomes FY 2023-2024). Otherwise,
            -- label it with the previous year and the current year (for example, March 2023 becomes FY 2022-2023).
            CASE WHEN DATEPART(MONTH, PP.TransactionDate) >= 4 THEN CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate), '-', DATEPART(YEAR, pp.TransactionDate) + 1) 
               ELSE CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate) - 1, '-', DATEPART(YEAR, pp.TransactionDate)) END AS FinancialYear
FROM   PricePaidSW12 AS pp;

/*
Use a temporary table
Microsoft T-SQL only
*/


DROP TABLE IF EXISTS #sale;

SELECT pp.TransactionID,
       pp.TransactionDate,
       pp.Price,
       DATEPART(YEAR, pp.TransactionDate) AS CalendarYear,
       CASE WHEN DATEPART(MONTH, PP.TransactionDate) >= 4 THEN CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate), '-', DATEPART(YEAR, pp.TransactionDate) + 1) ELSE CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate) - 1, '-', DATEPART(YEAR, pp.TransactionDate)) END AS FinancialYear
INTO   #sale
FROM   PricePaidSW12 AS pp;

SELECT TOP 25 *
FROM   #sale;

SELECT   #sale.FinancialYear,
         SUM(#sale.Price) / 1000000.0 AS TotalPriceInMillions
FROM     #sale
GROUP BY #sale.FinancialYear
ORDER BY #sale.FinancialYear;

/*
Use a common table expression CTE and the WITH statement
*/
WITH     sale
AS       (SELECT pp.TransactionID,
                 pp.TransactionDate,
                 pp.Price,
                 DATEPART(YEAR, pp.TransactionDate) AS CalendarYear,
                 CASE WHEN DATEPART(MONTH, PP.TransactionDate) >= 4 THEN CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate), '-', DATEPART(YEAR, pp.TransactionDate) + 1) ELSE CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate) - 1, '-', DATEPART(YEAR, pp.TransactionDate)) END AS FinancialYear
          FROM   PricePaidSW12 AS pp)
SELECT   sale.FinancialYear,
         SUM(sale.Price) / 1000000.0 AS TotalPriceInMillions
FROM     sale
GROUP BY sale.FinancialYear
ORDER BY sale.FinancialYear;

/*
Use a simple subquery
*/
SELECT   sale.FinancialYear,
         SUM(sale.Price) / 1000000.0 AS TotalPriceInMillions
FROM     (SELECT pp.TransactionID,
                 pp.TransactionDate,
                 pp.Price,
                 DATEPART(YEAR, pp.TransactionDate) AS CalendarYear,
                 CASE WHEN DATEPART(MONTH, PP.TransactionDate) >= 4 THEN CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate), '-', DATEPART(YEAR, pp.TransactionDate) + 1) ELSE CONCAT('FY ', DATEPART(YEAR, pp.TransactionDate) - 1, '-', DATEPART(YEAR, pp.TransactionDate)) END AS FinancialYear
          FROM   PricePaidSW12 AS pp) AS sale
GROUP BY sale.FinancialYear
ORDER BY sale.FinancialYear;


-- END
/*
Oracle version
Option 1: Use a common table expresion CTE and the WITH statement

WITH sale AS (
SELECT 
       pp.TransactionID,
       pp.TransactionDate,
       pp.Price,
       EXTRACT(YEAR FROM pp.TransactionDate) AS CalendarYear,
       CASE
           WHEN EXTRACT(MONTH FROM pp.TransactionDate) >= 4 THEN
               'FY '|| TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate)) || '-' || TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate) + 1 )
           ELSE
               'FY '|| TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate) - 1)  || '-' || TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate))
       END FinancialYear
FROM PricePaidSW12 pp
)
SELECT 
    sale.FinancialYear,
    SUM(sale.Price) /1000000.0 AS TotalPriceInMillions
 FROM sale
 GROUP BY sale.FinancialYear
 ORDER BY sale.FinancialYear;
*/
/*
 Oracle version
SELECT 
       pp.TransactionID,
       pp.TransactionDate,
       pp.Price,
       EXTRACT(YEAR FROM pp.TransactionDate) AS CalendarYear,
       CASE
           WHEN EXTRACT(MONTH FROM pp.TransactionDate) >= 4 THEN
               'FY '|| TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate)) || '-' || TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate) + 1 )
           ELSE
               'FY '|| TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate) - 1)  || '-' || TO_CHAR(EXTRACT(YEAR FROM pp.TransactionDate))
       END FinancialYear
FROM PricePaidSW12 pp
FETCH FIRST 100 ROWS ONLY;
 */
/*
Option 2: Use a simple subquery
Oracle version

