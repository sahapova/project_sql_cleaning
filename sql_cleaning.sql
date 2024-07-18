CREATE TABLE IF NOT EXISTS "Housing_data_cleaning_csv" (
    "UniqueID" INT,
    "ParcelID" TEXT,
    "LandUse" TEXT,
    "PropertyAddress" TEXT,
    "SaleDate" TIMESTAMP,
    "SalePrice" INT,
    "LegalReference" TEXT,
    "SoldAsVacant" TEXT,
    "OwnerName" TEXT,
    "OwnerAddress" TEXT,
    "Acreage" NUMERIC(4, 1),
    "TaxDistrict" TEXT,
    "LandValue" INT,
    "BuildingValue" INT,
    "TotalValue" INT,
    "YearBuilt" INT,
    "Bedrooms" INT,
    "FullBath" INT,
    "HalfBath" INT
);

select *
from public."Housing_data_cleaning_csv"
limit 5;


--DATA CLEANING--

---checking for strange rows
Select distinct 
--"ParcelID" 
--"LandUse"
--"PropertyAddress" --some adress is NULL
--"SaleDate"
-- "SalePrice"
-- "LegalReference"
-- "SoldAsVacant" -- different words
-- "OwnerName"
-- "OwnerAddress"
-- "Acreage"
-- "TaxDistrict"
-- "LandValue"
-- "BuildingValue"
-- "TotalValue"
-- "YearBuilt"
-- "Bedrooms"
-- "FullBath"
-- "HalfBath"
from public."Housing_data_cleaning_csv"

------Date format changing (before "YY-MM-DD 00:00:00">> after "YY-MM-DD")

select "SaleDate"::timestamp::date 
from public."Housing_data_cleaning_csv"; --check 

ALTER TABLE public."Housing_data_cleaning_csv"
ADD COLUMN saledate_formatted date; -- create a column with date type

UPDATE  public."Housing_data_cleaning_csv"
SET  saledate_formatted= "SaleDate"::timestamp::date; -- update column for date format

------Remove dublicates row

Delete from public."Housing_data_cleaning_csv"
where "UniqueID" IN (
    select "UniqueID"
    from (
        select "UniqueID",
               ROW_NUMBER() OVER(PARTITION BY "ParcelID",  "PropertyAddress", "SaleDate", "SalePrice", "TotalValue"
		       ORDER BY "UniqueID") AS group_num
		from public."Housing_data_cleaning_csv"
    ) AS RowNumCTE
    where group_num > 1
);

--checking dublicate
select * 
from (
select *,
	ROW_NUMBER() OVER(PARTITION BY "ParcelID",  "PropertyAddress", "SaleDate", "SalePrice", "TotalValue"
					  ORDER BY "UniqueID") AS group_num
from public."Housing_data_cleaning_csv"
	) as group_dubl
where group_num > 1;

-----Formatiing answers Yes-No

select distinct "SoldAsVacant"
from public."Housing_data_cleaning_csv";

--BEFORE "Yes" "Y" "N" "No" >> after "Yes" "No"

UPDATE public."Housing_data_cleaning_csv"
SET "SoldAsVacant" = 'Yes'
WHERE "SoldAsVacant" = 'Y';

UPDATE public."Housing_data_cleaning_csv"
SET "SoldAsVacant" = 'No'
WHERE "SoldAsVacant" = 'N';

-----Formatting Adress ("PropertyAddress")

ALTER TABLE public."Housing_data_cleaning_csv"
Add column "City" VARCHAR


UPDATE public."Housing_data_cleaning_csv"
SET "City" = TRIM(SPLIT_PART("PropertyAddress", ',', 2))

--check

select distinct "City"
from public."Housing_data_cleaning_csv"

select "PropertyAddress"
from public."Housing_data_cleaning_csv"
where "City" is NULL
--now we know that some rows of "PropertyAddress" is NULL, lets change it
--add new column city

ALTER TABLE public."Housing_data_cleaning_csv"
Add column "City_owner" VARCHAR;

UPDATE public."Housing_data_cleaning_csv"
SET "City_owner" = TRIM(SPLIT_PART("OwnerAddress", ',', 2))

select distinct "City_owner"
from public."Housing_data_cleaning_csv"

--change city to city_owner

update public."Housing_data_cleaning_csv"
SET "City" = "City_owner"
where "City" is NULL

select "PropertyAddress", "City", "City_owner", "OwnerAddress"
from public."Housing_data_cleaning_csv"
where "City" is NULL ---29 rows was changed, other 11 rows totally NULL


