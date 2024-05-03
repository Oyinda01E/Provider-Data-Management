-- step 1 check if provider exists
-- SELECT * FROM amiown.PROVIDER WHERE trim(PROV_NBR) in ('{Rending NPI or Billing NPI if no Rendering}')
SELECT * FROM amiown.PROVIDER WHERE trim(PROV_NBR) in ('1639412976');
SELECT * FROM amiown.PROVIDER WHERE INSTNAME like '%HEALTH%ALLIANCE%';


-- step 2 check if provider address exists
-- SELECT * FROM amiown.ADDRESS WHERE ADDR_WHO LIKE '%{NPI from Step 1}%'
SELECT * FROM amiown.ADDRESS WHERE ADDR_WHO LIKE '%1821050535%';

-- Step 3 if not pay to self need to see if Group exists
-- SELECT * FROM amiown.GROUP_PRACTICE_M WHERE trim(NPI) = '{Billing NPI}' AND IRS_NBR = '{Billing Tax ID}'
SELECT * FROM amiown.GROUP_PRACTICE_M WHERE trim(NPI) = '1538194980' AND IRS_NBR = '042704683';

SELECT * FROM amiown.GROUP_PRACTICE_M WHERE IRS_NBR = '800482067';

SELECT * FROM amiown.GROUP_PRACTICE_M WHERE NAME_X like '%HEALTHALLIANCE%';

-- If Group Exists Note the PRAC_NBR
-- If Group Does Not Exist.  Find the next available PRAC_NBR open greater then 5000
SELECT * FROM amiown.GROUP_PRACTICE_M  WHERE PRAC_NBR > 5000 ORDER BY PRAC_NBR DESC;

--  Step 4 If Group Exists then check if Address exists
-- SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) LIKE '%G {PRAC_NBR from Step 3}%';
SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) LIKE '%G 5179%';

-- If there is a Pay to address the confirm that the Group has a 'F' Financial address
-- ADDRTYPE_WHO would start with 'F' if there is a financial address.

-- Step 5 Check if IRS record exists
-- SELECT * FROM amiown.IRS_M WHERE trim(IRS_NBR) IN ('{TAX ID from Step 3}') 
SELECT * FROM amiown.IRS_M WHERE trim(IRS_NBR) IN ('853789567',
'042513817',
'042704683',
'043163589',
'043235796',
'042704683',
'042704683',
'273267315',
'043554035',
'272538057',
'872780671',
'943295573',
'042103581',
'042103581',
'042103581',
'205054049',
'043329067',
'273210819',
'043466314',
'043466314');

-- Step 6 Check if IRS Address record exists
--SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) = 'IR{Billing Tax ID}';
SELECT * FROM amiown.ADDRESS WHERE TRIM(ADDR_WHO) LIKE '%042704683%';

-- if not W9 is on file then IR Address will not exist.

-- Step 7 Check if Affiliation Record Exists
--SELECT * FROM amiown.AFFILIATION WHERE trim(IRS_NBR) = {{Billing Tax Id}' AND trim(PROV_NBR) = '{Rending NPI}' and VOID != 'V '
SELECT * FROM amiown.AFFILIATION WHERE trim(IRS_NBR) = '042704683' AND trim(PROV_NBR) = '1639412976' and VOID != 'V ';
SELECT * FROM amiown.AFFILIATION WHERE trim(PROV_NBR) = '1821050535' and VOID != 'V ';

SELECT * FROM amiown.AFFILIATION WHERE trim(IRS_NBR) = '270705150' and VOID != 'V ' AND pay_class = 'PRVDNYW9';
