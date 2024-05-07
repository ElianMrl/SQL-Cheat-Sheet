use BaseBall_Summer_2023;
go
---Basic Select Clause to make sure that we established a connection to the database
---1 Select all columns from the PEOPLE table
select * from people

-- For the questions below, you MUST replace UCID with your UDIC when you create a view named UCID_Player_Summary. For example, the
-- view name in question 1 should look something like NJ342_Player_Summary. The Assignment is to write a view containing the following:

-- playerID
-- Player Full Name, (use the dbo.fullname function included in the database by adding dbo.fullname(playerid) to the select
-- Total_401K amount from the People table
-- Number of yrs played from the Batting table
-- Number of Teams played for the Batting table
-- Career Total Home Runs from Batting
-- Career Batting Average (calculate the Batting Average using all the data for the player)
-- Last Year Played from Batting
-- Total Salary
-- Average Career Salary
-- Starting Salary from the Salaries table
-- Ending Salary from the Salaries table
-- Career percentage of salary increase (percent difference in starting and ending salary)
-- Career Total of Wins from Pitching Table
-- Career Total of Strike Outs (SO) from the Pitching Table
-- Career Power Fitness Ratio (statistical measure of the performance of a pitcher. It is the sum of strikeouts (SO) and walks (BB) divided
-- by sum of innings pitched (IPouts/3)from the Pitching Table
-- Total games played (G) from the Fielding Table
-- Total games started (GS) from the Fielding Table
-- Career Fielding Percentage (statistical measure of fielding. It is calculated by the sum of putouts (PO) and assists (A), divided by the
-- number of total chances (putouts + assists + errors (E).[1]
-- Year Inducted in the Hall of Fame
-- # of times nominated for the hall of fame but not inducted (# of rows where inducted = ‘N’)
-- Hall of Fame (Yes or No) as an indicator if the player was actually elected to the Hall of Fame

-- Note: Since it was not required according to the sample for query #2 to format the salary or percentage then I decided to leave it as it is

-- 1. The SQL that creates your view
CREATE VIEW EM486_Player_Summary AS
    WITH BattingStats AS (
        SELECT playerID,
            COUNT(DISTINCT yearID) AS num_years,
            COUNT(DISTINCT teamID) AS num_teams,
            SUM(HR) AS runs,
            CASE 
                WHEN SUM(AB) > 0 THEN CONVERT(decimal(10,6), SUM(H) * 1.0 / SUM(AB))
                ELSE 0
            END AS career_ba,
            MAX(yearID) AS last_year_played
        FROM Batting
        GROUP BY playerID
    ),
    SalaryStats AS (
        SELECT playerID,
            SUM(Salary) AS tot_sal,
            AVG(Salary) AS avg_sal,
            MIN(Salary) AS min_Salary,
            MAX(Salary) AS max_Salary,
            CASE 
                WHEN MIN(salary) > 0 THEN CONVERT(decimal(10,6), (MAX(Salary) - MIN(Salary)) * 1.0 / MAX(Salary))
                ELSE NULL
            END AS perct_incr
        FROM Salaries
        GROUP BY playerID
    ),
    PitchingStats AS (
        SELECT playerID,
            SUM(W) AS tot_win,
            SUM(SO) AS tot_so,
            CONVERT(decimal(10,6), (SUM(SO) + SUM(BB)) * 1.0 / NULLIF(SUM(IPouts) / 3, 0)) AS car_pfr
        FROM Pitching
        GROUP BY playerID
    ),
    FieldingStats AS (
        SELECT playerID,
            SUM(G) AS total_games_played,
            SUM(CAST(GS AS INT)) AS total_games_started, 
            CONVERT(decimal(10,6), (SUM(PO) + SUM(A)) * 1.0 / NULLIF(SUM(PO) + SUM(A) + SUM(E), 0)) AS career_fielding_per
        FROM Fielding
        GROUP BY playerID
    ),
    HallOfFameStats AS (
        SELECT playerID,
            MAX(CASE WHEN inducted = 'Y' THEN yearID END) AS year_inducted, -- Note: I have to use MAX() for inducted because it will ask for putting inducted in an aggreagate or group by and if I put it in group by it will create extra rows for the same playerid if the playerid was inducted in different years
            COUNT(CASE WHEN inducted = 'N' THEN playerID END) AS nominated_count, -- Nominated count but not inducted means not including 'Y'
            MAX(inducted) AS inducted -- 'Y' if inducted at least once, otherwise 'N' or NULL (Note: I have to use MAX() for the same reason as for years_inducted)
        FROM HallOfFame
        GROUP BY playerID
    )
    SELECT P.playerID,
        dbo.fullname(P.playerid) AS full_name,
        P.Total_401K,
        B.num_years,
        B.num_teams,
        B.runs,
        B.career_ba,
        B.last_year_played,
        S.tot_sal,
        S.avg_sal,
        S.min_Salary,
        S.max_Salary,
        S.perct_incr,
        Pi.tot_win,
        Pi.tot_so,
        Pi.car_pfr,
        F.total_games_played,
        F.total_games_started,
        F.career_fielding_per,
        HOF.year_inducted,
        HOF.nominated_count,
        COALESCE(HOF.inducted, 'N') AS inducted -- COALESCE Ensures 'N' is shown if it is NULL
    FROM People P
        LEFT JOIN BattingStats B ON P.playerID = B.playerID
        LEFT JOIN SalaryStats S ON P.playerID = S.playerID
        LEFT JOIN PitchingStats Pi ON P.playerID = Pi.playerID
        LEFT JOIN FieldingStats F ON P.playerID = F.playerID
        LEFT JOIN HallOfFameStats HOF ON P.playerID = HOF.playerID;

-- 2. The SQL that selects all the rows from your view (10 points off if this is missing)
GO
SELECT * 
FROM EM486_Player_Summary 
ORDER BY playerID;

SELECT playerID, COUNT(*)
FROM EM486_Player_Summary 
GROUP BY playerID 
HAVING COUNT(*) > 1
ORDER BY playerID;

-- 3. Write a query that calculates the count of rows returned, the average of the [# of yrs played], the average of the [Average Salary] and
-- the averages of the Career Batting Averages, and the average of career of all players who’s last name begins with the letter B using the
-- information in the view. Your answer needs to be properly formatted as shownbelow. (10 points off if this is missing or formatted
-- incorrectly)
SELECT COUNT(*) AS Total_rows,
    AVG(num_years) AS avg_num_years_played,
    FORMAT(AVG(avg_sal), 'C') AS Average_salary,
    AVG(career_ba) AS avg_career_BA
FROM EM486_Player_Summary
WHERE full_name LIKE 'B%';



------ CEMETERY -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- The following query takes for ever to run. To fix this issue, I should used WITH clause
-- SELECT P.playerID AS playerid, 
--     dbo.fullname(P.playerid) AS full_name, 
--     P.Total_401K AS Total_401K, 
--     COUNT(DISTINCT B.yearID) AS num_years, 
--     COUNT(DISTINCT B.teamID) AS num_teams, 
--     SUM(B.HR) AS runs, 
--     CASE 
--         WHEN SUM(B.AB) > 0 THEN Convert(decimal(10,6),SUM(B.H) * 1.0 / SUM(B.AB))
--         ELSE 0 
--     END AS career_ba, 
--     MAX(B.yearID) AS last_year_played, 
--     SUM(S.Salary) AS tot_sal, 
--     AVG(S.Salary) AS avg_sal, 
--     MIN(S.Salary) AS min_Salary, 
--     MAX(S.Salary) AS max_Salary, 
--     CASE 
--         WHEN MIN(S.salary) > 0 THEN (MAX(S.Salary) - MIN(S.Salary)) / MAX(S.Salary) -- since the sample query #2 is not in percentage then I am going to leave this one as it is (without multiplying by 100 and adding the % sign)
--         ELSE NULL
--     END AS perct_incr, 
--     SUM(Pi.W) AS tot_win,
--     SUM(Pi.SO) AS tot_so,
--     Convert(decimal(10,6),(SUM(Pi.SO) + SUM(Pi.BB)) * 1.0 / nullif((SUM(Pi.IPouts) / 3), 0)) AS car_pfr,
--     SUM(Fi.G) AS total_games_played, 
--     SUM(CAST(Fi.GS AS INT)) AS total_games_started, 
--     Convert(decimal(10,6),(SUM(Fi.PO) + SUM(Fi.A)) * 1.0 / nullif((SUM(Fi.PO) + SUM(Fi.A)) + SUM(E), 0)) AS career_fielding_per,
--     HOF.yearID AS year_inducted, 
--     COUNT(NotHOF.playerID) AS nominated_count, 
--     CASE 
--         WHEN HallOfFame.inducted IS NULL THEN 'N'
--         ELSE HallOfFame.inducted
--     END AS inducted
-- FROM People P
--     LEFT JOIN Batting B ON P.playerID = B.playerID
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
--     LEFT JOIN Pitching Pi ON P.playerID = Pi.playerID
--     LEFT JOIN Fielding Fi ON P.playerID = Fi.playerID
--     LEFT JOIN (
--         SELECT playerID, yearID
--         FROM HallOfFame
--         WHERE inducted = 'Y'
--     ) HOF ON p.playerID = hof.playerID
--     LEFT JOIN (
--         SELECT playerID
--         FROM HallOfFame
--         WHERE inducted = 'N'
--     ) NotHOF ON p.playerID = NotHOF.playerID
--     LEFT JOIN HallOfFame ON P.playerID = HallOfFame.playerID
-- GROUP BY P.playerID, P.Total_401K, HOF.yearID, HallOfFame.inducted;



-- Solution to the above issue:
-- WITH BattingStats AS (
--     SELECT 
--         playerID,
--         COUNT(DISTINCT yearID) AS num_years,
--         COUNT(DISTINCT teamID) AS num_teams,
--         SUM(HR) AS runs,
--         CASE 
--             WHEN SUM(AB) > 0 THEN CONVERT(decimal(10,6), SUM(H) * 1.0 / SUM(AB))
--             ELSE 0
--         END AS career_ba,
--         MAX(yearID) AS last_year_played
--     FROM Batting
--     GROUP BY playerID
-- ),
-- SalaryStats AS (
--     SELECT 
--         playerID,
--         SUM(Salary) AS tot_sal,
--         AVG(Salary) AS avg_sal,
--         MIN(Salary) AS min_Salary,
--         MAX(Salary) AS max_Salary,
--         CASE 
--             WHEN MIN(salary) > 0 THEN CONVERT(decimal(10,6), (MAX(Salary) - MIN(Salary)) * 1.0 / MAX(Salary))
--             ELSE NULL
--         END AS perct_incr
--     FROM Salaries
--     GROUP BY playerID
-- ),
-- PitchingStats AS (
--     SELECT 
--         playerID,
--         SUM(W) AS tot_win,
--         SUM(SO) AS tot_so,
--         CONVERT(decimal(10,6), (SUM(SO) + SUM(BB)) * 1.0 / NULLIF(SUM(IPouts) / 3, 0)) AS car_pfr
--     FROM Pitching
--     GROUP BY playerID
-- ),
-- FieldingStats AS (
--     SELECT 
--         playerID,
--         SUM(G) AS total_games_played,
--         SUM(CAST(GS AS INT)) AS total_games_started, 
--         CONVERT(decimal(10,6), (SUM(PO) + SUM(A)) * 1.0 / NULLIF(SUM(PO) + SUM(A) + SUM(E), 0)) AS career_fielding_per
--     FROM Fielding
--     GROUP BY playerID
-- ),
-- HallOfFameStats AS (
--     SELECT 
--         playerID,
--         MAX(CASE WHEN inducted = 'Y' THEN yearID END) AS year_inducted, -- Note: I have to use MAX() for inducted because it will ask for putting inducted in an aggreagate or group by and if I put it in group by it will create extra rows for the same playerid if the playerid was inducted in different years
--         COUNT(CASE WHEN inducted = 'N' THEN playerID END) AS nominated_count, -- But not inducted means not including 'Y'
--         MAX(inducted) AS inducted -- 'Y' if inducted at least once, otherwise 'N' or NULL (Note: I have to use MAX() for the same reason as for years_inducted)
--     FROM HallOfFame
--     GROUP BY playerID
-- )
-- SELECT 
--     P.playerID,
--     dbo.fullname(P.playerid) AS full_name,
--     P.Total_401K,
--     B.num_years,
--     B.num_teams,
--     B.runs,
--     B.career_ba,
--     B.last_year_played,
--     S.tot_sal,
--     S.avg_sal,
--     S.min_Salary,
--     S.max_Salary,
--     S.perct_incr,
--     Pi.tot_win,
--     Pi.tot_so,
--     Pi.car_pfr,
--     F.total_games_played,
--     F.total_games_started,
--     F.career_fielding_per,
--     HOF.year_inducted,
--     HOF.nominated_count,
--     COALESCE(HOF.inducted, 'N') AS inducted -- Ensures 'N' is shown if NULL
-- FROM People P
--     LEFT JOIN BattingStats B ON P.playerID = B.playerID
--     LEFT JOIN SalaryStats S ON P.playerID = S.playerID
--     LEFT JOIN PitchingStats Pi ON P.playerID = Pi.playerID
--     LEFT JOIN FieldingStats F ON P.playerID = F.playerID
--     LEFT JOIN HallOfFameStats HOF ON P.playerID = HOF.playerID
-- ORDER BY P.playerID;


-- -- playerID
-- SELECT P.playerID
-- FROM People P;

-- -- Player Full Name, (use the dbo.fullname function included in the database by adding dbo.fullname(playerid) to the select
-- SELECT P.playerID, dbo.fullname(P.playerid) AS 'Full Name'
-- FROM People P
-- GROUP BY P.playerID;

-- -- Total_401K amount from the People table
-- SELECT playerID, Total_401K
-- FROM People
-- GROUP BY playerID, Total_401K;

-- -- Number of yrs played from the Batting table
-- SELECT P.playerID, COUNT(DISTINCT B.yearID) AS '# of yrs played'
-- FROM People P LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY P.playerID;

-- -- Number of Teams played for the Batting table
-- SELECT P.playerID, COUNT(DISTINCT B.teamID) AS '# of Teams played'
-- FROM People P LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY P.playerID;

-- -- Career Total Home Runs from Batting
-- SELECT P.playerID, SUM(B.HR) AS 'Total Home Runs'
-- FROM People P LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY P.playerID;

-- -- Career Batting Average (calculate the Batting Average using all the data for the player)
-- SELECT P.playerID, SUM(B.HR) AS 'Total Home Runs'
-- FROM People P LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY P.playerID;

-- -- Career Batting Average (calculate the Batting Average using all the data for the player)
-- SELECT P.playerID, dbo.fullname(P.playerid) AS 'Full Name',
--     CASE 
--         WHEN SUM(B.AB) > 0 THEN Convert(decimal(7,6),SUM(B.H) * 1.0 / SUM(B.AB))
--         ELSE 0 
--     END AS CareerBattingAverage
-- FROM People P
--     LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY P.playerID, dbo.fullname(P.playerid)
-- ORDER BY P.playerID

-- -- Last Year Played from Batting
-- SELECT P.playerID, MAX(B.yearID) AS 'Last Year Played'
-- FROM People P
--     LEFT JOIN Batting B ON P.playerID = B.playerID
-- GROUP BY p.playerID

-- -- Total Salary
-- SELECT P.playerID, SUM(S.Salary) AS 'Total Salary'
-- FROM People P
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
-- GROUP BY p.playerID
-- ORDER BY P.playerID

-- -- Average Career Salary
-- SELECT P.playerID, AVG(S.Salary) AS 'Average Salary'
-- FROM People P
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
-- GROUP BY p.playerID
-- ORDER BY P.playerID

-- -- Starting Career Salary
-- -- SELECT 
-- --     p.playerID,
-- --     s.StartYear,
-- --     ss.salary AS 'Starting Salary'
-- -- FROM 
-- --     People p
-- -- LEFT JOIN 
-- --     (SELECT 
-- --          playerID, 
-- --          MIN(yearID) AS StartYear
-- --      FROM Salaries
-- --      GROUP BY playerID) s ON p.playerID = s.playerID
-- -- LEFT JOIN Salaries ss ON p.playerID = ss.playerID AND s.StartYear = ss.yearID
-- -- ORDER BY 
-- --     p.playerID;

-- SELECT P.playerID, MIN(S.Salary) AS 'Starting Salary'
-- FROM People P
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
-- GROUP BY p.playerID
-- ORDER BY P.playerID

-- -- Ending Career Salary
-- SELECT P.playerID, MAX(S.Salary) AS 'Ending Salary'
-- FROM People P
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
-- GROUP BY p.playerID
-- ORDER BY P.playerID

-- -- Career percentage of salary increase (percent difference in starting and ending salary)
-- SELECT P.playerID, 
--     CASE 
--         WHEN MIN(S.salary) > 0 THEN (MAX(S.Salary) - MIN(S.Salary)) / MAX(S.Salary) -- since the sample query #2 is not in percentage then I am going to leave this one as it is (without multiplying by 100 and adding the % sign)
--         ELSE NULL
--     END AS 'Career percentage of salary increase'
-- FROM People P
--     LEFT JOIN Salaries S ON P.playerID = S.playerID
-- GROUP BY p.playerID
-- ORDER BY P.playerID

-- -- Career Total of Wins from Pitching Table
-- SELECT P.playerID, SUM(Pi.W) AS tot_win
-- FROM People P LEFT JOIN Pitching Pi ON P.playerID = Pi.playerID
-- GROUP BY P.playerID;


-- -- Career Total of Strike Outs (SO) from the Pitching Table
-- SELECT P.playerID, SUM(Pi.SO) AS tot_so
-- FROM People P LEFT JOIN Pitching Pi ON P.playerID = Pi.playerID
-- GROUP BY P.playerID;

-- -- Career Power Fitness Ratio (statistical measure of the performance of a pitcher. It is the sum of strikeouts (SO) and walks (BB) divided
-- -- by sum of innings pitched (IPouts/3)from the Pitching Table
-- SELECT P.playerID, 
--     Convert(decimal(7,6),(SUM(Pi.SO) + SUM(Pi.BB)) * 1.0 / nullif((SUM(Pi.IPouts) / 3), 0)) AS car_pfr
-- FROM People P LEFT JOIN Pitching Pi ON P.playerID = Pi.playerID
-- GROUP BY P.playerID;

-- -- Total games played (G) from the Fielding Table
-- SELECT P.playerID, SUM(Fi.G) AS total_games_played
-- FROM People P LEFT JOIN Fielding Fi ON P.playerID = Fi.playerID
-- GROUP BY P.playerID;


-- -- Total games started (GS) from the Fielding Table
-- SELECT P.playerID, SUM(CAST(Fi.GS AS INT)) AS total_games_started
-- FROM People P LEFT JOIN Fielding Fi ON P.playerID = Fi.playerID
-- GROUP BY P.playerID;

-- -- Career Fielding Percentage (statistical measure of fielding. It is calculated by the sum of putouts (PO) and assists (A), divided by the
-- -- number of total chances (putouts + assists + errors (E).
-- SELECT P.playerID, 
--     Convert(decimal(7,6),(SUM(Fi.PO) + SUM(Fi.A)) * 1.0 / nullif((SUM(Fi.PO) + SUM(Fi.A)) + SUM(E), 0)) AS career_fielding_per
-- FROM People P LEFT JOIN Fielding Fi ON P.playerID = Fi.playerID
-- GROUP BY P.playerID;

-- -- Year Inducted in the Hall of Fame
-- SELECT P.playerID, HOF.yearID AS year_inducted
-- FROM People P
--     LEFT JOIN (
--         SELECT playerID, yearID
--         FROM HallOfFame
--         WHERE inducted = 'Y'
--     ) HOF ON p.playerID = hof.playerID;

-- -- # of times nominated for the hall of fame but not inducted (# of rows where inducted = ‘N’)
-- SELECT P.playerID, COUNT(NotHOF.playerID)
-- FROM People P LEFT JOIN (
--         SELECT playerID
--         FROM HallOfFame
--         WHERE inducted = 'N'
--     ) NotHOF ON p.playerID = NotHOF.playerID
-- GROUP BY P.playerID;

-- -- Hall of Fame (Yes or No) as an indicator if the player was actually elected to the Hall of Fame
-- SELECT P.playerID, 
--     CASE 
--         WHEN HallOfFame.inducted IS NULL THEN 'N'
--         ELSE HallOfFame.inducted
--     END AS inducted
-- FROM People P LEFT JOIN HallOfFame ON P.playerID = HallOfFame.playerID



