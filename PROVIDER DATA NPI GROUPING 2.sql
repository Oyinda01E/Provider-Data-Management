--create Cte and use it later

;WITH original 
AS
(
SELECT DISTINCT provider_npi AS ClientIdentifier
, 1 AS isEnabled
, CASE WHEN Indiv_Flag = 'Individual' THEN 1 ELSE 0 END AS IsIndividual
, accepts_new_patients AS AcceptsNewPatients
, Null AS Name_Prefix
, First_Name AS First_Name
, Middle_Name AS Middle_Name
, Last_Name as Lat_Name
, null as Name_Suffix
, prov2.ProvSex AS Gender
, prov2.ProvDegree AS Credentials
, prov.GroupName AS Organization_DBA
, provider_npi AS NPI
, CASE WHEN pdf_Category = 'Primary Care Provider' THEN 1 ELSE 0 END AS is_PCP
FROM [New Excel Edited] AS ex
INNER JOIN prov_group_table AS prov ON prov.ProviderNPI = ex.provider_npi
INNER JOIN ummh_prov AS prov2 ON ex.Provider_NPI = prov2.RecordKey)

SELECT NPI, COUNT(DISTINCT(IS_PCP)) AS Countofrecords
FROM original
WHERE is_pcp <> 0 --remove the record where ispcp =0
GROUP BY NPI
HAVING COUNT(DISTINCT(is_pcp)) = 2
