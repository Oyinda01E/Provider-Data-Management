-- Creating a Claims Table
CREATE TABLE Claims (
    ClmDiagnosisCode_1 VARCHAR(10),
    ClaimStartDt DATE
);
INSERT INTO Claims (ClmDiagnosisCode_1, ClaimStartDt) VALUES
('4019', '2022-06-15'),
('25000', '2022-07-20'),
('41401', '2022-08-10'),
('4019', '2022-09-04'),
('25000', '2022-10-21'),
('25000', '2022-11-11'),
('41401', '2022-12-30'),
('41401', '2022-05-16'),
('4019', '2022-04-27');


-- Creating a HospitalStays Table
CREATE TABLE HospitalStays (
    Department VARCHAR(50),
    AdmissionDt DATE,
    DischargeDt DATE,
    BeneID VARCHAR(10)
);
INSERT INTO HospitalStays (Department, AdmissionDt, DischargeDt, BeneID) VALUES
('Cardiology', '2022-04-01', '2022-04-04', 'B001'),
('Oncology', '2022-05-10', '2022-05-20', 'B002'),
('Neurology', '2022-06-15', '2022-06-20', 'B003'),
('Cardiology', '2022-07-01', '2022-07-03', 'B001'),
('Oncology', '2022-08-05', '2022-08-15', 'B004'),
('Neurology', '2022-09-10', '2022-09-14', 'B005');


-- Creating a HospitalVisits Table
CREATE TABLE HospitalVisits (
    BeneID VARCHAR(10),
    ChronicCond_Alzheimer INT,
    ChronicCond_Heartfailure INT,
    AdmissionDt DATE,
    DischargeDt DATE
);

INSERT INTO HospitalVisits (BeneID, ChronicCond_Alzheimer, ChronicCond_Heartfailure, AdmissionDt, DischargeDt) VALUES
('B001', 0, 1, '2022-01-10', '2022-01-14'),
('B002', 1, 0, '2022-02-15', '2022-02-20'),
('B001', 0, 1, '2022-03-12', '2022-03-16'),
('B003', 0, 0, '2022-04-22', '2022-04-26'),
('B004', 1, 1, '2022-05-18', '2022-05-22');

-- Creating a Hospitals and Facilities Table
CREATE TABLE Hospitals_Facilities (
    Hospital_code VARCHAR(5),
    Hospital_region_code VARCHAR(10),
    BedGrade CHAR(1),
    AdmissionDt DATE,
    DischargeDt DATE
);
INSERT INTO Hospitals_Facilities (Hospital_code, Hospital_region_code, BedGrade, AdmissionDt, DischargeDt) VALUES
('H001', 'North', 'A', '2022-01-10', '2022-01-15'),
('H002', 'South', 'B', '2022-02-12', '2022-02-18'),
('H001', 'North', 'A', '2022-03-05', '2022-03-10'),
('H003', 'East', 'C', '2022-04-20', '2022-04-28'),
('H002', 'South', 'B', '2022-05-25', '2022-06-01');


-- Ensure your database system uses the correct functions for date calculations;
-- The example below uses SQL Server syntax
---pulling blanks
SELECT ClmDiagnosisCode_1, COUNT(*) AS Frequency
FROM [dbo].[Claims]
WHERE ClaimStartDt >= DATEADD(year, -1, GETDATE()) 
GROUP BY ClmDiagnosisCode_1
ORDER BY Frequency DESC
--select * from [dbo].[Claims]
--SELECT MIN(ClaimStartDt), MAX(ClaimStartDt) FROM [dbo].[Claims];
---Trouble shooting
SELECT ClmDiagnosisCode_1, COUNT(*) AS Frequency
FROM [dbo].[Claims]
GROUP BY ClmDiagnosisCode_1
--the query is deriving insight into the top 3 diagnosis code with 
--the most frequent hospital visit, this analysis provides
--answers if some certain hospitals region or bedgrades are in connection 
--with longer or shorter patients stays in the hospital, which can 
--potentially indicate the need for process improvements or adjuatments in providing care.
SELECT TOP 3 ClmDiagnosisCode_1, COUNT(*) AS Frequency
FROM [dbo].[Claims]
WHERE ClaimStartDt BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY ClmDiagnosisCode_1
ORDER BY Frequency DESC;

select * from [dbo].[HospitalVisits]

----2The Analysis involves the HospitalStays table were there are chronice condition indicatorsfor each patient
SELECT Department, AVG(CAST(DATEDIFF(day, AdmissionDt, DischargeDt) AS DECIMAL(10,2))) AS AverageStayLength
FROM HospitalStays
GROUP BY Department;
--cast the result of DATEDIFF to DECIMAL(10,2) to ensure I get the average in 
--days with decimal places for a more precise measurement.

--used the DATEDIFF function to calculate the difference in days for each stay, 
--and then calculate the average of these differences for each department.

--For Patients with Chronic Conditions--3
SELECT 
  ChronicCondition,
  AVG(CAST(NumberOfVisits AS DECIMAL(10,2))) AS AverageVisits
FROM (
  SELECT 
    BeneID,
    CASE 
      WHEN ChronicCond_Alzheimer > 0 OR ChronicCond_Heartfailure > 0 -- include all chronic condition columns here, I only checked for 1
      THEN 'Yes'
      ELSE 'No'
    END AS ChronicCondition,
    COUNT(*) AS NumberOfVisits
  FROM HospitalVisits
  GROUP BY BeneID, ChronicCond_Alzheimer, ChronicCond_Heartfailure 
) AS PatientVisits
GROUP BY ChronicCondition;
--select * from
--[dbo].[HospitalVisits]
---Correlation Between Length of Stay and Readmissions---4
WITH ReadmissionData AS (
  SELECT 
    hs.BeneID,
    DATEDIFF(day, hs.AdmissionDt, hs.DischargeDt) AS LengthOfStay,
    (SELECT COUNT(*)
     FROM HospitalStays hs2 
     WHERE hs2.BeneID = hs.BeneID 
     AND hs2.AdmissionDt > hs.DischargeDt
     AND hs2.AdmissionDt <= DATEADD(day, 30, hs.DischargeDt)
    ) AS ReadmissionsWithin30Days
  FROM HospitalStays hs
)
SELECT 
  AVG(CAST(LengthOfStay AS DECIMAL(10,2))) AS AverageLengthOfStay,
  AVG(CAST(ReadmissionsWithin30Days AS DECIMAL(10,2))) AS AverageReadmissionsWithin30Days
FROM ReadmissionData;

--Question: Determine the impact of hospital region and bed grade on patient stay length. 
--This can identify if certain regions or hospital wards are associated with 
--longer stays, which could suggest a need for process improvements.    5
SELECT * FROM [dbo].[Hospitals_Facilities]
SELECT * FROM [dbo].[HospitalStays]
SELECT * FROM [dbo].[HospitalVisits]
SELECT 
  Hospital_region_code, 
  BedGrade, 
  AVG(CAST(DATEDIFF(day, AdmissionDt, DischargeDt) AS DECIMAL(10,2))) AS AverageStayLength
FROM Hospitals_Facilities
GROUP BY Hospital_region_code, BedGrade
ORDER BY Hospital_region_code, BedGrade;

--Question: Count the total number of claims associated with each unique diagnosis code.
--This can help the hospital prepare by understanding the volume of claims per diagnosis.
SELECT 
  ClmDiagnosisCode_1, 
  COUNT(*) AS TotalClaims
FROM Claims
GROUP BY ClmDiagnosisCode_1;

--Question: Assess the average hospital stay length for patients with at least
--one chronic condition. This requires joining the data on hospital visits
--with a flag for chronic conditions, and then computing the average stay.

SELECT 
  AVG(CAST(DATEDIFF(day, hv.AdmissionDt, hv.DischargeDt) AS DECIMAL(10,2))) AS AverageStayLength
FROM HospitalVisits hv
JOIN (
  SELECT 
    BeneID, 
    CASE 
      WHEN ChronicCond_Alzheimer > 0 OR ChronicCond_Heartfailure > 0 -- include all necessary chronic condition checks
      THEN 'Chronic'
      ELSE 'Non-Chronic'
    END AS ConditionStatus
  FROM HospitalVisits
  GROUP BY BeneID, ChronicCond_Alzheimer, ChronicCond_Heartfailure -- include all necessary chronic condition columns
) AS ChronicStatus
ON hv.BeneID = ChronicStatus.BeneID
WHERE ChronicStatus.ConditionStatus = 'Chronic';

--Question: Determine the relationship between the bed grade, hospital region,
--and readmission rates within 30 days. This could indicate how the quality of the 
--facilities and regional management practices might influence patient outcomes.

WITH Readmissions AS (
  SELECT 
    hs.BeneID,
    COUNT(*) AS ReadmissionCount
  FROM HospitalStays hs
  WHERE EXISTS (
    SELECT 1 
    FROM HospitalStays hs2 
    WHERE hs2.BeneID = hs.BeneID 
    AND hs2.AdmissionDt > hs.DischargeDt
    AND hs2.AdmissionDt <= DATEADD(day, 30, hs.DischargeDt)
  )
  GROUP BY hs.BeneID
)
SELECT 
  hf.Hospital_region_code, 
  hf.BedGrade, 
  AVG(CAST(Readmissions.ReadmissionCount AS DECIMAL(10,2))) AS AverageReadmissions
FROM Hospitals_Facilities hf
JOIN HospitalStays hs ON hf.Hospital_code = hs.Hospital_code
JOIN Readmissions ON hs.BeneID = Readmissions.BeneID
GROUP BY hf.Hospital_region_code, hf.BedGrade
ORDER BY AverageReadmissions DESC;

WITH Readmissions AS (
  SELECT 
    hs.BeneID,
    DATEDIFF(day, hs.AdmissionDt, hs.DischargeDt) AS StayLength,
    CASE 
      WHEN EXISTS (
        SELECT 1
        FROM HospitalStays hs2
        WHERE hs2.BeneID = hs.BeneID
        AND hs2.AdmissionDt > hs.DischargeDt
        AND hs2.AdmissionDt <= DATEADD(day, 30, hs.DischargeDt)
      ) THEN 1
      ELSE 0
    END AS Readmission
  FROM HospitalStays hs
)
SELECT 
  hf.BedGrade, 
  COUNT(*) AS TotalStays,
  SUM(Readmission) AS TotalReadmissions,
  AVG(CAST(Readmissions.StayLength AS DECIMAL(10,2))) AS AverageStayLength,
  CAST(SUM(Readmission) AS DECIMAL(10,2)) / COUNT(*) AS ReadmissionRate
FROM Hospitals_Facilities hf
JOIN Readmissions ON hf.BeneID = Readmissions.BeneID -- Assuming a common BeneID or other join logic
GROUP BY hf.BedGrade;


-- Add a new column Hospital_code to HospitalStays table
ALTER TABLE HospitalStays
ADD Hospital_code VARCHAR(5);

-- Update the Hospital_code for each record
UPDATE HospitalStays
SET Hospital_code = CASE 
    WHEN BeneID = 'B001' THEN 'H001'
    WHEN BeneID = 'B002' THEN 'H002'
    WHEN BeneID = 'B003' THEN 'H001'
    WHEN BeneID = 'B004' THEN 'H003'
    WHEN BeneID = 'B005' THEN 'H002'

END;

-- Verify the updates
SELECT * FROM HospitalStays;
