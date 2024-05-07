use BaseBall_Summer_2023;
go
---Basic Select Clause
select * from people

-- Transaction Processing Assignment – Cursor Processing

-- Cursors are often used as a way to limit processing when you need to update a very large number of
-- rows in a database. In large commercial database, it can often take hours to update hundreds of millions
-- of rows. Data quality can often cause these processes to abend and need to be rerun. Cursors can also
-- be useful in these instances since they can be used to identify and skip rows that have already been
-- processed. The Baseball database does not lend itself to this type of processing, so while it may appear
-- to be easier to simply update all rows instead of using a Cursor, a Cursor is being used as an example for
-- this type of processing. Cursors are also typically utilize Stored Procedures to eliminate the risk of
-- inadvertent changes being made to the SQL. For this assignment, you need to write a script that does
-- the following:

-- 1. Add 2 columns to the PEOPLE table. The columns should be UCID_Career_EqA and
-- UCID_Date_Last_Update. As always, the UCID should be replaced with your actual UCID. Make
-- sure to include IF statements so the script can be run more than once. Also replace UCID with
-- your ID. An example of the column names would be sp245_Career_EqA

-- Creates em486_Career_EqA 
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'People' 
    AND COLUMN_NAME = 'em486_Career_EqA'
)
BEGIN
    ALTER TABLE People
    ADD em486_Career_EqA FLOAT;
END;

-- Creates em486_Date_Last_Update 
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'People' 
    AND COLUMN_NAME = 'em486_Date_Last_Update'
)
BEGIN
    ALTER TABLE People
    ADD em486_Date_Last_Update DATE;
END;


-- 2. Creates a stored procedure containing an update cursor that contains the playerid and the sum
-- of the player’s Equivalent Average calculated using the BATTING . Equivalent Average (EqA)
-- is a baseball metric invented by Clay Davenport and intended to express the production of
-- hitters in a context independent of park and league effects.[1] It represents a hitter's
-- productivity using the same scale as batting average. Thus, a hitter with an EqA over .300 is
-- a very good hitter, while a hitter with an EqA of .220 or below is poor. An EqA of .260 is
-- defined as league average.The formula for the Equivalent Average is

-- Equivalent Average = (Hits + Total Bases + (1.5 x (Walks + Hit by Pitch)) + Stolen Bases + Sacrifice Hits + Sacrifice Flies) ÷ 
-- (At Bats + Walks + Hit by Pitch + Sacrifice Hits + Sacrifice Flies + Caught Stealing + (Stolen Bases ÷ 3))

-- From the Battinging table, use the following columns:
-- Hits = H
-- Total Bases = H + 2*B2 + 3*b3 + 4*HR + BB
-- Walks = BB
-- At Bats = AB
-- Hit By Pitcher = HBP
-- Sacrifice Hits = SH
-- Sacrifice = SF
-- Caught Stealing = CS
-- Stolen Bases = SB


-- 3. The SQL created in #2, write a stored procedure that:

-- a. Updates the new columns in the PEOPLE table when UCID_Date_Last_Update is not
-- equal to the current date (handled in the WHERE clause of the DECLARE CURSOR)

-- b. updates the UCID_Career_EqA with the column from the cursor and set
-- UCID_Date_Last_Update to the current date. (the CURSOR only needs to contain the
-- playerid and EqA value)

-- c. Selects the system variable @@Cursor_Rows after you fetch the first CURSOR row so
-- you can see how many rows are in the cursor. (The value isn’t available until the 1st row
-- is fetched)

-- d. Turns off the individual rows update counter by specifying SET NOCOUNT ON at the
-- beginning of the Cursor processing. (This eliminates the 1 row update message form
-- appearing)

-- e. Writes the date and time as well as the # of records updated with the date and time for
-- every 1,000 records updated (This shows the operator that the CURSOR is making
-- progress and not experiencing a deadlock condition)

-- f. Closes and deallocates the cursor as the last step in the script.

-- g. Note: Microsoft has changed SQL Server so that PRINT statements do not show until the
-- stored procedure ends. You must not use a RAISERROR statement shown in the outline
-- below)

CREATE PROCEDURE UpdatePlayerEqA AS
BEGIN

    -- Question 3D: turn off row count messages
    SET NOCOUNT ON; 

    -- Creating variables to store the playerID and EqA values fetched from the cursor that iterates through the records of the Batting table.
    DECLARE @playerID NVARCHAR(50);
    DECLARE @EqA FLOAT;
    DECLARE @numRows INT = 0;
    DECLARE @totalRows INT;

    -- Question 2: Cursor to fetch playerID and calculate EqA for each player
    DECLARE EqA_Cursor CURSOR STATIC FOR
        SELECT playerID,
                (SUM(H) + SUM(H + 2 * B2 + 3 * B3 + 4 * HR + BB) + 1.5 * (SUM(BB) + SUM(CAST(HBP AS INT))) + SUM(SB) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT))) /
                (SUM(AB) + SUM(BB) + SUM(CAST(HBP AS INT)) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT)) + SUM(CS) + (SUM(SB) / 3.0)) AS EqA
        FROM Batting
        GROUP BY playerID
        HAVING (SUM(AB) + SUM(BB) + SUM(CAST(HBP AS INT)) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT)) + SUM(CS) + (SUM(SB) / 3.0)) > 0;

    OPEN EqA_Cursor;

    FETCH NEXT FROM EqA_Cursor INTO @playerID, @EqA;

    -- Question 3C: Check how many rows are in the cursor after the first fetch
    SET @totalRows = @@CURSOR_ROWS;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Update the People table with the calculated EqA and current date for each player
        UPDATE People
        SET em486_Career_EqA = @EqA,
            em486_Date_Last_Update = GETDATE()
        WHERE playerID = @playerID;

        SET @numRows = @numRows + 1;

        -- Question 3E: Writes the date and time as well as the # of records updated with the date and time for every 1,000 records updated 
        IF @numRows % 1000 = 0
        BEGIN
            DECLARE @message NVARCHAR(1000) = CONVERT(VARCHAR(25), GETDATE()) + 
                                              ': Updated ' + CONVERT(VARCHAR(10), @numRows) + 
                                              ' of ' + CONVERT(VARCHAR(10), @totalRows) + ' records.';
            RAISERROR(@message, 0, 1) WITH NOWAIT; -- this forces to show the print message before the stored procedure ends but according to the note in question 3 it may not work. 
        END

        -- Fetch the next player
        FETCH NEXT FROM EqA_Cursor INTO @playerID, @EqA;
    END;

    -- Close and deallocate the cursor
    CLOSE EqA_Cursor;
    DEALLOCATE EqA_Cursor;
END;

-- the EXEC statements to run the stored procedure
EXEC UpdatePlayerEqA;

-- 4. Include a query to be run after the Cursor processing is complete that selects the playerid,
-- UCID_Career_EqA and UCID_Date_Last_Update from the PEOPLE table

SELECT playerID, em486_Career_EqA, em486_Date_Last_Update
FROM People; 

-- 5. Run the script created for steps #2 and #3 a second time and see what happens. Think of why
-- you got these results when you run the script a second time.

-- the EXEC statements to run the stored procedure
EXEC UpdatePlayerEqA;

SELECT playerID, em486_Career_EqA, em486_Date_Last_Update
FROM People; 

-- FINDINGS: After running the stored procedure a second time I notices no changes in the following columns playerID, 
-- em486_Career_EqA, and em486_Date_Last_Update because the data was not change in between the two executions. I am not sure
-- if I am suppose to expect some changes but as I mentioned before I got the same results or maybe I am missing something or 
-- doing something wrong. 


-- CEMETERY ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SELECT playerID,
--         (SUM(H) + SUM(H + 2 * B2 + 3 * B3 + 4 * HR + BB) + 1.5 * (SUM(BB) + SUM(CAST(HBP AS INT))) + SUM(SB) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT))) /
--         (SUM(AB) + SUM(BB) + SUM(CAST(HBP AS INT)) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT)) + SUM(CS) + (SUM(SB) / 3.0)) AS EqA
-- FROM Batting
-- GROUP BY playerID
-- HAVING (SUM(AB) + SUM(BB) + SUM(CAST(HBP AS INT)) + SUM(CAST(SH AS INT)) + SUM(CAST(SF AS INT)) + SUM(CS) + (SUM(SB) / 3.0)) > 0;