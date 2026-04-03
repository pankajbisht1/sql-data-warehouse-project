
==========================================================================
Gold Layer: You can do analytics and reporting from here
  The data here represent the final dimension and fact tables(star schema)
==========================================================================

CREATE VIEW dw_gold.dim_product AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key ) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM crm_prd_info pn
LEFT JOIN erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id;

SELECT
sl.sls_ord_num AS sales_order,
pr.product_key,
ci.customer_key,
sl.sls_cust_id AS customer_id,
sl.sls_order_dt AS order_date,
sl.sls_ship_dt AS shipping_date,
sl.sls_due_dt AS due_date,
sl.sls_sales AS sales_amount,
sl.sls_quantity,
sl.sls_price AS sales_price
FROM crm_sales_details sl
LEFT JOIN dw_gold.dim_product pr
ON sls_prd_key = pr.product_number
LEFT JOIN dw_gold.dim_customer ci
ON sl.sls_cust_id=ci.customer_id;

