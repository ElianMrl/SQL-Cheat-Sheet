use BaseBall_Summer_2023;
go
---Basic Select Clause
select * from people

-- 1. Using the IS631View included in the database, you want to know who the top pitchers were in
-- terms of strike outs. Write a query that provides the playerid and the Career SO values and uses the
-- RANK function to rank players by the column Career SO in descending order. Exclude players that
-- are not pitchers (career SO is null). This query should return 10,384 rows.

SELECT playerid, [Career SO], RANK() OVER (ORDER BY [Career SO] DESC) AS SO_Rank
FROM IS631View
WHERE [Career SO] IS NOT NULL
ORDER BY [Career SO] DESC;

-- 2. When you change the query to rank in ascending order so you can see who the worst pitchers
-- were, you notice pitchers with a career SO of 0 are all ranked as a 1 and then the rank jumps to 755
-- for pitchers who have 1 Career SO. You feel this is misleading. Use the Dense rank function to
-- eliminate the gaps in the rank number. Write a query that provides the playerid and the Career SO
-- values and uses the RANK function to rank players by the column Career SO in ascending order.
-- Exclude players that are not pitchers (career SO is null) This query should return 10,384 rows.
-- Starting in row 753, you should have the following results

SELECT playerid, [Career SO], DENSE_RANK() OVER (ORDER BY [Career SO] ASC) AS SO_Rank
FROM IS631View
WHERE [Career SO] IS NOT NULL
ORDER BY [Career SO] ASC;

-- 3. You decide to get better information, you want to group the players by the last year they played
-- and then rank them. Using the partition by parameter, write a query that provides the playerid and
-- the Career SO values and uses the RANK function to rank players by the column Career SO in
-- descending order. Exclude players that are not pitchers (career SO is null). Order your results by
-- lastplayed in descending order so you seen the most recent players first.

SELECT playerid, LastPlayed, [Career SO], 
    DENSE_RANK() OVER (PARTITION BY LastPlayed ORDER BY [Career SO] DESC) AS SO_Rank
FROM IS631View
WHERE [Career SO] IS NOT NULL
ORDER BY LastPlayed DESC;

-- 4. You feel this is too much information. Modify your query for question 3 to only show the players
-- with a rank of 3 or less. This query should return 452 rows.

WITH PitchersTable AS (
    SELECT playerid, LastPlayed, [Career SO], 
        DENSE_RANK() OVER (PARTITION BY LastPlayed ORDER BY [Career SO] DESC) AS SO_Rank
    FROM IS631View
    WHERE [Career SO] IS NOT NULL
)
SELECT playerid, lastplayed, [Career SO], SO_Rank
FROM PitchersTable
WHERE SO_Rank <= 3
ORDER BY lastplayed DESC;


-- 5. You decide that the rank function isn’t giving you the information you need and you decide you
-- want to see where pitchers stand from a percentage standpoint. Use the Percent_rank function. I
-- did not like the top pitchers being at the bottom of the list, so I used 1-the rank function to get the
-- top players first. This query returns 10,384 rows.

SELECT playerid, [Career SO], 1 - Percent_rank() OVER (ORDER BY [Career SO] DESC) AS SO_Rank
FROM IS631View
WHERE [Career SO] IS NOT NULL
ORDER BY [Career SO] DESC;

-- 6. I wanted to see who the “average” pitchers were. Using the cume_dist function, write a query the
-- shows the player that are between .4 and .6 in the distribution. This query returns 2,101 rows.

WITH PitchersTable AS (
    SELECT playerid, [Career SO], cume_dist() OVER (ORDER BY [Career SO] DESC) AS SO_Rank
    FROM IS631View
    WHERE [Career SO] IS NOT NULL 
)
SELECT playerid, [Career SO], SO_Rank
FROM PitchersTable
WHERE SO_Rank BETWEEN 0.4 AND 0.6
ORDER BY [Career SO] ASC;


-- 7. You were told that the SALARIES table does not have any primary keys because no one knew how
-- to eliminate the duplicate rows. Using the row_number function, write a query that deletes the
-- rows that would cause duplicate keys. The primary key would be the yearid, teamid, lgid and
-- playerid columns. Hint: you need a subquery to calculate the row_number and then the main
-- query would delete the rows where rank is > 1. I find it easiest to create the subquery using a WITH
-- statement. You may also want to create a backup of the SALARIES table to test with, so you do not
-- need to restore the database if you make a mistake. You can create a table to test with by running
-- the following SQL:

IF OBJECT_ID (N'dbo.salaries_backup', N'U') IS NOT NULL
DROP TABLE [dbo].[salaries_backup]
GO
select * into salaries_Backup from salaries

-- You can then use the SALARIES_BACKUP table for testing. Your query should delete 1,826 rows.

WITH salaries_count_row AS (
    SELECT yearid, teamid, lgid, playerid,
        ROW_NUMBER() OVER (PARTITION BY yearid, teamid, lgid, playerid ORDER BY (SELECT NULL)) AS row_number_count
    FROM salaries_backup
)
DELETE FROM salaries_count_row
WHERE row_number_count > 1;


-- 8. Using the Salaries table, write a query that compares the averages salary by team and year with
-- the windowed average (also called moving average) of the 3 prior years and the 1 year after the
-- current year. This query returns 1,068 rows. Note: I used a subquery to calculate the team’s
-- average salary and use the results of the subquery to get the windowed average. This query
-- should return 1,068 Rows.
-- Windowed averages are used to smooth data. Note the average goes down on 2001 and then up in 2002
-- while the windowed average shows a steady increase.

WITH TeamYearlyAvg AS (
    SELECT teamID, yearID, AVG(salary) AS Avg_Salary
    FROM Salaries
    GROUP BY teamID, yearID
)
SELECT teamID, yearID, Avg_Salary,
    AVG(Avg_Salary) OVER (PARTITION BY teamID ORDER BY yearID 
        ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING) AS Windowed_Salary -- 3 prior years and 1 year after the current year
FROM TeamYearlyAvg
ORDER BY teamID, yearID;


-- Using a recursive CTE, write a query that will generate the Months of the year using the function
-- DATENAME(MONTH, DATE)
-- Your query must recurse and use Monthnumber+1 to get the next month. Make sure you include a GO
-- statement before the CTE. The output should be

-- NOTE: DATENAME(interval, date) returns an specific part of a date. For example: 
SELECT DATENAME(YEAR, '2017/08/25'); -- Returns the year from the date '2017/08/25'
SELECT DATENAME(MONTH, '2017/08/25'); -- Returns the month from the date '2017/08/25'

-- NOTE: DATEFROMPARTS(year, month, day)  Return a date from its parts. For example:
SELECT DATEFROMPARTS(2024, 10, 15);

-- NOTE: Combine these two functions together I can extract the month name based on a number:
SELECT DATENAME(MONTH, DATEFROMPARTS(2024, 10, 15))

-- All together to make a recursive query that output all the months of the year
WITH Months_Table AS (

    -- Anchor member initialization
    SELECT 1 AS MonthNumber
    UNION ALL

    -- Recursive member definition
    SELECT MonthNumber + 1
    FROM Months_Table
    WHERE MonthNumber < 12
)
SELECT MonthNumber, 
    DATENAME(MONTH, DATEFROMPARTS(2024, MonthNumber, 15)) AS Month_Name
FROM Months_Table;


-- 10. Using a query with the PIVOT option (see slide 26 of the Chapter 14 - Data Warehouse Presentation
-- 2022 Summer in Module 6 – Advanced SQL module), using the batting table write a query that
-- shows the number of home hrs (hr) hit in the last 5 years of each century (1895 to 1899, 1995 to
-- 1999 and 2018 to 2022) you want to use this data to see if the number of home runs hit has
-- increased over time. You must code each of the years individually in the IN clause of the PIVOT
-- statement and enclose each year in brackets. The IN statement would start with yearid in ([1895],
-- [1896], [1897],... This query should return 149 rows.

SELECT *
FROM (SELECT yearID, HR, teamID
    FROM batting
) AS P
PIVOT (
    SUM(HR)
    FOR yearID IN ([1895], [1896], [1897], [1898], [1899], [1995], [1996], [1997], [1998], [1999], [2018], [2019], [2020], [2021], [2022])
) AS PivotTable;


