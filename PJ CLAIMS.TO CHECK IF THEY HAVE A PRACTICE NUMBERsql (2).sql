-- step 1 check if provider exists
-- SELECT * FROM amiown.PROVIDER WHERE trim(PROV_NBR) in ('{Rending NPI or Billing NPI if no Rendering}')
SELECT IMAGE_RECNBR, PROV_NBR, DEGREE, FIRSTNAME, INSTNAME, LANG01, LASTNAME, NPI, PROVCAT, SEX, SPEC1, YMDTRANS, YRBEGIN, YMDBIRTH, TRANSCODE, OP_NBR FROM amiown.PROVIDER 
WHERE trim(PROV_NBR) in 
('1841246964')
ORDER BY PROV_NBR

-- step 2 check if provider address exists
-- SELECT * FROM amiown.ADDRESS WHERE ADDR_WHO LIKE '%{NPI from Step 1}%'
SELECT * FROM amiown.ADDRESS WHERE ADDR_WHO LIKE '%1366469728%';

--SELECT DISTINCT NPI, FULL_NAME, NAME_FIRST, NAME_LAST, ADDRESS_STREET, ADDRESS_CITY, STATE, ZIP FROM amiown.Provider_scf WHERE ENTITY_TYPE = '85' AND
--TRIM(NPI) IN ('1184377376','1225371107','1417965369','1588908388','1619986114','1639401169','1700865094','1760418370','1821124900','1942601570','1992995880')

-- Step 3 if not pay to self need to see if Group exists
-- SELECT * FROM amiown.GROUP_PRACTICE_M WHERE trim(NPI) = '{Billing NPI}' AND IRS_NBR = '{Billing Tax ID}'
SELECT * FROM amiown.GROUP_PRACTICE_M WHERE trim(NPI) = '1902856024' AND IRS_NBR = '043159969'

-- If Group Exists Note the PRAC_NBR
-- If Group Does Not Exist.  Find the next available PROC_NBR open greater then 5000
SELECT * FROM amiown.GROUP_PRACTICE_M  WHERE PRAC_NBR > 5000 ORDER BY PRAC_NBR DESC;

--  Step 4 If Group Exists then check if Address exists
-- SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) LIKE '%G {PRAC_NBR from Step 3}%';
SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) LIKE '%G 5062%';

-- If there is a Pay to address the confirm that the Group has a 'F' Financial address
-- ADDRTYPE_WHO would start with 'F' if there is a financial address.

-- Step 5 Check if IRS record exists
-- SELECT * FROM amiown.IRS_M WHERE trim(IRS_NBR) IN ('{TAX ID from Step 3}') 
SELECT * FROM amiown.IRS_M WHERE trim(IRS_NBR) IN ('043159969'), '270050256','593769572','852949721')

-- Step 6 Check if IRS Address record exists
--SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) = 'IR{Billing Tax ID}';
SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) = 'IR043159969';

-- if not W9 is on file then IR Address will not exist.

-- Step 7 Check if Affiliation Record Exists
--SELECT * FROM amiown.AFFILIATION WHERE trim(IRS_NBR) = {{Billing Tax Id}' AND trim(PROV_NBR) = '{Rending NPI}' and VOID != 'V '
SELECT * FROM amiown.AFFILIATION WHERE trim(IRS_NBR) = '812751049' AND trim(PROV_NBR) = '1275287815' and VOID != 'V '

SELECT * FROM amiown.AFFILIATION WHERE trim(NPI) = '1881340826' AND IRS_NBR = '872780671' and VOID != 'V ' 

-- DONE

-- If you need to look up Providers on a claim.
-- 87 Pay to
-- 82 Rendering
-- DN Referring
-- 85 Billing
-- P3 Rendering PCP
-- 77 Service Facility Location
SELECT * FROM amiown.PROVIDER_SCF WHERE CLAIM_NBR = '221040E00019'

