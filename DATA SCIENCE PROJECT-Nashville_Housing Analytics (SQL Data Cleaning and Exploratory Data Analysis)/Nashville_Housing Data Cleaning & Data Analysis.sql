--====================================================================================================
-----------------------------------------------START----------------------------------------------------
--====================================================================================================
SELECT *
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

--====================================================================================================
-- DATA PREPROCESSING :
--====================================================================================================

--====================================================================================================
-- 1) DATE TYPE CONVERSION :
--====================================================================================================
SELECT SaleDate
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
-- It is in the form of DateTime, Lets convert them back to DATE type

ALTER TABLE Nashville_Housing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

--====================================================================================================
-- 2) PROPERTY ADDRESS NULL VALUES :
--====================================================================================================
SELECT *
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE PropertyAddress IS NULL

SELECT COUNT([UniqueID ]) AS No_Of_Null_Values
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE PropertyAddress IS NULL
-- 29 Rows
-- There are some Null Values in the Property Address Column, 
-- Lets populate the Data with some reference point.

SELECT *
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
ORDER BY ParcelID
-- WE could Identify certain pattern that all the Similar Parcel_ID has the Similar Property Address Data, 
-- Therefore lets populate the Property Address Based on the Similar Parcel_ID.

SELECT A.[UniqueID ], A.ParcelID, A.PropertyAddress, B.[UniqueID ], B.ParcelID, B.PropertyAddress
FROM [Portfolio_Projects].[dbo].[Nashville_Housing] A,
 [Portfolio_Projects].[dbo].[Nashville_Housing] B
WHERE A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
AND B.PropertyAddress IS NULL

SELECT *
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE PropertyAddress IS NULL
  AND ParcelID IN (
    SELECT ParcelID
    FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
    WHERE PropertyAddress IS NOT NULL
  );

SELECT COUNT(*)
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE PropertyAddress IS NULL
  AND ParcelID IN (
    SELECT ParcelID
    FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
    WHERE PropertyAddress IS NOT NULL
  );
-- 29 Rows

-- FILL NULL VALUES:
UPDATE [Portfolio_Projects].[dbo].[Nashville_Housing]
Set PropertyAddress = ISNULL(PropertyAddress, (
  SELECT TOP 1 PropertyAddress
  FROM [Portfolio_Projects].[dbo].[Nashville_Housing] T2
  WHERE T2.ParcelID = Nashville_Housing.ParcelID
  AND T2.PropertyAddress IS NOT NULL
))
WHERE PropertyAddress IS NULL;

SELECT *
FROM Portfolio_Projects.dbo.Nashville_Housing
WHERE PropertyAddress IS NULL;

--====================================================================================================
-- 3) Break Property Address Into Individual Columns (Address, City, State) :
--====================================================================================================
SELECT PropertyAddress
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

SELECT LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS SplitPropertyAddress,
LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)))
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

ALTER TABLE Nashville_Housing
ADD SplitPropertyAddress NVARCHAR(255),
    SplitPropertyCity NVARCHAR(255);

UPDATE [Portfolio_Projects].[dbo].[Nashville_Housing]
SET SplitPropertyAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1), 
    SplitPropertyCity = LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)));

--====================================================================================================
-- 4) Investigate Null Values in Owner Name Data :
--====================================================================================================
SELECT *
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE OwnerName IS NULL

SELECT COUNT(*)
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE OwnerName IS NULL
-- 31216 Rows of null values, this is huge number of data we cant remove them.

--====================================================================================================
-- 5) SPLIT Owner Address INTO (Address, City, State) :
--====================================================================================================
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Projects.dbo.Nashville_Housing

ALTER TABLE [Portfolio_Projects].[dbo].[Nashville_Housing]
ADD SplitOwner_Address_1 NVARCHAR(225), 
    SplitOwner_City NVARCHAR(225), 
    SplitOwner_State NVARCHAR(225)

UPDATE [Portfolio_Projects].[dbo].[Nashville_Housing]
SET SplitOwner_Address_1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
    SplitOwner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
    SplitOwner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Portfolio_Projects.dbo.Nashville_Housing

--====================================================================================================
-- 6) INCONSISTENCY IN SoldASVacant :
--====================================================================================================
SELECT DISTINCT SoldAsVacant
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

SELECT SoldAsVacant, COUNT(*)
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY SoldAsVacant
ORDER BY COUNT(*) DESC

-- Replace Y as Yes and N as No:
SELECT SoldAsVacant, 
       (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
             WHEN SoldAsVacant = 'N' THEN 'No'
             ELSE SoldAsVacant
             END) AS NewSoldVacant
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE SoldAsVacant = 'Y'
OR SoldAsVacant = 'N'

-- Optional Y & N instead of Yes or No
SELECT DISTINCT(LEFT(SoldAsVacant, 1))
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- Update
UPDATE [Portfolio_Projects].[dbo].[Nashville_Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END

SELECT SoldAsVacant, COUNT(*)
FROM Portfolio_Projects.dbo.Nashville_Housing
GROUP BY SoldAsVacant

------------------------------------------------------------------------------------------------------

--====================================================================================================
-- DATA ANALYSIS :
--====================================================================================================
SELECT * 
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
--====================================================================================================
-- 1) TOTAL RECORDS :
--====================================================================================================
SELECT COUNT(DISTINCT [UniqueID ]) AS Total_Records
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + ------------- +
-- | Total_Records |
-- + ------------- +
-- +    56477      +
-- + ------------- +

--====================================================================================================
-- 2) AVERAGE HOUSE PRICE :
--====================================================================================================
SELECT AVG(SalePrice) AS Average_House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + -------------- +
-- | Avg_HousePrice |
-- + -------------- +
-- +   327226       +
-- + -------------- +

--====================================================================================================
-- 3) MINIMUM HOUSE PRICE AND MAXIMUM HOUSE PRICE :
--====================================================================================================
SELECT MIN(SalePrice) AS Minimum_House_Price, 
       MAX(SalePrice) AS Maximum_House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + ---------------- + ---------------- +
-- |  Min_HousePrice  |  Max_HousePrice  |
-- + ---------------- + ---------------- +
-- +      50          +     54278060     +
-- + ---------------- + ---------------- +

--====================================================================================================
-- 4) PERCENTAGE OF HOUSE ON SOLD AS VACANT :
--====================================================================================================
SELECT SoldAsVacant, (COUNT(DISTINCT [UniqueID ])*100/(
  SELECT COUNT(DISTINCT [UniqueID ]) FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
  )) AS Percentage_Of_Houses
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY SoldAsVacant

-- + ---------------- + ---------------- +
-- |  Sold_As_Vacant  |  Per%_of_Houses  |
-- + ---------------- + ---------------- +
-- +      No          +     91 %         +
-- +      Yes         +     8 %          +
-- + ---------------- + ---------------- +

--====================================================================================================
-- 5) NUMBER OF PROPERTIES BY LAND USE :
--====================================================================================================
SELECT TOP 10 LandUse, COUNT(DISTINCT [UniqueID ]) AS No_Of_Properties
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY LandUse
ORDER BY No_Of_Properties DESC

-- + -------------------------- + ---------------- +
-- |      Land_Use              | No_Of_Properties |
-- + -------------------------- + ---------------- +
-- +  SINGLE FAMILY	            +      34197       +
-- +  RESIDENTIAL CONDO  	    +      14080       +
-- +  VACANT RESIDENTIAL LAND	+      3547        +
-- +  VACANT RES LAND	        +      1549        +
-- +  DUPLEX	                +      1373        +
-- +  ZERO LOT LINE	            +      1048        +
-- +  CONDO	                    +      247         + 
-- +  RESIDENTIAL COMBO/MISC	+      95          +
-- +  TRIPLEX	                +      92          + 
-- +  QUADPLEX	                +      39          +
-- + -------------------------- + ---------------- +

--====================================================================================================
-- 6) AVERAGE LAND VALUE :
--====================================================================================================
SELECT ROUND(AVG(LandValue), 2) AS Average_Land_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + -------------- +
-- | Avg_LandValue  |
-- + -------------- +
-- +   69068.56     +
-- + -------------- +

--====================================================================================================
-- 7) TOP 10 PROPERTY ADDRESS BY AVERAGE LAND VALUE :
--====================================================================================================
SELECT TOP 10 PropertyAddress, AVG(LandValue) AS Average_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY PropertyAddress
ORDER BY Average_LandValue DESC;

-- + ---------------------------------- + ------------------ +
-- |      PropertyAddress               | Average LandValue  |   
-- + ---------------------------------- + ------------------ +
-- + 0  CHARLOTTE PIKE, NASHVILLE	    +     2772000        +
-- + 7211  CAROTHERS RD, NOLENSVILLE	+     1921700        +
-- + 105  BELLE MEADE BLVD, NASHVILLE	+     1869000        +
-- + 540  JACKSON BLVD, NASHVILLE	    +     1830700        +
-- + 1303 CHICKERING  RD, NASHVILLE	    +     1603800        + 
-- + 4404  CHICKERING LN, NASHVILLE	    +     1567600        +
-- + 1800  CHICKERING RD, NASHVILLE	    +     1392800        +
-- + 1403  CHICKERING RD, NASHVILLE	    +     1276000        +
-- + 1624  CHICKERING RD, NASHVILLE	    +     1264000        +
-- + 4406  CHICKERING LN, NASHVILLE	    +     1255500        +
-- + ---------------------------------- + ------------------ +

--====================================================================================================
-- 8) TOP 10 PROPERTY ADDRESS BY HOUSE PRICE :
--====================================================================================================
SELECT TOP 10 PropertyAddress, SUM(SalePrice) AS HousePrice
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE SalePrice IS NOT NULL
GROUP BY PropertyAddress
ORDER BY HousePrice DESC;

-- + ----------------------------------- + ------------- + 
-- |      Property Address               |    HousePrice |
-- + ----------------------------------- + ------------- +
-- +   320  11TH AVE S, NASHVILLE	     +     384692022 +
-- +   6680  CHARLOTTE PIKE, NASHVILLE	 +     247562900 +
-- +   1212  LAUREL ST, NASHVILLE	     +     173559324 +
-- +   6901  LENOX VILLAGE DR, NASHVILLE +     108000000 +
-- +   600  12TH AVE S, NASHVILLE	     +     81857941  +
-- +   900  20TH AVE S, NASHVILLE	     +     58488399  +
-- +   301  DEMONBREUN ST, NASHVILLE	 +     49332073  +
-- +   1382  RURAL HILL RD, ANTIOCH	     +     45689191  +
-- +   415  CHURCH ST, NASHVILLE	     +     39164933  +
-- +   270  TAMPA DR, NASHVILLE	         +     35441900  +
-- + ----------------------------------- + --------------+

--====================================================================================================
-- 9) HOUSE PRICE BY SALE DATE (MONTH, QUARTER, YEAR) :
--====================================================================================================
SELECT DATENAME(MONTH, SaleDate) AS Month_Name, 
       SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE SalePrice IS NOT NULL
GROUP BY DATENAME(MONTH, SaleDate)
ORDER BY House_Price DESC;

-- + ------------- + -------------- +
-- |  Month Name   |  House Price   |
-- + ------------- + -------------- +
-- +    January	   +    2155382094  +
-- +    June	   +    1978451943  +
-- +    August	   +    1800308075  +
-- +    May	       +    1765649668  +
-- +    July	   +    1758217830  +
-- +    September  +    1672552371  +
-- +    April	   +    1569431847  +
-- +    December   +    1531829638  +
-- +    October	   +    1329782558  +
-- +    March	   +    1191059922  +
-- +    November   +    1044454378  +
-- +    February   +    683643350   +
-- + ------------- + -------------- +

SELECT DATEPART(QUARTER, SaleDate) AS Quarter_Type, 
       SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE SalePrice IS NOT NULL
GROUP BY DATEPART(QUARTER, SaleDate)
ORDER BY House_Price DESC;

-- + ------------- + -------------- +
-- |  Quarter Type |  House Price   |
-- + ------------- + -------------- +
-- +    2	       +    5313533458  +
-- +    3	       +    5231078276  +
-- +    1	       +    4030085366  +
-- +    4	       +    3906066574  +
-- + ------------- + -------------- +

SELECT YEAR(SaleDate) AS Year_Type, 
       SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE SalePrice IS NOT NULL
GROUP BY YEAR(SaleDate)
ORDER BY House_Price DESC;

-- + ---------- + -------------- +
-- |  Year Type |  House Price   |
-- + ---------- + -------------- +
-- +    2015    +   6708933320   +
-- +    2014    +   4773448818   +
-- +    2016	+   4236375528   +
-- +    2013    +   2761769008   +
-- +    2019    +   237000       +
-- + ---------- + -------------- +

--====================================================================================================
-- 10) NUMBER OF HOUSE BY SALE DATE (MONTH, QUARTER, YEAR) :
--====================================================================================================
SELECT DATENAME(MONTH, SaleDate) AS Month_Name, 
       COUNT(DISTINCT [UniqueID ]) AS House_Num
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY DATENAME(MONTH, SaleDate)
ORDER BY House_Num DESC;

-- + ------------- + -------------- +
-- |  Month Name   |  House Price   |
-- + ------------- + -------------- +
-- +    January	   +    2155382094  +
-- +    June	   +    1978451943  +
-- +    August	   +    1800308075  +
-- +    May	       +    1765649668  +
-- +    July	   +    1758217830  +
-- +    September  +    1672552371  +
-- +    April	   +    1569431847  +
-- +    December   +    1531829638  +
-- +    October	   +    1329782558  +
-- +    March	   +    1191059922  +
-- +    November   +    1044454378  +
-- +    February   +    683643350   +
-- + ------------- + -------------- +

SELECT DATEPART(QUARTER, SaleDate) AS Quarter_Type, 
       COUNT(DISTINCT [UniqueID ]) AS House_Num
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY DATEPART(QUARTER, SaleDate)
ORDER BY House_Num DESC;

-- + ------------- + -------------- +
-- |  Quarter Type |  House Price   |
-- + ------------- + -------------- +
-- +    2	       +    5313533458  +
-- +    3	       +    5231078276  +
-- +    1	       +    4030085366  +
-- +    4	       +    3906066574  +
-- + ------------- + -------------- +

SELECT YEAR(SaleDate) AS Year_Type, 
       COUNT(DISTINCT [UniqueID ]) AS House_Num
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
GROUP BY YEAR(SaleDate)
ORDER BY House_Num DESC;

-- + ---------- + -------------- +
-- |  Year Type |  House Price   |
-- + ---------- + -------------- +
-- +    2015    +   6708933320   +
-- +    2014    +   4773448818   +
-- +    2016	+   4236375528   +
-- +    2013    +   2761769008   +
-- +    2019    +   237000       +
-- + ---------- + -------------- +

--====================================================================================================
-- 11) AVERAGE LAND VALUE BY DATE (MONTH, QUARTER, YEAR) :
--====================================================================================================
SELECT DATENAME(MONTH, SaleDate) AS Month_Name, 
       ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATENAME(MONTH, SaleDate)
ORDER BY Avg_LandValue DESC;

-- + ------------- + -------------- +
-- |  Month Name   |  Avg Landvalue |
-- + ------------- + -------------- +
-- +    June	   +    77585       +
-- +    May	       +    73258.99    +
-- +    August	   +    70585.94    +
-- +    April	   +    70424.98    +
-- +    July	   +    69254.63    +
-- +    September  +    68526.66    +
-- +    December   +    68432.79    +
-- +    January    +    67058.23    +
-- +    February   +    65393.89    +
-- +    October	   +    64354.43    +
-- +    November   +    64125.08    +
-- +    March      +    61040.48    +
-- + ------------- + -------------- +

SELECT DATEPART(QUARTER, SaleDate) AS Quarter_Type, 
       ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATEPART(QUARTER, SaleDate)
ORDER BY Avg_LandValue DESC;

-- + ------------- + ---------------- +
-- |  Quarter Type |  Avg LandValue   |
-- + ------------- + ---------------- +
-- +    2	       +    74069.77      +
-- +    3	       +    69468.92      +
-- +    4	       +    65579.18      +
-- +    1	       +    63979.93      +
-- + ------------- + ---------------- +

SELECT YEAR(SaleDate) AS Year_Type, 
       ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY YEAR(SaleDate)
ORDER BY Avg_LandValue DESC;

-- + ---------- + ---------------- +
-- |  Year Type |  Avg LandValue   |
-- + ---------- + ---------------- +
-- +    2013    +   77598.62       +
-- +    2014    +   72018.01       +
-- +    2015	+   65274.82       +
-- +    2016    +   63474.37       +
-- +    2019    +   22000          +
-- + ---------- + ---------------- +

--====================================================================================================
-- 12) AVERAGE BUILDING VALUE :
--====================================================================================================
SELECT ROUND(AVG(BuildingValue), 2) AS Average_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + ------------------ + 
-- | Avg Building Value |
-- + ------------------ +
-- +     160784.68      +
-- + ------------------ +

--====================================================================================================
-- 13) AVERAGE BUILDING VALUE BY DATE (MONTH, QUARTER, YEAR) :
--====================================================================================================
SELECT DATENAME(MONTH, SaleDate) AS Month_Name, 
       ROUND(AVG(BuildingValue), 2) AS Average_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATENAME(MONTH, SaleDate)
ORDER BY Average_BuildingValue DESC;

-- + ------------- + -------------------- +
-- |  Month Name   |  Avg BuildingValue   |
-- + ------------- + -------------------- +
-- +    June	   +    174063.46         +
-- +    July	   +    165258.44         +
-- +    November   +    163839.68         +
-- +    May	       +    161965.66         +
-- +    April	   +    161542.65         +
-- +    August     +    159718.2          +
-- +    January	   +    158152.44         +
-- +    Febraury   +    158148.32         +
-- +    October	   +    156452.74         +
-- +    December   +    155924.21         +
-- +    March      +    154418.89         +
-- +    September  +    152468.52         +
-- + ------------- + -------------------- +
	
SELECT DATEPART(QUARTER, SaleDate) AS Quarter_Type, 
       ROUND(AVG(BuildingValue), 2) AS Average_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATEPART(QUARTER, SaleDate)
ORDER BY Average_BuildingValue DESC;

-- + ------------- + -------------------- +
-- |  Quarter Type |  Avg BuildingValue   |
-- + ------------- + -------------------- +
-- +    2	       +    166402.98         +
-- +    3	       +    159263.19         +
-- +    4	       +    158283.51         +
-- +    1	       +    156521.13         +
-- + ------------- + -------------------- +

SELECT YEAR(SaleDate) AS Year_Type, 
       ROUND(AVG(BuildingValue), 2) AS Average_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY YEAR(SaleDate)
ORDER BY Average_BuildingValue DESC;

-- + ---------- + -------------------- +
-- |  Year Type |  Avg BuildingValue   |
-- + ---------- + -------------------- +
-- +    2013    +   177951.29          +
-- +    2014    +   174272.34          +
-- +    2015	+   158393.93          +
-- +    2016    +   136316.55          +
-- +    2019    +   67500              +
-- + ---------- + -------------------- +

--====================================================================================================
-- 14) TOP 10 PROPERTY ADDRESS BY AVERAGE BUILDING VALUE :
--====================================================================================================
SELECT TOP 10 PropertyAddress, AVG(BuildingValue) AS Average_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE BuildingValue IS NOT NULL
GROUP BY PropertyAddress
ORDER BY Average_BuildingValue DESC;

-- + ----------------------------------- + -------------- + 
-- |      Property Address               | Avg_BuildValue |
-- + ----------------------------------- + -------------- +
-- +   2800  MCGAVOCK PIKE, NASHVILLE    +     12971800   +
-- +   4225  FRANKLIN PIKE, NASHVILLE	 +     5824300    +
-- +   540  JACKSON BLVD, NASHVILLE	     +     3768000    +
-- +   4321  CHICKERING LN, NASHVILLE    +     3563100    +
-- +   6123  HILLSBORO PIKE, NASHVILLE   +     3456900    +
-- +   4333  CHICKERING LN, NASHVILLE	 +     2691500    +
-- +   1019  STONEWALL DR, NASHVILLE	 +     2673700    +
-- +   4410  TRUXTON PL, NASHVILLE	     +     2493900    +
-- +   874  CURTISWOOD LN, NASHVILLE     +     2490600    +
-- +   34  BANCROFT PL, NASHVILLE        +     2472500    +
-- + ----------------------------------- + -------------- +

--====================================================================================================
-- 15) AVERAGE TOTAL VALUE :
--====================================================================================================
SELECT ROUND(AVG(TotalValue), 2) AvgTotal_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + ------------------ + 
-- |    Avg Value       |
-- + ------------------ +
-- +     232375.4       +
-- + ------------------ +

--====================================================================================================
-- 16) AVERAGE TOTAL VALUE BY DATE (MONTH, QUARTER, YEAR) :
--====================================================================================================
SELECT DATENAME(MONTH, SaleDate) AS Month_Name, 
       ROUND(AVG(TotalValue), 2) AS AvgTotal_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATENAME(MONTH, SaleDate)
ORDER BY AvgTotal_Value DESC;

-- + ------------- + ----------------- +
-- |  Month Name   |  Avg TotalValue   |
-- + ------------- + ----------------- +
-- +    June	   +      254281.74    +
-- +    May	       +      237517.86    +
-- +    July	   +      237161.04    +
-- +    April	   +      234402.81    +
-- +    August	   +      233129.83    +
-- +    November   +      230308.54    +
-- +    January	   +      227405.16    +
-- +    December   +      226838.9     +
-- +    February   +      226033.74    +
-- +    October	   +      223498.88    +
-- +    September  +      223489.41    +
-- +    March	   +      217941.57    +
-- + ------------- + ----------------- +

SELECT DATEPART(QUARTER, SaleDate) AS Quarter_Type, 
       ROUND(AVG(TotalValue), 2) AS AvgTotal_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY DATEPART(QUARTER, SaleDate)
ORDER BY AvgTotal_Value DESC;

-- + ------------- + -------------- +
-- |  Quarter Type | Avg TotalValue |
-- + ------------- + -------------- +
-- +       2	   +    242935.19   +
-- +       3	   +    231390.44   +
-- +       4	   +    226394.11   +
-- +       1	   +    222901.61   +
-- + ------------- + -------------- +


SELECT YEAR(SaleDate) AS Year_Type, 
       ROUND(AVG(TotalValue), 2) AS AvgTotal_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE LandValue IS NOT NULL
GROUP BY YEAR(SaleDate)
ORDER BY AvgTotal_Value DESC;

-- + ---------- + -------------- +
-- |  Year Type | Avg TotalValue |
-- + ---------- + -------------- +
-- +    2013	+     258462.51  +
-- +    2014	+     249142.25  +
-- +    2015	+     225960.9   +
-- +    2016	+     201931.01  +
-- +    2019	+     89500      +
-- + ---------- + -------------- +

--====================================================================================================
-- 17) TOP 10 PROPERTY ADDRESS BY AVERAGE TOTAL VALUE :
--====================================================================================================
SELECT TOP 10 PropertyAddress, AVG(TotalValue) AS AvgTotal_Value
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE BuildingValue IS NOT NULL
GROUP BY PropertyAddress
ORDER BY AvgTotal_Value DESC;

-- + ----------------------------------- + -------------- + 
-- |      Property Address               | Avg_BuildValue |
-- + ----------------------------------- + -------------- +
-- +   2800  MCGAVOCK PIKE, NASHVILLE    +     13940400   +
-- +   4225  FRANKLIN PIKE, NASHVILLE	 +     6402600    +
-- +   540  JACKSON BLVD, NASHVILLE	     +     5697100    +
-- +   4321  CHICKERING LN, NASHVILLE    +     4455200    +
-- +   6123  HILLSBORO PIKE, NASHVILLE   +     4058100    +
-- +   4410  TRUXTON PL, NASHVILLE   	 +     3723900    +
-- +   4333  CHICKERING LN, NASHVILLE	 +     3500000    +
-- +   4405  WARNER PL, NASHVILLE	     +     3388400    +
-- +   605  BELLE MEADE BLVD, NASHVILLE  +     3290300    +
-- +   4406  CHICKERING LN, NASHVILLE    +     3157400    +
-- + ----------------------------------- + -------------- +

--====================================================================================================
-- 18) AVERAGE ACRE :
--====================================================================================================
SELECT ROUND(AVG(Acreage), 2) AS Average_Acre
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]

-- + ------------------ + 
-- |     Avg Acre       |
-- + ------------------ +
-- +       0.5          +
-- + ------------------ +

--====================================================================================================
-- 19)  TOP 10 PROPERTY ADDRESS BY AVERAGE ACRE VALUE :
--====================================================================================================
SELECT TOP 10 PropertyAddress, AVG(Acreage) AS Average_Acre
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE BuildingValue IS NOT NULL
GROUP BY PropertyAddress
ORDER BY Average_Acre DESC;

-- + ----------------------------------- + --------------- + 
-- |      Property Address               | Avg_Acre        |
-- + ----------------------------------- + --------------- +
-- +   7211  CAROTHERS RD, NOLENSVILLE   +      160.06     +
-- +   0  BELL RD, ANTIOCH	             +      62.96      +
-- +   OLD HICKORY BLVD, NASHVILLE	     +      51.34      +
-- +   144 SCENIC VIEW  RD, OLD HICKORY  +      47.5       +
-- +   0  CHARLOTTE PIKE, NASHVILLE      +      41.24      +
-- +   0  COUCHVILLE PIKE, HERMITAGE   	 +      37.06      +
-- +   3365  HOBSON PIKE, HERMITAGE	     +      35.97      +
-- +   0  HART LN, NASHVILLE	         +      35         +
-- +   2800  MCGAVOCK PIKE, NASHVILLE    +      34.64      +
-- +   0  LEBANON PIKE, HERMITAGE        +      33.9       +
-- + ----------------------------------- + --------------- +

--====================================================================================================
-- 20) TOTAL HOUSE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, COUNT(DISTINCT [UniqueID ]) AS Total_Houses
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY Total_Houses DESC

-- + ---------------------------- + -------------- +
-- |      Tax District            | Total House    |
-- + ---------------------------- + -------------- +   
-- + URBAN SERVICES DISTRICT	  +    20024       +
-- + GENERAL SERVICES DISTRICT	  +    4556        +
-- + CITY OF FOREST HILLS     	  +    407         + 
-- + CITY OF OAK HILL      	      +    393         +
-- + CITY OF GOODLETTSVILLE  	  +    379         + 
-- + CITY OF BELLE MEADE	      +    235         +
-- + CITY OF BERRY HILL   	      +    21          +
-- + ---------------------------- + -------------- +  

--====================================================================================================
-- 21) HOUSE PRICE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY House_Price DESC

--====================================================================================================
-- 22) AVERAGE LAND VALUE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY Avg_LandValue DESC

-- + ---------------------------- + -------------- +
-- |      Tax District            | Total House    |
-- + ---------------------------- + -------------- +   
-- + CITY OF BELLE MEADE	      +    665049.36   +
-- + CITY OF FOREST HILLS	      +    362595.27   +
-- + CITY OF OAK HILL     	      +    262828.98   + 
-- + URBAN SERVICES DISTRICT      +    60960.51    +
-- + GENERAL SERVICES DISTRICT    +    34693.75    + 
-- + CITY OF BERRY HILL	          +    28666.67    +
-- + CITY OF GOODLETTSVILLE   	  +    27239.84    +
-- + ---------------------------- + -------------- +  

--====================================================================================================
-- 23) AVERAGE BUILDING VALUE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, ROUND(AVG(BuildingValue), 2) AS Avg_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY Avg_BuildingValue DESC

-- + ---------------------------- + -------------- +
-- |      Tax District            | Total House    |
-- + ---------------------------- + -------------- +   
-- + CITY OF BELLE MEADE	      +    638208.09   +
-- + CITY OF OAK HILL	          +    445136.83   +
-- + CITY OF FOREST HILLS     	  +    435859.71   + 
-- + URBAN SERVICES DISTRICT      +    156723.75   +
-- + CITY OF BERRY HILL           +    129019.05   + 
-- + GENERAL SERVICES DISTRICT	  +   109478.36    +
-- + CITY OF GOODLETTSVILLE  	  +   107576.78    +
-- + ---------------------------- + -------------- +  

--====================================================================================================
-- 24) TOTAL AVERAGE VALUE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, ROUND(AVG(TotalValue), 2) AS Avg_TotalValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY Avg_TotalValue DESC

-- + ---------------------------- + -------------- +
-- |      Tax District            | Total AvgValue |
-- + ---------------------------- + -------------- +   
-- + CITY OF BELLE MEADE	      +    1317644.68  +
-- + CITY OF FOREST HILLS	      +   804563.33    +
-- + CITY OF OAK HILL     	      +   715183.63    + 
-- + URBAN SERVICES DISTRICT	  +   219961.29    +
-- + CITY OF BERRY HILL  	      +    158466.67   + 
-- + GENERAL SERVICES DISTRICT	  +    146503.52   +
-- + CITY OF GOODLETTSVILLE	      +    136602.37   +
-- + ---------------------------- + -------------- +  

--====================================================================================================
-- 25) AVERAGE ACRE BY TAX DISTRICT :
--====================================================================================================
SELECT TaxDistrict, ROUND(AVG(Acreage), 2) AS Avg_Acre
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY Avg_Acre DESC

-- + ---------------------------- + -------- +
-- |      Tax District            | Avg_Acre |
-- + ---------------------------- + -------- +   
-- + CITY OF FOREST HILLS	      +    2.11  +
-- + CITY OF OAK HILL	          +    1.49  +
-- + CITY OF BELLE MEADE	      +    1.14  + 
-- + GENERAL SERVICES DISTRICT	  +    0.72  +
-- + CITY OF GOODLETTSVILLE	      +    0.62  + 
-- + URBAN SERVICES DISTRICT	  +    0.39  +
-- + CITY OF BERRY HILL	          +    0.15  +
-- + ---------------------------- + -------- +  

--====================================================================================================
-- 26) NUMBER OF HOUSES BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  COUNT(DISTINCT [UniqueID ]) AS Total_Houses
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
GROUP BY Bedrooms
ORDER BY Total_Houses DESC

-- + --------- + -------------- +
-- | BEDROOMS  |  Total_House   |
-- + --------- + -------------- +
-- +     3	   +     12877      + 
-- +     2	   +     5104       +
-- +     4	   +     4856       +
-- +     5	   +     870        +
-- +     6	   +     243        +
-- +     1	   +     102        +
-- +     0	   +     43         +
-- +     7	   +     35         +
-- +     8	   +     22         +
-- +     10	   +      2         +
-- +     9	   +      2         +
-- +     11	   +      1         +
-- + --------- + -------------- +

--====================================================================================================
-- 27) HOUSE PRICE BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
GROUP BY Bedrooms
ORDER BY House_Price DESC

-- + --------- + -------------- +
-- | BEDROOMS  | House Price    |
-- + --------- + -------------- +
-- +     3	   +   2916046894   +
-- +     4	   +   1942960196   +
-- +     2	   +   890962331    +
-- +     5	   +   639254803    +
-- +     6	   +   157140006    +
-- +     7	   +   34213629     +
-- +     0	   +   24361900     +
-- +     1	   +   16974431     +
-- +     8	   +   8116700      +
-- +     10	   +   3300000      +
-- +     11    +   2438500      +
-- +     9	   +   797500       +
-- + --------- + -------------- +

--====================================================================================================
-- 28) AVERAGE LAND VALUE BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
AND LandValue IS NOT NULL
GROUP BY Bedrooms
ORDER BY Avg_LandValue DESC

-- + --------- + -------------- +
-- | BEDROOMS  | Avg_LandValue  |
-- + --------- + -------------- +
-- +     11	   +     849600     +
-- +     10	   +     240000     +
-- +      7	   +     226428.57  +
-- +      5	   +     220861.11  +
-- +      6	   +     183631.28  +
-- +      0	   +     121113.95  +
-- +      4	   +     110213.15  +
-- +      8	   +     73781.82   +
-- +      9	   +     68550      +
-- +      3    +     51125      + 
-- +      2	   +     41908.06   +
-- +      1	   +     37941.18   +
-- + --------- + -------------- +

--====================================================================================================
-- 29) AVERAGE BUILDING VALUE BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  ROUND(AVG(BuildingValue), 2) AS Avg_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
AND BuildingValue IS NOT NULL
GROUP BY Bedrooms
ORDER BY Avg_BuildingValue DESC

-- + --------- + -------------- +
-- | BEDROOMS  | Avg_BuildValue |
-- + --------- + -------------- +
-- +     10	   +     1826100    +
-- +     11	   +     1541400    +
-- +      7	   +     716648.57  +
-- +      5	   +     542987.36  +
-- +      6	   +     446956.28  +
-- +      9	   +     316650     +
-- +      4	   +     252281.32  +
-- +      8	   +     184550     +
-- +      0	   +     168446.51  + 
-- +      3	   +     142300.09  +
-- +      2	   +     93257.07   +
-- +      1	   +     62789.22   +
-- + --------- + -------------- +

--====================================================================================================
-- 30) TOTAL AVERAGE VALUE BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  ROUND(AVG(TotalValue), 2) AS Avg_TotalValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
AND TotalValue IS NOT NULL
GROUP BY Bedrooms
ORDER BY Avg_TotalValue DESC

-- + --------- + -------------- +
-- | BEDROOMS  | Avg_TotalValue |
-- + --------- + -------------- +
-- +    11	   +     2467100    +
-- +    10	   +     2115400    +
-- +     7	   +     963400     +
-- +     5	   +     772117.44  +
-- +     6	   +     639408.95  +
-- +     9	   +     392350     +
-- +     4	   +     366658.31  +
-- +     0	   +     295118.6   +
-- +     8	   +     259290.91  +
-- +     3	   +     195329.42  +
-- +     2	   +     136863.95  +
-- +     1	   +     102010.78  +
-- + --------- + -------------- +

--====================================================================================================
-- 31) AVG ACRE VALUE BY BEDROOMS :
--====================================================================================================
SELECT Bedrooms, 
  ROUND(AVG(Acreage), 2) AS Avg_AcreValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE Bedrooms IS NOT NULL
AND Acreage IS NOT NULL
GROUP BY Bedrooms
ORDER BY Avg_AcreValue DESC

-- + --------- + -------------- +
-- | BEDROOMS  |  Avg_AcreValue |
-- + --------- + -------------- +
-- +     11	   +     8.12       +
-- +     0	   +     1.94       +
-- +     7	   +     1.43       +
-- +     10	   +     1.33       +
-- +     5	   +     0.94       + 
-- +     6	   +     0.82       +
-- +     4	   +     0.58       +
-- +     8     +     0.57       +
-- +     3	   +     0.41       +
-- +     9	   +     0.34       +
-- +     2 	   +     0.33       +
-- +     1	   +     0.29       +
-- + --------- + -------------- +

--====================================================================================================
-- 32) NUMBER OF HOUSES BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  COUNT(DISTINCT [UniqueID ]) AS Total_Houses
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
GROUP BY FullBath
ORDER BY Total_Houses DESC

-- + --------- + -------------- +
-- | FULLBATH  |    TotalHouse  |
-- + --------- + -------------- +
-- +    2	   +      9874      +
-- +    1	   +      9359      + 
-- +    3	   +      3446      + 
-- +    4	   +      989       +
-- +    5	   +      329       + 
-- +    0	   +      164       + 
-- +    6	   +      85        + 
-- +    7	   +      16        + 
-- +    8	   +      6         + 
-- +    10	   +      4         +
-- +    9	   +      3         +
-- + --------- + -------------- +

--====================================================================================================
-- 33) HOUSE PRICE BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
GROUP BY FullBath
ORDER BY House_Price DESC

-- + --------- + -------------- +
-- | FULLBATH  |    HousePrice  |
-- + --------- + -------------- +
-- +     2	   +    2402807544  +
-- +     1	   +    1561757074  +
-- +     3	   +    1410454258  +
-- +     4	   +    712160168   +
-- +     5	   +    345225089   +
-- +     6	   +    118695601   +
-- +     0	   +    87976750    +
-- +     7	   +    29149856    +
-- +     8	   +    17465000    +
-- +     10	   +    11450000    +
-- +     9	   +    6838500     +
-- + --------- + -------------- +

--====================================================================================================
-- 34) AVERAGE LAND VALUE BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
AND LandValue IS NOT NULL
GROUP BY FullBath
ORDER BY Avg_LandValue DESC

-- + --------- + -------------- +
-- | FULLBATH  | AVG_LandValue  |
-- + --------- + -------------- +
-- +     8	   +     845966.67  +
-- +     7	   +     745106.25  +
-- +     9	   +     638466.67  +
-- +     10	   +     515950     +
-- +     6	   +     409922.35  +
-- +     5	   +     340722.4   +
-- +     4	   +     224402.63  +
-- +     0     + 	 162648.78  +
-- +     3	   +     114470.92  +
-- +     2	   +     54499.24   +
-- +     1	   +     36014.25   +
-- + --------- + -------------- +

--====================================================================================================
-- 35) AVERAGE BUILDING VALUE BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  AVG(BuildingValue) AS Avg_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
AND BuildingValue IS NOT NULL
GROUP BY FullBath
ORDER BY Avg_BuildingValue DESC

-- + --------- + -------------- +
-- | FULLBATH  | AVG_TotalValue |
-- + --------- + -------------- +
-- +    10	   +    3003200     +
-- +    8	   +    2699633.33  + 
-- +    7	   +    2089193.75  +
-- +    9	   +    1852266.67  +
-- +    6	   +    1410487.94  +
-- +    5	   +    1191516.63  +
-- +    4	   +    725314.76   +
-- +    3	   +    381252.98   +
-- +    0	   +    323689.02   +
-- +    2	   +    207995.21   + 
-- +    1	   +    129958.73   +
-- + --------- + -------------- +

--====================================================================================================
-- 36) TOTAL AVERAGE VALUE BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  ROUND(AVG(TotalValue), 2) AS Avg_TotalValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
AND TotalValue IS NOT NULL
GROUP BY FullBath
ORDER BY Avg_TotalValue DESC

-- + --------- + -------------- +
-- | FULLBATH  | AVG_TotalValue |
-- + --------- + -------------- +
-- +    10	   +    3003200     +
-- +    8	   +    2699633.33  + 
-- +    7	   +    2089193.75  +
-- +    9	   +    1852266.67  +
-- +    6	   +    1410487.94  +
-- +    5	   +    1191516.63  +
-- +    4	   +    725314.76   +
-- +    3	   +    381252.98   +
-- +    0	   +    323689.02   +
-- +    2	   +    207995.21   + 
-- +    1	   +    129958.73   +
-- + --------- + -------------- +

--====================================================================================================
-- 37) AVG ACRE VALUE BY FULL BATHROOMS :
--====================================================================================================
SELECT FullBath, 
  ROUND(AVG(Acreage), 2) AS Avg_AcreValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE FullBath IS NOT NULL
AND Acreage IS NOT NULL
GROUP BY FullBath
ORDER BY Avg_AcreValue DESC

-- + --------- + -------------- +
-- | FULLBATH  | AVG_AcreValue  |
-- + --------- + -------------- +
-- +     9     +	4.26	    +
-- +     8     +	2.67		+
-- +     10    +    2.16		+
-- +     0     +	1.98		+
-- +     7     +	1.97		+
-- +     6     +	1.62		+
-- +     5     +	1.52		+
-- +     4     +	0.89		+
-- +     3     +	0.62		+
-- +     2     +	0.38		+
-- +     1     +	0.36		+
-- + --------- + -------------- +

--====================================================================================================
-- 38) NUMBER OF HOUSES BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  COUNT(DISTINCT [UniqueID ]) AS Total_Houses
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
GROUP BY HalfBath
ORDER BY Total_Houses DESC

-- + --------- + -------------- +
-- | HALFBATH  |  Total_Houses  |
-- + --------- + -------------- +
-- +     3     +	17683	    +
-- +     2     +	6092        +
-- +     1     +    344         +
-- +     0     +	25          +
-- + --------- + -------------- +

--====================================================================================================
-- 39) HOUSE PRICE BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  SUM(SalePrice) AS House_Price
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
GROUP BY HalfBath
ORDER BY House_Price DESC

-- + --------- + -------------- +
-- | HALFBATH  |   HousePrice   |
-- + --------- + -------------- +
-- +     3     +	4284854935  +
-- +     2     +	2036666529  +
-- +     1     +    309177768   +
-- +     0     +	42492000    +
-- + --------- + -------------- +

--====================================================================================================
-- 40) AVERAGE LAND VALUE BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  ROUND(AVG(LandValue), 2) AS Avg_LandValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
AND LandValue IS NOT NULL
GROUP BY HalfBath
ORDER BY Avg_LandValue DESC

-- + --------- + ------------- +
-- | HALFBATH  | AVG_LandValue |
-- + --------- + ------------- +
-- +     3     +   371836	   +
-- +     2     +   249535.47   +
-- +     1     +   81705.45    +
-- +     0     +   61495.41    +
-- + --------- + ------------- +

--====================================================================================================
-- 41) AVERAGE BUILDING VALUE BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  ROUND(AVG(BuildingValue), 2) AS Avg_BuildingValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
AND BuildingValue IS NOT NULL
GROUP BY HalfBath
ORDER BY Avg_BuildingValue DESC

-- + --------- + ----------------- +
-- | HALFBATH  | AVG_BuildingValue |
-- + --------- + ----------------- +
-- +     3     +	1322324        +
-- +     2     +	734316.79      +
-- +     1     +    235416.64      +
-- +     0     +	137793.4       +
-- + --------- + ----------------- +

--====================================================================================================
-- 42) TOTAL AVERAGE VALUE BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  ROUND(AVG(TotalValue), 2) AS Avg_TotalValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
AND TotalValue IS NOT NULL
GROUP BY HalfBath
ORDER BY Avg_TotalValue DESC

-- + --------- + -------------- +
-- | HALFBATH  | AVG_TotalValue |
-- + --------- + -------------- +
-- +     3     +	1719024	    +
-- +     2     +	992863.88   +
-- +     1     +    320609.06   +
-- +     0     +	201530.53   +
-- + --------- + -------------- +

--====================================================================================================
-- 43) AVG ACRE VALUE BY HALF BATHROOMS :
--====================================================================================================
SELECT HalfBath, 
  ROUND(AVG(Acreage), 2) AS Avg_AcreValue
FROM [Portfolio_Projects].[dbo].[Nashville_Housing]
WHERE HalfBath IS NOT NULL
AND Acreage IS NOT NULL
GROUP BY HalfBath
ORDER BY Avg_AcreValue DESC

-- + --------- + ------------- +
-- | HALF BATH | AVG_ACREVALUE |
-- + --------- + ------------- +
-- +	3	   +	  1.7      +
-- +    2      +      1.03     +
-- +    1      +      0.46     +
-- +    0      +      0.45     +
-- + --------- + ------------- +

--====================================================================================================
-----------------------------------------------END----------------------------------------------------
--====================================================================================================
