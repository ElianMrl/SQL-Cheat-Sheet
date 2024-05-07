use BaseBall_Summer_2023;
go
---Basic Select Clause
select * from people


-- 1. Create and populate a column called UCID_Total_G_Played (where UCID needs to be your
-- UCID) and a column called UCID_Career_Range_Factor in the PEOPLE table. Next populate both
-- columns with the appropriate aggregate functions for each player. Total _G_Played is simply the
-- sum of all the G columns for a player in the FIELDING table. Career_Range_Factoris calculated
-- using the following formula: Career_Range_Factor (RF) = 9*sum(PO+A)/(sum(InnOuts)/3). Your
-- SQL will need to adjust the columns and results for any difficulties caused by the column data
-- types. The performance factor indicates if a player helps others on his team play better (RF > 1)
-- or takes away from their performance (RF < 1).

-- Create a column called UCID_Total_G_Played
ALTER TABLE PEOPLE
ADD em486_Total_G_Played int;

-- Create a column called UCID_Career_Range_Factor
ALTER TABLE PEOPLE
ADD em486_Career_Range_Factor float;

-- Populate a column called UCID_Total_G_Played
UPDATE PEOPLE
SET em486_Total_G_Played = (
    SELECT SUM(G)
    FROM FIELDING
    WHERE PEOPLE.playerID = FIELDING.playerID
);

-- Populate a column called UCID_Career_Range_Factor
UPDATE PEOPLE
SET em486_Career_Range_Factor = (
    SELECT 9*sum(PO+A) / NULLIF((SUM(CAST(InnOuts AS INT)) / 3), 0)
    FROM FIELDING
    WHERE PEOPLE.playerID = FIELDING.playerID
); 

SELECT playerID, em486_Total_G_Played, em486_Career_Range_Factor
FROM PEOPLE

-- 2. The next step is to write a trigger that updates the both of the columns you created in the
-- PEOPLE table whenever there is a row inserted, updated or deleted from the FIELDING table.
-- The trigger name must start with your UCID and the DDL that creates the trigger must also check
-- to see if the trigger exists before creating it.
-- Your trigger must:

--  use basic math functions (+, -) to adjust UCID_Total_G_Played (worth 20 points). You’ll
-- need to use the INSERTED and DELETED tables to get the values to add or subtract.

--  use the INSERTED and DELETED tables to determine the SQL Command used (INSERT,
-- UPDATE and DELETE) and have a section to process the data from each command
-- (worth 10 points)

--  use the appropriate aggregate functions and the FIELDING table to adjust/recalculate
-- the UCID_Career_Range_Factor column correctly and only for the single player affected
-- by the SQL command (worth 10 points)

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'em486_Trigger')
    DROP TRIGGER em486_Trigger;
GO

CREATE TRIGGER em486_Trigger
ON Fielding -- For whenever there is a row inserted, updated or deleted from the FIELDING table
AFTER INSERT, UPDATE, DELETE -- updates the both of the columns created in the PEOPLE table
AS
BEGIN

    -- Handle case for INSERT
    IF (SELECT COUNT(*) FROM inserted) > 0 AND (SELECT COUNT(*) FROM deleted) = 0
    BEGIN
        UPDATE People
        SET em486_Total_G_Played = em486_Total_G_Played + (SELECT SUM(G) FROM inserted WHERE inserted.playerID = People.playerID),
            em486_Career_Range_Factor = (SELECT 9*sum(PO+A) / NULLIF((SUM(CAST(InnOuts AS INT)) / 3), 0) FROM Fielding WHERE Fielding.playerID = People.playerID)
        WHERE playerID IN (SELECT playerID FROM inserted);
    END

    -- Handle case for DELETE
    IF (SELECT COUNT(*) FROM deleted) > 0 AND (SELECT COUNT(*) FROM inserted) = 0
    BEGIN
        UPDATE People
        SET em486_Total_G_Played = em486_Total_G_Played - (SELECT SUM(G) FROM deleted WHERE deleted.playerID = People.playerID),
            em486_Career_Range_Factor = (SELECT 9*sum(PO+A) / NULLIF((SUM(CAST(InnOuts AS INT)) / 3), 0) FROM Fielding WHERE Fielding.playerID = People.playerID)
        WHERE playerID IN (SELECT playerID FROM deleted);
    END

    -- Handle case for UPDATE
    IF (SELECT COUNT(*) FROM inserted) > 0 AND (SELECT COUNT(*) FROM deleted) > 0
    BEGIN
        UPDATE People
        SET em486_Total_G_Played = em486_Total_G_Played + (SELECT SUM(G) FROM inserted WHERE inserted.playerID = People.playerID) - (SELECT SUM(G) FROM deleted WHERE deleted.playerID = People.playerID),
            em486_Career_Range_Factor = (SELECT 9*sum(PO+A) / NULLIF((SUM(CAST(InnOuts AS INT)) / 3), 0) FROM Fielding WHERE Fielding.playerID = People.playerID)
        WHERE playerID IN (SELECT playerID FROM inserted) OR playerID IN (SELECT playerID FROM deleted);
    END
END;


-- 3. Your answer must also include the queries necessary to verify your trigger works correctly. This
-- would typically include 3 sets of queries. One each for Insert, Delete and Update commands.
-- Each set would have the following pattern. The firsts query would select the columns from the
-- PEOPLE and FIELDING tables. The 2nd query would perform the insert, update or delete function
-- on the FIELDING table. The 3rd query would select the columns from the PEOPLE and FIELDING
-- tables to show that your trigger correctly updated the values changed in the 2nd query. The 3
-- sets needed would be separate queries for insert, update and delete . 


SELECT *
FROM Fielding


-- Before INSERT
SELECT P.playerID, P.em486_Total_G_Played, P.em486_Career_Range_Factor, F.G
FROM People P
JOIN Fielding F ON P.playerID = F.playerID
WHERE P.playerID = 'abercda01'; 

-- INSERT -----------------------------------------------------------------------------------------------
INSERT INTO Fielding (playerID, yearID, stint, teamID, lgID, POS, G) -- these are not null values that must be included when new records are added (except for G, which it is only needed to make sure that the triggers is working on the new columns)
VALUES ('abercda01', 1871, 1, 'TRO', 'NA', 'C', 10);

-- After INSERT
SELECT P.playerID, P.em486_Total_G_Played, P.em486_Career_Range_Factor, F.G
FROM People P
JOIN Fielding F ON P.playerID = F.playerID
WHERE P.playerID = 'abercda01'; 

-- DELETE -----------------------------------------------------------------------------------------------
DELETE FROM Fielding
WHERE playerID = 'abercda01' AND yearID = 1871 AND stint = 1 AND teamID = 'TRO' AND lgID = 'NA' AND POS = 'C' AND G = 10;

-- After DELETE
SELECT P.playerID, P.em486_Total_G_Played, P.em486_Career_Range_Factor, F.G
FROM People P
JOIN Fielding F ON P.playerID = F.playerID
WHERE P.playerID = 'abercda01'; 

-- UPDATE ------------------------------------------------------------------------------------------------
UPDATE Fielding
SET G = 15
WHERE playerID = 'abercda01' AND yearID = 1871 AND stint = 1 AND teamID = 'TRO' AND lgID = 'NA' AND POS = 'SS' AND G = 1;

-- After UPDATE
SELECT P.playerID, P.em486_Total_G_Played, P.em486_Career_Range_Factor, F.G
FROM People P
JOIN Fielding F ON P.playerID = F.playerID
WHERE P.playerID = 'abercda01'; 

-- To go back to the original database -------------------------------------------------------------------
UPDATE Fielding
SET G = 1
WHERE playerID = 'abercda01' AND yearID = 1871 AND stint = 1 AND teamID = 'TRO' AND lgID = 'NA' AND POS = 'SS' AND G = 15;



-- 4. The last part of your submission needs to be the DDL to disable the trigger. 

-- Disable the Trigger
DISABLE TRIGGER em486_Trigger ON Fielding;

-- To Enable the Trigger
-- ENABLE TRIGGER em486_Trigger ON Fielding;