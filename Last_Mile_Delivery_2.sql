USE last_mile_delivery;

-- SPRINT 2: TABLE CREATION

CREATE TABLE customers (
  customer_id VARCHAR(40) NOT NULL,
  customer_name VARCHAR(120),
  city VARCHAR(40),
  delivery_zone_id VARCHAR(40),
  preferred_time_slot VARCHAR(120),
  customer_type VARCHAR(40),
  account_since DATE,
  PRIMARY KEY (customer_id)
);

CREATE TABLE drivers (
  driver_id VARCHAR(40) NOT NULL,
  driver_name VARCHAR(120),
  hire_date DATE,
  rating DECIMAL(12,2),
  employment_type VARCHAR(40),
  is_active VARCHAR(40),
  PRIMARY KEY (driver_id)
);

CREATE TABLE vehicles (
  vehicle_id VARCHAR(40) NOT NULL,
  vehicle_type VARCHAR(40),
  fuel_type VARCHAR(40),
  max_payload_kg DECIMAL(12,2),
  depot VARCHAR(40),
  last_service_date DATE,
  is_active VARCHAR(40),
  PRIMARY KEY (vehicle_id)
);

CREATE TABLE orders (
  order_id VARCHAR(40) NOT NULL,
  customer_id VARCHAR(40),
  order_date DATE,
  delivery_zone_id VARCHAR(40),
  package_weight_kg DECIMAL(12,2),
  service_type VARCHAR(40),
  priority VARCHAR(40),
  total_value DECIMAL(12,2),
  PRIMARY KEY (order_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE deliveries (
  delivery_id VARCHAR(40),
  order_id VARCHAR(40),
  driver_id VARCHAR(40),
  vehicle_id VARCHAR(40),
  assigned_date DATE,
  actual_delivery_date DATE,
  status VARCHAR(40),
  delivery_attempt INT,
  distance_km DECIMAL(12,2),
  delivery_duration_min INT,
  PRIMARY KEY (delivery_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);


-- Import CSV files into tables in this order: customers, drivers, vehicles, orders, deliveries.
-- Use MySQL Workbench Table Data Import Wizard.

-- SPRINT 2: DATA VERIFICATION

SELECT COUNT(*) FROM customers; -- 400
SELECT COUNT(*) FROM orders; -- 3000
SELECT COUNT(*) FROM deliveries; -- 3500
SELECT COUNT(*) FROM drivers; -- 80
SELECT COUNT(*) FROM vehicles; -- 50


-- SPRINT 3 AND 4: ANALYTICAL QUERIES

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM deliveries;

SELECT DISTINCT service_type FROM orders;

SELECT COUNT(*) FROM drivers WHERE is_active = 'Yes';

SELECT DISTINCT vehicle_type FROM vehicles;

SELECT ROUND(SUM(total_value),2) FROM orders;

SELECT ROUND(AVG(package_weight_kg),2) FROM orders;

SELECT delivery_zone_id, COUNT(*) orders FROM orders GROUP BY delivery_zone_id ORDER BY orders DESC LIMIT 8;

SELECT service_type, COUNT(*) orders, ROUND(SUM(total_value),2) value FROM orders GROUP BY service_type ORDER BY orders DESC;

SELECT priority, COUNT(*) orders FROM orders GROUP BY priority;

SELECT DATE_FORMAT(order_date,'%Y-%m') month, COUNT(*) orders FROM orders GROUP BY month ORDER BY month;

SELECT customer_id, COUNT(*) orders FROM orders GROUP BY customer_id ORDER BY orders DESC LIMIT 8;

SELECT customer_id, ROUND(SUM(total_value),2) total_value FROM orders GROUP BY customer_id ORDER BY total_value DESC LIMIT 8;

SELECT c.customer_type, COUNT(o.order_id) orders, ROUND(SUM(o.total_value),2) value FROM customers c JOIN orders o ON c.customer_id=o.customer_id GROUP BY c.customer_type;

SELECT status, COUNT(*) attempts FROM deliveries GROUP BY status;

SELECT o.delivery_zone_id, COUNT(*) attempts, ROUND(100*AVG(d.status = 'Delivered'),2) delivered_pct FROM orders o JOIN deliveries d ON o.order_id=d.order_id GROUP BY o.delivery_zone_id ORDER BY delivered_pct LIMIT 8;

SELECT status, ROUND(AVG(delivery_duration_min),2) avg_minutes FROM deliveries GROUP BY status;

SELECT driver_id, COUNT(*) deliveries FROM deliveries GROUP BY driver_id ORDER BY deliveries DESC LIMIT 8;

SELECT v.vehicle_type, COUNT(*) delivery_records, ROUND(AVG(d.delivery_duration_min),2) avg_minutes FROM deliveries d JOIN vehicles v ON d.vehicle_id=v.vehicle_id GROUP BY v.vehicle_type;

SELECT ROUND(MIN(rating),2), ROUND(AVG(rating),2), ROUND(MAX(rating),2) FROM drivers;

SELECT order_id, COUNT(*) records FROM deliveries GROUP BY order_id HAVING COUNT(*) > 1;

SELECT delivery_attempt, COUNT(*) records FROM deliveries GROUP BY delivery_attempt;

SELECT o.delivery_zone_id, COUNT(*) records, ROUND(100*AVG(d.status <> 'Delivered'),2) non_delivered_pct FROM orders o JOIN deliveries d ON o.order_id=d.order_id GROUP BY o.delivery_zone_id ORDER BY non_delivered_pct DESC LIMIT 8;




ALTER TABLE customers
MODIFY customer_id VARCHAR(20) NOT NULL;

ALTER TABLE orders
MODIFY order_id VARCHAR(20) NOT NULL,
MODIFY customer_id VARCHAR(20);

ALTER TABLE deliveries
MODIFY delivery_id VARCHAR(20) NOT NULL,
MODIFY order_id VARCHAR(20),
MODIFY driver_id VARCHAR(20),
MODIFY vehicle_id VARCHAR(20);

ALTER TABLE drivers
MODIFY driver_id VARCHAR(20) NOT NULL;

ALTER TABLE vehicles
MODIFY vehicle_id VARCHAR(20) NOT NULL;

SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM deliveries;
SHOW INDEX FROM drivers;
SHOW INDEX FROM vehicles;




ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

ALTER TABLE deliveries
ADD PRIMARY KEY (delivery_id);

ALTER TABLE drivers
ADD PRIMARY KEY (driver_id);

ALTER TABLE vehicles
ADD PRIMARY KEY (vehicle_id);




ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_deliveries_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_deliveries_drivers
FOREIGN KEY (driver_id)
REFERENCES drivers(driver_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_deliveries_vehicles
FOREIGN KEY (vehicle_id)
REFERENCES vehicles(vehicle_id);



SELECT
    table_name,
    column_name,
    referenced_table_name
FROM information_schema.key_column_usage
WHERE table_schema = 'last_mile_delivery'
AND referenced_table_name IS NOT NULL;