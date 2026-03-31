-- =================================
-- INSERTING INTO SILVER LAYER
-- =================================   
USE dw_silver;
INSERT INTO dw_silver.crm_cst_info
(
    cst_key,
    cst_id,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_key,
    cst_id,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'Unknown'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flags
    FROM dw_bronze.crm_cst_info
    WHERE cst_id IS NOT NULL
      AND cst_id <> 0
) t
WHERE flags = 1;
SELECT * FROM dw_silver.crm_cst_info;
SELECT COUNT(*) FROM dw_bronze.crm_cst_info;
SELECT COUNT(*) FROM dw_silver.crm_cst_info;

ALTER TABLE dw_silver.crm_prd_info
ADD COLUMN cat_id VARCHAR(50);

INSERT INTO dw_silver.crm_prd_info
(
prd_id,
cat_id,
prd_key,
prd_nm ,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key,
prd_nm,
prd_cost,
CASE WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line))='S' THEN 'Other sales'
	WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
	ELSE 'Unknown'
END AS prd_line,
prd_start_dt,
LEAD(DATE_SUB(prd_start_dt, INTERVAL 1 DAY)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
FROM crm_prd_info;
SELECT * FROM dw_silver.crm_prd_info;
ALTER TABLE dw_silver.crm_prd_info
MODIFY COLUMN cat_id VARCHAR(50) AFTER prd_id;

INSERT INTO dw_silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quntity,
sls_price
)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt =0 OR LENGTH(sls_order_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt =0 OR LENGTH(sls_ship_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt =0 OR LENGTH(sls_due_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
END AS sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!=sls_quantity * ABS(sls_price) 
	 THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0
THEN sls_price= sls_sales/NULLIF(sls_quantity,0)
ELSE sls_price
END AS sls_price
FROM crm_sales_details;

INSERT INTO dw_silver.erp_cust_az12
(cid,
bdate,
gen) 

SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid)) 
     ELSE cid
END AS cid,
CASE WHEN bdate > NOW() THEN NULL
     ELSE bdate
END AS bdate,
  CASE
    WHEN gen IS NULL 
         OR TRIM(REPLACE(REPLACE(gen, '\r',''), '\n','')) = '' 
    THEN 'Unknown'
    WHEN UPPER(TRIM(REPLACE(REPLACE(gen, '\r',''), '\n',''))) IN ('F','FEMALE')
    THEN 'Female'
    WHEN UPPER(TRIM(REPLACE(REPLACE(gen, '\r',''), '\n',''))) IN ('M','MALE')
    THEN 'Male'
    ELSE 'Unknown'
END AS gen
FROM erp_cust_az12;
SELECT * FROM dw_silver.erp_cust_az12;

INSERT INTO dw_silver.erp_loc_a101
(
cid,
cntry
)

SELECT 
REPLACE (cid,'-','') cid,
CASE 
 WHEN cntry IS NULL OR TRIM(REPLACE(REPLACE(cntry,'\r',''),'\n','')) = ''
 THEN 'Unknown'
 WHEN UPPER(TRIM(REPLACE(REPLACE(cntry,'\r',''),'\n',''))) = 'DE'
 THEN 'Germany'
 WHEN UPPER(TRIM(REPLACE(REPLACE(cntry,'\r',''),'\n',''))) IN ('US','USA')
 THEN 'United States'
 ELSE TRIM(REPLACE(REPLACE(cntry,'\r',''),'\n',''))
END AS cntry
FROM erp_loc_a101 ;
SELECT * FROM dw_silver.erp_loc_a101;

INSERT INTO dw_silver.erp_px_cat_g1v2
(
id,
cat,
subcat,
maintenance
)

SELECT
id,
cat,
subcat,
maintenance
FROM erp_px_cat_g1v2;
SELECT * FROM dw_silver.erp_px_cat_g1v2;

