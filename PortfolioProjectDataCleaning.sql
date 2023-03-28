/* This part of the code is to enable the local data loading mysql  Ver 8.0.32-0ubuntu0.22.04.2 for Linux on x86_64 ((Ubuntu))*/

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = true;

/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Creating Table after manipulation in EXCEL

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/

CREATE Table HousingData
(UniqueID int ,
ParcelID varchar(100) ,
LandUse varchar(100) ,
PropertyAddress varchar(255) ,
SaleDate varchar(100) ,
SalePrice float ,
LegalReference varchar(255) ,
SoldAsVacant varchar(50) ,
OwnerName varchar(255) ,
OwnerAddress varchar(255) ,
Acreage float ,
TaxDistrict varchar(255) ,
LandValue int ,
BuildingValue int ,
TotalValue int ,
YearBuilt int ,
Bedrooms int ,
FullBath int ,
HalfBath int 
);

/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Uploading data from CSV file

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/
LOAD DATA LOCAL INFILE '/home/gyahia/Desktop/BootCamp/HousingData.csv'
INTO TABLE HousingData
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@UniqueID,	@ParcelID,	@LandUse,	@PropertyAddress,	@SaleDate,	@SalePrice,	@LegalReference,	@SoldAsVacant,	@OwnerName,	@OwnerAddress,	@Acreage,	@TaxDistrict,	@LandValue,	@BuildingValue,	@TotalValue,	@YearBuilt,	@Bedrooms,	@FullBath,	@HalfBath)
SET
UniqueID=NULLIF(@UniqueID,''),
ParcelID=NULLIF(@ParcelID,''),
LandUse=NULLIF(@LandUse,''),
PropertyAddress=NULLIF(@PropertyAddress,''),
SaleDate=NULLIF(@SaleDate,''),
SalePrice=NULLIF(@SalePrice,''),
LegalReference=NULLIF(@LegalReference,''),
SoldAsVacant=NULLIF(@SoldAsVacant,''),
OwnerName=NULLIF(@OwnerName,''),
OwnerAddress=NULLIF(@OwnerAddress,''),
Acreage=NULLIF(@Acreage,''),
TaxDistrict=NULLIF(@TaxDistrict,''),
LandValue=NULLIF(@LandValue,''),
BuildingValue=NULLIF(@BuildingValue,''),
TotalValue=NULLIF(@TotalValue,''),
YearBuilt=NULLIF(@YearBuilt,''),
Bedrooms=NULLIF(@Bedrooms,''),
FullBath=NULLIF(@FullBath,''),
HalfBath=NULLIF(@HalfBath,'');

SELECT * FROM  `HousingData`;

/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Standardize date FORMAT to (Y/m/d) an UPDATE it in the table

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/

SELECT SaleDate, STR_TO_DATE(`SaleDate`,'%M %e, %Y')
FROM `HousingData`;

UPDATE `HousingData`
SET
    `SaleDate`=STR_TO_DATE(`SaleDate`,'%M %e, %Y');

SELECT SaleDate FROM `HousingData`;

/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

PopulateProperty Address Data

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/

SELECT UniqueID, PropertyAddress 
FROM `HousingData`;

SELECT COUNT(`UniqueID`)
FROM `HousingData`
WHERE `PropertyAddress`IS NULL;
SELECT uniqueid,propertyaddress ,COUNT(`UniqueID`) OVER (PARTITION BY `PropertyAddress`)
FROM `HousingData`
WHERE `PropertyAddress` IS NULL
GROUP BY `UniqueID`,`PropertyAddress`;

SELECT * 
FROM `HousingData`
WHERE `PropertyAddress` IS NULL;

SELECT * 
FROM `HousingData`
WHERE `PropertyAddress` IS NOT NULL;

SELECT COUNT(UniqueID)
FROM `HousingData`
WHERE `PropertyAddress` IS NOT NULL;

SELECT *
FROM `HousingData`
WHERE `PropertyAddress` IS NULL
ORDER BY `ParcelID`;

SELECT one.`UniqueID`,one.`ParcelID`,one.`PropertyAddress`,two.`UniqueID`,two.`ParcelID`,two.`PropertyAddress`
FROM `HousingData` AS one
JOIN HousingData  AS two
    ON one.`ParcelID`=two.`ParcelID`;
  --  AND one.`UniqueID`<> two.UniqueID;

SELECT one.`UniqueID`,one.`ParcelID`,one.`PropertyAddress`,two.`UniqueID`,two.`ParcelID`,two.`PropertyAddress`
FROM `HousingData` AS one
JOIN HousingData  AS two
    ON one.`ParcelID`=two.`ParcelID`
    AND one.`UniqueID`<> two.UniqueID;

SELECT one.`UniqueID`,one.`ParcelID`,one.`PropertyAddress`,two.`UniqueID`,two.`ParcelID`,two.`PropertyAddress`
FROM `HousingData` AS one
JOIN HousingData  AS two
    ON one.`ParcelID`=two.`ParcelID`
    AND one.`UniqueID`<> two.UniqueID
WHERE one.`PropertyAddress` IS NULL;

SELECT one.`UniqueID`,one.`ParcelID`,one.`PropertyAddress`,two.`UniqueID`,two.`ParcelID`,two.`PropertyAddress`, IFNULL(one.`PropertyAddress`,two.`PropertyAddress`)
FROM `HousingData` AS one
JOIN HousingData  AS two
    ON one.`ParcelID`=two.`ParcelID`
    AND one.`UniqueID`<> two.UniqueID
WHERE one.`PropertyAddress` IS NULL;

Update `HousingData` AS a
JOIN `HousingData` AS b
    ON a.`ParcelID`=b.`ParcelID`
    AND a.`UniqueID` <> b.`UniqueID`
SET
    a.PropertyAddress =IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.`PropertyAddress` IS NULL;



/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Breaking Address in : Address, Ciy, State

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/


SELECT SUBSTRING(`PropertyAddress`,1,POSITION("," IN `PropertyAddress`)-1) AS StreetAddress,SUBSTRING(`PropertyAddress`,POSITION("," IN `PropertyAddress`)+1) AS City
FROM `HousingData`;


ALTER TABLE `HousingData`
Add PropertyStreetAddress varchar(255),ADD PropertyCity VARCHAR(100);

UPDATE `HousingData`
SET
    `PropertyStreetAddress`= SUBSTRING(`PropertyAddress`,1,POSITION("," IN `PropertyAddress`)-1),
    `PropertyCity`=SUBSTRING(`PropertyAddress`,POSITION("," IN `PropertyAddress`)+1);


SELECT UniqueID, PropertyAddress,PropertyCity,PropertyStreetAddress, `OwnerAddress`
FROM `HousingData`;

SELECT
PARSER(OwnerAddress,1)
FROM `HousingData`;

-- CHECKING what SUBSTRING_INDEX does depending on variables
SELECT `OwnerAddress`,SUBSTRING_INDEX(`OwnerAddress`,",",1),SUBSTRING_INDEX(`OwnerAddress`,",",2),SUBSTRING_INDEX(`OwnerAddress`,",",-2),SUBSTRING_INDEX(`OwnerAddress`,",",-1)
FROM `HousingData`;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(`OwnerAddress`,",",-2),",",-1)
FROM `HousingData`;

Alter TABLE `HousingData`
ADD OwnerState varchar(50),
ADD OwnerStreet VARCHAR(255),
Add OwnerCity VARCHAR(255);

Update `HousingData`
SET
    `OwnerState`=SUBSTRING_INDEX(`OwnerAddress`,",",-1),
    `OwnerStreet`=SUBSTRING_INDEX(`OwnerAddress`,",",1),
    `OwnerCity`=SUBSTRING_INDEX(SUBSTRING_INDEX(`OwnerAddress`,",",-2),",",-1);

SELECT * FROM `HousingData` LIMIT 100;

/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Standardize yes/No content for SoldAsVacant Column

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/

SELECT DISTINCT(`SoldAsVacant`),COUNT(`SoldAsVacant`)
From `HousingData`
GROUP BY `SoldAsVacant`;

--Simpler to change Y and N to Yes and NO

SELECT `SoldAsVacant`,
    CASE 
        WHEN `SoldAsVacant`="N" THEN "No"  
        WHEN  `SoldAsVacant`="Y" THEN "Yes"
        ELSE `SoldAsVacant`
    END
FROM `HousingData`;

UPDATE `HousingData`
SET 
    `SoldAsVacant` = (CASE 
        WHEN `SoldAsVacant`="N" THEN "No"  
        WHEN  `SoldAsVacant`="Y" THEN "Yes"
        ELSE `SoldAsVacant`
    END);


/*-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

Remove Dupicates

---------------------------------------------------------------------------------
-------------------------------------------------------------------------------*/

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY `ParcelID`,
                      `PropertyAddress`,
                      `SalePrice`,
                      `SaleDate`,
                      `LegalReference`
                      ORDER BY `UniqueID`) row_num
FROM `HousingData`
ORDER BY `ParcelID`;

WITH RowNumCTE AS(
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY `ParcelID`,
                      `PropertyAddress`,
                      `SalePrice`,
                      `SaleDate`,
                      `LegalReference`
                      ORDER BY `UniqueID`) row_num
FROM `HousingData`
ORDER BY `ParcelID`)
SELECT * 
FROM RowNumCTE
WHERE row_num >1
ORDER BY `ParcelID`;

   

DROP TABLE IF EXISTS DuplicateData;
CREATE TEMPORARY TABLE DuplicateData
(id int,
parcel varchar(255),
address VARCHAR(255),
price int,
date varchar(255),
ref VARCHAR(255),
row_num int);


INSERT INTO DuplicateData
SELECT UniqueID,parcelID,PropertyAddress,SalePrice,SaleDate,LegalReference, ROW_NUMBER () OVER (PARTITION BY `ParcelID`,
                      `PropertyAddress`,
                      `SalePrice`,
                      `SaleDate`,
                      `LegalReference`
                      ) AS row_num
FROM `HousingData`;


SELECT * FROM DuplicateData;
SELECT * FROM DuplicateData
WHERE row_num >1;

SELECT *
FROM `HousingData`
JOIN DuplicateData
    ON`UniqueID`=DuplicateData.id
WHERE DuplicateData.row_num > 1; 

DELETE h
FROM `HousingData` h
JOIN DuplicateData
    ON`UniqueID`=DuplicateData.id
WHERE DuplicateData.row_num > 1; 

