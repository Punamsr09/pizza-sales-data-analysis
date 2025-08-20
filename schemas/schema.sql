CREATE DATABASE pizzahut_db;

CREATE TABLE orders (
	order_id INT NOT NULL,
	order_date DATE NOT NULL,
	order_time TIME NOT NULL,
	PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
	order_details_id INT NOT NULL,
	order_id INT NOT NULL,
	pizza_id VARCHAR(100) NOT NULL,
	quantity INT NOT NULL,
	PRIMARY KEY (order_details_id)
);

CREATE TABLE pizza_types (
	pizza_types_id VARCHAR(100) NOT NULL,
    name VARCHAR(500) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ingredients TEXT NOT NULL,
    PRIMARY KEY (pizza_types_id) 
);

CREATE TABLE pizzas (
	pizza_id VARCHAR(100) NOT NULL,
    pizza_types_id VARCHAR(100) NOT NULL,
    size VARCHAR(10) NOT NULL,
    price decimal(8,2) NOT NULL,
    PRIMARY KEY (pizza_id)
);
