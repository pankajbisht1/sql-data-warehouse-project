-- ==========================================
-- CREATING THE DATABASE/SCHEMA
-- ==========================================

CREATE DATABASE dw_bronze;
CREATE DATABASE dw_silver;
CREATE DATABASE dw_gold;

-- ===========================================
-- BRONZE LAYER: CREATING TABLES FOR CRM FILES
-- ===========================================

USE dw_bronze;
CREATE TABLE 
cust_info
(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR (50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR (50),
cst_gndr VARCHAR (50),
cst_create_date DATE
);

CREATE TABLE 
crm_prd_info
(
prd_id INT,
prd_key VARCHAR (50),
prd_nm VARCHAR (50),
prd_cost INT,
prd_line VARCHAR (50),
prd_start_dt DATE,
prd_end_dt DATE
);

CREATE TABLE
crm_sales_details
(
sls_ord_num INT,
sls_prd_key VARCHAR (50),
sls_cust_id BIGINT,
sls_order_dt BIGINT,
sls_ship_dt BIGINT,
sls_due_dt BIGINT,
sls_sales INT,
sls_quntity INT,
sls_price INT
);

-- ===========================================
-- BRONZE LAYER: CREATING TABLES FOR ERP FILES
-- ===========================================

CREATE TABLE
erp_cust_az12
(
cid VARCHAR(50),
bdate DATE,
gen VARCHAR (50)
);

CREATE TABLE
erp_loc_a101
(
cid VARCHAR (50),
cntry VARCHAR (50)
);

CREATE TABLE
erp_px_cat_g1v2
(
id VARCHAR (50),
cat VARCHAR (50),
subcat VARCHAR (50),
maintenance VARCHAR (50)
);

-- ==========================
-- BRONZE LAYER: DATA LOADING
-- ==========================

-- Load customer data from CRM source

	TRUNCATE TABLE crm_cst_info;
	SET GLOBAL local_infile = 1;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
	INTO TABLE crm_cst_info
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;



	TRUNCATE TABLE crm_prd_info;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
	INTO TABLE crm_prd_info
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


	TRUNCATE TABLE crm_sales_details;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
	INTO TABLE crm_sales_details
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;

-- ==============================
-- BRONZE LAYER: ERP DATA LOADING
-- =============================

-- Load customer data from ERP

	TRUNCATE TABLE erp_cust_az12;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
	INTO TABLE erp_cust_az12
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


	TRUNCATE TABLE erp_loc_a101;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
	INTO TABLE erp_loc_a101
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


	TRUNCATE TABLE erp_px_cat_g1v2;
	LOAD DATA LOCAL INFILE '/Users/pankajbisht/Downloads/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
	INTO TABLE erp_px_cat_g1v2
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
