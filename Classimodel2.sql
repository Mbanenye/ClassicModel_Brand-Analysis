-- Data exploration, these queries explore the data contained the seven tables contained in the company's schema.

--  Show all the data
SELECT * 
FROM customers;
-- Show customers from USA or Norway

SELECT contactLastName, phone, city , country
FROM customers
WHERE country = 'USA'
OR country = 'Norway';

-- Show all columns for customers from the USA  or Uk with surname Brown

SELECT * 
FROM customers
WHERE (country = 'USA' 
OR country = 'UK')
and contactLastname = 'Brown';

-- Show all columns for customers who are from New York, London or Mumbai. 

SELECT * 
FROM customers
WHERE city IN ( 'NYC', 'London', 'Mumbai');

-- group the customers into different creditlimit ranges.
SELECT 
case when creditLimit < 75000 then 'a: Less than $75k'
when creditLimit between 75000 and 100000 then 'b: $75k -
$100k'
when creditLimit between 100000 and 150000 then 'c: $100k
- $150k'
when creditLimit > 150000 then 'd: Over $150k'
else 'Other' end as credit_limit_grp,

count(distinct c.customernumber) as customers
from classicmodels.customers c
group by credit_limit_grp;

-- Show all the data in the employees table.

SELECT * 
FROM employees;

-- For employees who are sales reps, display their email. This is from the employees table.

SELECT email
FROM employees
WHERE jobTitle = 'Sales Rep';

-- show data for employees with listed employee number.

SELECT * 
FROM employees
WHERE employeeNumber IN (
1102,1143,1216,1370);

-- Show data in orders table. 

SELECT *
FROM ORDERS;

-- Show the sum of all orders on each day.

SELECT *
FROM orders
WHERE status ='Shipped';

-- Joining the orders table to the customer table

SELECT * 
FROM customers cust
JOIN orders ord
ON cust.customerNumber = ord.customerNumber;

-- Show the customer first name, lastname, orderdate and status for each order in the orders table with a matching customer in the customer table.

SELECT cust.contactFirstName, cust.contactLastName, ord.orderDate, ord.status
FROM customers cust
JOIN orders ord
ON cust.customerNumber = ord.customerNumber;

-- Display the first name and last name of all customers, and the order date and ordernumber of all their orders, even if the customer made no orders. 

SELECT cust.contactFirstName, cust.contactLastName, ord.orderDate, ord.orderNumber
FROM customers cust
LEFT JOIN orders ord
ON cust.customerNumber = ord.customerNumber;

-- Show the data from the payment table.

SELECT *
FROM  payments;

-- Show the total amount of payment made each day.
SELECT paymentDate, ROUND(SUM(amount),1) as TotalAmount
FROM payments
GROUP BY 1
ORDER BY 1;

-- Show the date when more than 40 Motorcycles were ordered.

with main_cte as
(
select
t1.ordernumber,
orderdate,
quantityordered,
productname,
productline,
case when quantityordered > 40 and productline = 'Motorcycles' then 1
else 0 end as ordered_over_40_motorcycles
from classicmodels.orders t1
join classicmodels.orderdetails t2 on t1.ordernumber = t2.ordernumber
join classicmodels.products t3 on t2.productcode = t3.productcode
)
select orderdate, sum(ordered_over_40_motorcycles) as over_40_bike_sale
from main_cte
group by orderdate;

-- Display the orderdate, ordernumber, salesrepemployeenumber for each sales reps second order.
 WITH CTE_MAIN AS 
 (SELECT ord.orderDate, ord.orderNumber, salesRepEmployeeNumber,
ROW_NUMBER() OVER(PARTITION BY salesRepEmployeeNumber ORDER BY orderdate) as salesRepordernum
FROM orders ord
JOIN customers cust
ON ord.customerNumber = cust.customerNumber)
SELECT * FROM CTE_MAIN
where salesRepordernum = 2;

-- Show the overview of sales by product for the year 2004
SELECT ord.orderDate, ord.orderNumber, ordt.quantityOrdered, pd.buyprice, priceeach,
ordt.quantityOrdered * pd.buyprice AS Cost,
ordt.quantityOrdered * priceeach AS Sales,
(priceeach - pd.buyprice ) * quantityOrdered  AS Profit
FROM orders ord
JOIN customers cust
ON ord.customerNumber = cust. customerNumber
JOIN orderdetails ordt
ON ord.orderNumber = ordt.orderNumber
JOIN products pd
ON ordt.productCode = pd.productCode
JOIN payments pay
ON cust.customerNumber = pay.customerNumber
where year(orderDate) = 2004;

-- Show products purchased together if any and the ones that are rarely purchased together.

WITH prod_sales AS
(
SELECT  ordt.orderNumber, pd.productCode, pd.productLine
FROM orderdetails ordt
JOIN products pd
ON ordt.productCode = pd.productCode
)
SELECT t1.orderNumber, t1.productLine as First_product, t2.productLine as Second_product
FROM prod_sales t1
LEFT JOIN prod_sales t2
ON t1.orderNumber = t2.orderNumber and t1.productLine <> t2. productLine
WHERE  t1.productLine = 'Classic Cars' and t2.productLine = 'Trucks and Buses';



