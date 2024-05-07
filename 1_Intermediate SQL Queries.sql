use BaseBall_Summer_2023;
go
---Basic Select Clause to make sure that we are connected to the Database
SELECT * FROM People;

-- 1. Write a query that lists the playerid, birthcity, birthstate, Home Runs (HR), Runs Batted In (RBI), At Bats
-- (AB) salary and batting average for all players born in Texas sorted by first name and year in ascending
-- order using the PEOPLE, SALARIES and BATTING tables. The joins must be made using the WHERE
-- clause. Make sure values are properly formatted. Sort your results by namefirst and yearid.
-- Note: your query should return 4,337 rows using the where statement to resolve divide by zero error or
-- 1,239 rows using nullif.

-- Joining tables in the WHERE clause
SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average]
FROM People, Salaries, Batting
WHERE People.playerID = Batting.playerID AND
    People.playerID = Salaries.playerID AND 
    Batting.teamID = Salaries.teamID AND 
    Batting.yearID = Salaries.yearID AND
    birthState = 'TX' AND 
    AB > 0
ORDER BY People.nameFirst, Batting.yearID ASC;

-- Using the JOIN clause to join the tables
SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average]
FROM People 
JOIN Batting ON People.playerID = Batting.playerID
JOIN Salaries ON People.playerID = Salaries.playerID AND 
    Batting.yearID = Salaries.yearID AND 
    Batting.teamID = Salaries.teamID
WHERE birthState = 'TX' AND 
    AB > 0
ORDER BY People.nameFirst, Batting.yearID ASC;


-- 2. Now take the query in #1 and add the schoolid from the CollegePlaying table to the query. This will
-- return 1,910 rows using the where statement to resolve divide by zero error.
SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average],
    schoolID
FROM People, Salaries, Batting, CollegePlaying
WHERE People.playerID = Batting.playerID AND
    People.playerID = Salaries.playerID AND 
    Batting.teamID = Salaries.teamID AND 
    Batting.yearID = Salaries.yearID AND
    People.playerID = CollegePlaying.playerID AND
    birthState = 'TX' AND 
    AB > 0
ORDER BY People.nameFirst, Batting.yearID ASC;

-- Using the JOIN clause to join the tables
SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average],
    schoolID
FROM People 
JOIN Batting ON People.playerID = Batting.playerID
JOIN Salaries ON People.playerID = Salaries.playerID AND 
    Batting.yearID = Salaries.yearID AND 
    Batting.teamID = Salaries.teamID
JOIN CollegePlaying ON People.playerID = CollegePlaying.playerID
WHERE birthState = 'TX' AND 
    AB > 0
ORDER BY People.nameFirst, Batting.yearID ASC;


-- 3. Now add a clause in the where statement to only show players who went to school between 1970 and
-- 1980 using a BETWEEN clause in the where statement. This will return 140 rows using the where
-- statement to resolve divide by zero error.

SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average],
    schoolID
FROM People, Salaries, Batting, CollegePlaying
WHERE People.playerID = Batting.playerID AND
    People.playerID = Salaries.playerID AND 
    Batting.teamID = Salaries.teamID AND 
    Batting.yearID = Salaries.yearID AND
    People.playerID = CollegePlaying.playerID AND
    birthState = 'TX' AND 
    AB > 0 AND 
    CollegePlaying.yearID BETWEEN 1970 AND 1980
ORDER BY People.nameFirst, Batting.yearID ASC;

-- Using the JOIN clause to join the tables
SELECT People.playerID, birthCity, birthState, Batting.teamID, HR, RBI, AB, Batting.yearID, format(salary,'C') AS Salary, 
    Convert(decimal(5,4),(H*.1/AB)) AS [Batting Average],
    schoolID
FROM People 
JOIN Batting ON People.playerID = Batting.playerID
JOIN Salaries ON People.playerID = Salaries.playerID AND 
    Batting.yearID = Salaries.yearID AND 
    Batting.teamID = Salaries.teamID
JOIN CollegePlaying ON People.playerID = CollegePlaying.playerID
WHERE birthState = 'TX' AND 
    AB > 0 AND 
    CollegePlaying.yearID BETWEEN 1970 AND 1980
ORDER BY People.nameFirst, Batting.yearID ASC;


-- 4. You are now interested in the longevity of players careers. Using the BATTING table and the appropriate
-- SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the
-- same teams in 2016 and 2021. Your query only needs to return the playerid and teamids. The query
-- should return 138 rows.

SELECT playerID, teamID
FROM Batting
WHERE yearID IN (2016, 2021)
GROUP BY playerID, teamID
HAVING COUNT(DISTINCT yearID) = 2
ORDER BY playerID;

-- Another way of doing this: 
SELECT playerID, teamID FROM Batting WHERE yearID = 2016
INTERSECT 
SELECT playerID, teamID FROM Batting WHERE yearID = 2021
ORDER BY playerID, teamID;

-- 5. Using the BATTING table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint
-- presentation, find the players that played for the different teams in 2016 and 2021 Your query only
-- needs to return the playerids and the 2016 teamid. The query should return 1,344 rows.

-- First Try: FAILED
-- WITH year2016 AS (
--     SELECT playerID, teamID
--     FROM Batting
--     WHERE yearID = 2016
-- ),
-- year2021 AS (
--     SELECT playerID, teamID
--     FROM Batting
--     WHERE yearID = 2021
-- )
-- SELECT year2016.playerID, year2016.teamID
-- FROM year2016
-- LEFT JOIN year2021 ON year2016.playerID = year2021.playerID -- LEFT JOIN ensures that all records from the left table (year2016) are returned, and if there's a matching record in the right table (year2021), those values are returned. Otherwise, the right table columns will be filled with NULLs.
-- WHERE year2021.playerID IS NULL OR year2016.teamID != year2021.teamID
-- ORDER BY year2016.playerID;

-- Second Try: FAILED
-- SELECT playerID, teamID
-- FROM Batting
-- WHERE playerID NOT IN (
--     SELECT playerID
--     FROM Batting
--     WHERE yearID IN (2016, 2021)
--     GROUP BY playerID, teamID
--     HAVING COUNT(DISTINCT yearID) = 2) AND 
--     yearID = 2016
-- ORDER BY playerID;

SELECT playerID, teamID FROM Batting WHERE yearID = 2016
EXCEPT 
SELECT playerID, teamID FROM Batting WHERE yearID = 2021
ORDER BY playerID, teamID;



-- 6. You’ve been asked by the data entry department to provide a list of rows in the SALARIES table that are
-- missing salaries so they can fix them. Write a query that returns the playerid, yearid and teamid for the
-- rows missing salary information sorted by teamid and yearid. This query should return 40 rows.
SELECT playerID, yearID, teamID
FROM Salaries
WHERE salary IS NULL;



-- 7. You and a friend are discussing if it is worth while for a baseball player to go to college. Write a query
-- that shows the playerid, the number of colleges they attended, the first and last year they attended,
-- and the number of semesters they attended college using the CollegePlaying table. This query will
-- return 6,570 rows.

-- I am assuming that one year is equal to 2 semesters but it looks like that I am not getting the correct number of 
-- semesters as the example solution from question 7 so the following is not correct: 
-- (MAX(yearID) - MIN(yearID) + 1) * 2 AS Num_Semesters

SELECT playerID,
    COUNT(yearID) AS Num_Semesters, -- I believe that this is incorrect but it produces the same output as the example from Question 7
    COUNT(DISTINCT schoolID) AS num_colleges,
    MIN(yearID) AS firstyr,
    MAX(yearID) AS lstyr
FROM CollegePlaying
GROUP BY playerID;



-- 8. You then start to discuss the impact the years in college have on the player’s earnings. Write a query
-- that returns the minimum, average and maximum salary from the salaries table.
SELECT 
    FORMAT(MIN(salary),'C') AS minsalary,
    FORMAT(AVG(salary),'C') AS avg_salary,
    FORMAT(MAX(salary),'C') AS maxsalary
FROM Salaries;


-- 9. Now we decide to make the assumption that, on average, players will attend college for 3 years since
-- some go to community colleges and some to 4 year schools. Using the salaries table, write a query that
-- shows each players total salary, lost salary as 3 times their average salary (to estimate lost income by
-- going to college) and the percent of total income they would have lost by attending college (calculated
-- as 1-(total salary/(total salary + lost income). Exclude players having a negative difference. This query
-- should have 6,246 rows in the results.

SELECT playerID,
    FORMAT(SUM(salary),'C') AS totsalary,
    FORMAT(AVG(salary),'C') AS avgsalary,
    FORMAT(AVG(salary) * 3,'C') AS lostincome,
    FORMAT((1 - (SUM(salary) / (SUM(salary) + (AVG(salary) * 3)))) * 100, 'N2') + ' %' AS perctdiff
FROM Salaries
GROUP BY playerID;



-- 10. Now you want to know the average lost income and the average percent difference in salary for all
-- players. To do this, use the answer for #9 as a nested subquery and calculate the answer. You will need
-- to add 1 lines of SQL and make minor modifications to the query from #9 to get the answer.

SELECT FORMAT(AVG(lostincome),'C') AS avglost,
    FORMAT(AVG(perctdiff) * 100, 'N2') + ' %' AS avgperctdiff
FROM (
    SELECT
        AVG(salary) * 3 AS lostincome,
        (1 - (SUM(salary) / (SUM(salary) + (AVG(salary) * 3)))) AS perctdiff
    FROM Salaries
    GROUP BY playerID
) AS table_q9



-- 11. Modify the query for #10 to only include information for players who attended college by using an IN
-- clause in the WHERE statement of the subquery to only include players in the collegeplaying table. You
-- also decide to use the maximum salary vs. the average salary in your calculations since you decide to
-- view not going to college as extending their career by 3 years.
SELECT FORMAT(AVG(lostincome),'C') AS avglost,
    FORMAT(AVG(perctdiff) * 100, 'N2') + ' %' AS avgperctdiff
FROM (
    SELECT
        MAX(salary) * 3 AS lostincome,
        (1 - (SUM(salary) / (SUM(salary) + (MAX(salary) * 3)))) AS perctdiff
    FROM Salaries
    WHERE Salaries.playerID IN (
        SELECT DISTINCT CollegePlaying.playerID FROM CollegePlaying
    )
    GROUP BY playerID
) AS table_q9



-- 12. You decide to dig in a little deeper and use the actual numbers they went to school in your calculations
-- instead of estimating it at 3 years. You do this by adding a subquery to the existing top level subquery
-- that calculates the number of years by player and joining them by playerid. Also add the average
-- number of years players attend college to your output. This changes your top level subquery to have a
-- FROM statement that reads:
-- FROM SALARIES, (select.... From collegeplaying ....) colyears
-- And a WHERE statement that reads:
-- WHERE salaries.playerid = colyears.playerid
-- This gives you the following results:

SELECT FORMAT(AVG(lostincome),'C') AS avglost,
    FORMAT(AVG(perctdiff) * 100, 'N2') + ' %' AS avgperctdiff,
    AVG(yrattend) AS yrattend
FROM (
    SELECT playerID,
        MAX(salary) * 3 AS lostincome,
        (1 - (SUM(salary) / (SUM(salary) + (MAX(salary) * 3)))) AS perctdiff
    FROM Salaries
    WHERE Salaries.playerID IN (
        SELECT DISTINCT CollegePlaying.playerID FROM CollegePlaying
    )
    GROUP BY playerID
) AS table_q9, (
    SELECT playerID, COUNT(yearID) AS yrattend 
    FROM CollegePlaying
    GROUP BY playerID
) AS collYears
WHERE collYears.playerID = table_q9.playerID;



-- 13. Using the Salaries table, find the players full name, average salary and the last year they played for
-- each team they played for during their career. Also find the difference between the players salary and
-- the average team salary. You must use subqueries in the FROM statement to get the team and player
-- average salaries and calculate the difference in the SELECT statement. Sort your answer by the last year
-- in descending order , the difference in descending order and the playerid in ascending order. The query
-- should return 13,482 rows
GO
WITH playerSal AS (
    SELECT playerID, 
        teamID, 
        MAX(yearID) AS LastYear, 
        AVG(salary) AS PlayerAvg
    FROM Salaries
    GROUP BY playerID, teamID
), 
teamSal AS (
    SELECT teamID, 
        AVG(salary) AS TeamAvg, 
        yearID
    FROM Salaries
    GROUP BY teamID, yearID
),
playerFull AS (
    SELECT 
        playerID, 
        NameGiven + ' ( ' + namefirst + ' ) ' + nameLast AS FullName
    FROM People
)
SELECT playerSal.playerID, FullName AS 'Full Name', playerSal.teamID, 
    LastYear AS 'Last Year', 
    FORMAT(PlayerAvg,'C') AS 'Player Average', 
    FORMAT(TeamAvg,'C') AS 'Team Average', 
    FORMAT((PlayerAvg - TeamAvg),'C') AS 'Difference'
FROM playerSal 
JOIN teamSal ON playerSal.teamID = teamSal.teamID AND 
    playerSal.LastYear = teamSal.yearID
JOIN playerFull ON playerSal.playerID = playerFull.playerID
ORDER BY LastYear DESC, 
    (PlayerAvg - TeamAvg) DESC, 
    playerSal.playerID ASC;



-- 14. Rewrite the query in #11 using a WITH statement for the subqueries instead of having the subqueries in
-- the from statement. The answer will be the same. Please make sure you put a GO statement before
-- and after this problem. 5 points will be deducted if the GO statements are missing and I have to add
-- them manually.

-- SELECT FORMAT(AVG(lostincome),'C') AS avglost,
--     FORMAT(AVG(perctdiff) * 100, 'N2') + ' %' AS avgperctdiff
-- FROM (
--     SELECT
--         MAX(salary) * 3 AS lostincome,
--         (1 - (SUM(salary) / (SUM(salary) + (MAX(salary) * 3)))) AS perctdiff
--     FROM Salaries
--     WHERE Salaries.playerID IN (
--         SELECT DISTINCT CollegePlaying.playerID FROM CollegePlaying
--     )
--     GROUP BY playerID
-- ) AS table_q9


GO

WITH CollePlayers AS (
    SELECT DISTINCT playerID
    FROM CollegePlaying
),
LostIncome AS (
    SELECT Salaries.playerID,
        MAX(Salaries.salary) * 3 AS lostincome,
        (1 - (SUM(Salaries.salary) / (SUM(Salaries.salary) + (MAX(Salaries.salary) * 3)))) AS perctdiff
    FROM Salaries
    GROUP BY Salaries.playerID
)
SELECT FORMAT(AVG(lostincome),'C') AS avglost,
    FORMAT(AVG(perctdiff) * 100, 'N2') + ' %' AS avgperctdiff
FROM CollePlayers, LostIncome
WHERE CollePlayers.playerID = LostIncome.playerID;  




-- 15. Using a scalar queries in the SELECT statement and the salaries, batting, pitching and people tables ,
-- write a query that shows the full Name, the average salary (from SALARIES table), career batting
-- average (from the BATTING table), career ERA (the average of the ERA from the PITCHING table), total
-- errors (sum of E from the Fielding table) and the number of teams the player played (from the BATTING
-- table). Format the results as shown below and only use the PEOPLE table in the FROM statement of the
-- top level select. This query returns 20,676 rows
-- NOTE: The columns required for problems #13 through #16 were created in the Add Additional Columns
-- script. You do not need to create or alter any columns. Also, do not format the data you insert into the
-- new columns, formatting the data within a table may make them in unusable in calculations

SELECT P.NameGiven + ' ( ' + P.namefirst + ' ) ' + P.nameLast AS 'Full Name',
    (SELECT COUNT(teamID) 
        FROM Batting B 
        WHERE B.playerID = P.playerID
        GROUP BY playerID) AS 'Total Teams',
    (SELECT FORMAT(AVG(S.salary), 'C') 
        FROM Salaries S 
        WHERE S.playerID = P.playerID) AS 'Avg Salary',
    (SELECT FORMAT(AVG(ERA), 'N2') 
        FROM Pitching Pi 
        WHERE Pi.playerID = P.playerID) AS 'Avg ERA',
    (SELECT FORMAT(AVG(BA), 'N3') 
        FROM (SELECT (H*1.0)/AB AS BA 
            FROM Batting B 
            WHERE B.playerID = P.playerID 
                AND AB > 0) AS AvgBA) AS 'Avg BA',
    (SELECT SUM(E) 
        FROM Fielding F 
        WHERE F.playerID = P.playerID) AS 'Total Errors'
FROM People P


-- 16. The player’s union has negotiated that players will start to have a 401K retirement plan. Using the
-- [Player_401K_Contributions] column in the Salaries table, populate this column for each row by updating
-- it to contain 6% of the salary in the row. You must use an UPDATE query to fill in the amount. This query
-- updates 32,862 rows. Use the column names given, do not create your own columns. Include a select
-- query with the results sorted by playerid as part of your answer that results the rows shown below.
-- Note the column names need to be inside brackets because they start with a number. This is bad
-- naming conventions on my part.
-- playerid salary 401K Contributions
-- A.Mi01 3250000.00 195000.00
-- aardsda01 4500000.00 270000.00
-- aardsda01 500000.00 30000.00

-- Updating the [Player_401K_Contributions] column
UPDATE Salaries
SET [Player_401K_Contributions] = salary * 0.06;

-- Showing the results of the above query
SELECT playerid, salary, [Player_401K_Contributions]
FROM Salaries
ORDER BY playerid;


-- 17. Contract negotiations have proceeded and now the team owner will make a separate contribution to
-- each players 401K each year. If the player’s salary is under $1 million, the team will contribute another
-- 5%. If the salary is over $1 million, the team will contribute 2.5%. You now need to write an UPDATE
-- query for the [Team_401K_Contributions] column in the Salaries table to populate the team contribution
-- with the correct amount. You must use a CASE clause in the UPDATE query to handle the different
-- amounts contributed. This query updates 32,862 rows.
-- playerid salary 401K Contributions 401K Team Contributions
-- A.Mi01 3250000.00 195000.00 81250.00
-- aardsda01 4500000.00 270000.00 112500.00
-- aardsda01 500000.00 30000.00 25000.00

-- Updating the [Team_401K_Contributions] column
UPDATE Salaries
SET [Team_401K_Contributions] = 
    CASE 
        WHEN salary < 1000000 THEN salary * 0.05
        ELSE salary * 0.025
    END;

-- Showing the results of the above query
SELECT playerid, salary, [Player_401K_Contributions], [Team_401K_Contributions]
FROM Salaries
ORDER BY playerid;



-- 18. You have now been asked to populate the columns to the PEOPLE table that contain the total number
-- of HRs hit ( Total_HR column) by the player and the highest Batting Average the player had during any
-- year they played ( High_BA column). Write a single query that correctly populates these columns. You
-- will need to use a subquery to make is a single query. This query updates 18,003 rows if you use AB > 0
-- in the where statement. It updates 20,469 rows in nullif is used for batting average. After your update
-- query, write a query that shows the playerid, Total HRs and Highest Batting Average for each player.
-- The Batting Average must be formatted to only show 4 decimal places. Sort the results by playerid. The
-- update query will update 20,676 rows and the select query will return 20,370 rows.
-- playerid Total_HR Career_BA
-- aardsda01 0 0.0000
-- aaronha01 755 0.3545
-- aaronto01 13 0.2500
-- aasedo01 0 0.0000

-- SELECT SUM(HR) 
-- FROM Batting 
-- GROUP BY playerID

-- SELECT MAX(CAST(H AS FLOAT) / NULLIF(AB, 0)) 
-- FROM Batting 
-- GROUP BY playerID

-- Updating the Total_HR and High_BA columns
UPDATE People
SET Total_HR = (
        SELECT SUM(HR) 
        FROM Batting 
        WHERE Batting.playerID = People.playerID
        GROUP BY playerID
    ), 
    High_BA = (
        SELECT MAX(CAST(H AS FLOAT) / NULLIF(AB, 0)) 
        FROM Batting 
        WHERE Batting.playerID = People.playerID
        GROUP BY playerID
    );

-- Showing the results of the above query
SELECT playerID, Total_HR, FORMAT(High_BA, 'N4') AS Career_BA
FROM PEOPLE
ORDER BY playerID;


-- 19. You have also been asked to populate a column in the PEOPLE table ( Total_401K column) that contains
-- the total value of the 401K for each player in the Salaries table. Write the SQL that correctly populates
-- the column. This query updates 5,982 rows. Also, include a query that shows the playerid, the player
-- full name and their 401K total from the people table. Only show players that have contributed to their
-- 401Ks. Sort the results by playerid. . This query returns 6,210 rows.
-- playerid Full Name 401K Total
-- aardsda01 David Allan ( David ) Aardsma $837,322.50
-- aasedo01 Donald William ( Don ) Aase $253,000.00
-- abadan01 Fausto Andres ( Andy ) Abad $35,970.00

-- SELECT playerID, SUM(ISNULL(S.[Player_401K_Contributions], 0) + ISNULL(S.[Team_401K_Contributions], 0))
--     FROM Salaries S
--     GROUP BY playerID
--     ORDER BY playerID;

-- Updating the Total_401K column from the People table
UPDATE People
SET Total_401K = (
    SELECT SUM(ISNULL(S.[Player_401K_Contributions], 0) + ISNULL(S.[Team_401K_Contributions], 0))
    FROM Salaries S
    WHERE S.playerID = People.playerID
    GROUP BY S.playerID
);

-- Showing the results of the above query
SELECT playerID, 
    NameGiven + ' ( ' + namefirst + ' ) ' + nameLast AS 'Full Name',
    FORMAT(Total_401K, 'C') AS '401K Total'
FROM People
WHERE Total_401K > 0
ORDER BY playerID;




-- EXTRA CREDIT
-- 20. As with any job, players are given raises each year, write a query that calculates the increase each
-- player received and calculate the % increase that raise makes. You will only need to use the SALARIES
-- and PEOPLE tables. You answer should include the columns below. Include the players full name and
-- sort your results by playerid in ascending order and year in descending order. This query returns 18,545
-- rows. You cannot use advanced aggregate functions such as LAG for this question. The answer can be
-- written using only the SQL parameters you learned in this chapter.
-- playerid Player Name yearid Current Prior Salary Salary
-- Salary Salary Difference Increase
-- aardsda01 David Allan ( David ) Aardsma 2011 $4,500,000.00 $2,750,000.00 $1,750,000.00 63.63%
-- aardsda01 David Allan ( David ) Aardsma 2010 $2,750,000.00 $419,000.00 $2,331,000.00 556.32%
-- aasedo01 Donald William ( Don ) Aase 1988 $675,000.00 $625,000.00 $50,000.00 8.00%
-- aasedo01 Donald William ( Don ) Aase 1987 $625,000.00 $600,000.00 $25,000.00 4.16%
-- abadfe01 Fernando Antonio ( Fernando ) Abad 2015 $1,087,500.00 $525,900.00 $561,600.00 106.78%
-- abadfe01 Fernando Antonio ( Fernando ) Abad 2012 $485,000.00 $418,000.00 $67,000.00 16.02%

SELECT S1.playerid,
    NameGiven + ' ( ' + namefirst + ' ) ' + nameLast AS "Player Name",
    S1.yearid,
    FORMAT(S1.salary, 'C') AS "Current Salary",
    FORMAT(S2.salary, 'C') AS "Prior Salary",
    FORMAT(S1.salary - S2.salary, 'C') AS "Salary Difference",
    FORMAT((S1.salary - S2.salary) / NULLIF(S2.salary, 0) * 100, 'N2') + '%' AS "Salary Increase"
FROM Salaries S1
INNER JOIN 
    Salaries S2 ON S1.playerid = S2.playerid AND S1.yearid = S2.yearid + 1
INNER JOIN 
    People ON S1.playerid = People.playerid
WHERE S1.salary > S2.salary
ORDER BY S1.playerid ASC, S1.yearid DESC;
