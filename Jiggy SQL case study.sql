-- create table product
create table product(product_id int primary key,
Product_name varchar(200) ,
Category varchar(200),
ProductDescription float ,
SupplierName varchar(200),
SupplierContact varchar(200),
PurchasePrice float
);

--create table customer
create table customer(customer_id int primary key,
CustomerFullName varchar(200),
CustomerPhone float ,
CustomerEmail varchar(200),
CustomerAddress varchar(200),
Country  varchar(200),
City varchar(200),
PostalCode int
);

--create table shipping
create table shiping(shipping_id int primary key,
ShippingCost float,
OrderStatus varchar(200),
ReturnStatus varchar(200),
Rating int,
Feedback varchar(200),
ShippingDate varchar(200),
DeliveryDate varchar(200),
ShipmentTrackingNumber float
);

--create table inventroy
create table inventory(inventory_id int primary key,
Carrier varchar(200),
EstimatedDelivery varchar(200),
ActualDelivery varchar(200),
DeliveryStatus varchar(200),
ProductReturnDate float,
ReturnReason float,
RefundAmount float,
CustomerSupportContac float,
PromotionApplied float,
CouponCode float,
MembershipStatus float,
ReviewComment float ,
ReviewDate float,
FollowUpAction float
);

--create table sales
create table sales(Product_id int,
customer_id int,
shipping_id int,
inventory_id int,
Quantity int,
UnitPrice float,
TotalPrice float,
PaymentType varchar(200),
Profit float,
Discount float,
Tax float,
TaxAmount float,
FinalPrice float,
PaymentStatus varchar(200),
Date date,
foreign key (Product_id) references product(Product_id),
foreign key (customer_id) references customer(customer_id),
foreign key (inventory_id) references inventory(inventory_id),
foreign key (shipping_id) references shiping(shipping_id)
);

-- Window Function:

--Calculate the running total of sales amount for each customer over time
select CustomerFullName,
       Product_id,
	   TotalPrice ,
	   sum(TotalPrice) over(order by CustomerFullName) as toal_sales
from customer c
join sales s
on c.customer_id = s.customer_id 
;
       
--Determine the average order value within a moving window of the last 7 days for each product
select
       Product_id,
       inventory.inventory_id,
	   Date,
	   Carrier,
	   avg(FinalPrice) over(partition by Product_id ) as order_value_average
from inventory
join sales 
on inventory.inventory_id = sales.inventory_id 
order by Date desc
fetch first 7 rows only ;

--Calculate the Percentage of Total Sales for Each Product
select
      Product_id,
	  Quantity,
	  UnitPrice,
	  sum(TotalPrice/100) over(partition by Product_id) as percentage_of_sales
from sales ;	

--Create a stored procedure to update the customer loyalty points based on their purchase history
select
       c.customer_id,
	   CustomerFullName,
       CustomerPhone,
       CustomerEmail,
       CustomerAddress,
	   sum(PurchasePrice) over(partition by c.customer_id) as purchase_history
from customer c
join sales s on c.customer_id = s.customer_id
join product p on s.Product_id = P.product_id;

--Write a function to calculate the discount amount for a given product category
select 
      p.Product_id,
	  product_name,
	  Category,
	  sum(Discount) over(partition by Category) as discount_amount
from product p
join sales s
on p.Product_id = s.Product_id ;

--Develop a function to retrieve the total sales for a specific customer
select 
       c.customer_id,
	   CustomerFullName,
       CustomerPhone,
       CustomerEmail,
       CustomerAddress,
	   sum(TotalPrice) over(partition by CustomerFullName) as total_sales
from customer c
join sales s on c.customer_id = s.customer_id;


--Join:

--Find the total sales amount by joining sales transactions and product details
select 
       p.Product_id,
       Product_name,
       Category,
       ProductDescription,
       SupplierName,
       SupplierContact,
       TotalPrice,
	   PaymentType,
       PaymentStatus
from product p
inner join sales s on p.Product_id = s.Product_id;

--List all customers who have placed orders along with their order details
select
      c.customer_id,
	  CustomerFullName,
      CustomerPhone,
      CustomerEmail,
      CustomerAddress,
	  p.shipping_id,
      i.inventory_id,
      EstimatedDelivery,
      ActualDelivery,
      DeliveryStatus,
      ProductReturnDate
from customer c
inner join sales s on c.customer_id = s.customer_id
inner join shiping p on s.shipping_id = p.shipping_id 
inner join inventory i on s.inventory_id = i.inventory_id;

--Join the sales, customer, and products tables to get detailed sales,customer names and product names
select
       c.CustomerFullName,
	   p.Product_name,
	   p.PurchasePrice,
	   Quantity,
       UnitPrice,
       TotalPrice,
       PaymentType,
       Profit,
       Discount,
       Tax,
       TaxAmount,
       FinalPrice,
       PaymentStatus,
       Date 
from customer c
inner join sales s on c.customer_id = s.customer_id
inner join product p on s.Product_id = p.Product_id;


-- Ranking:

--Rank customers based on their total purchase amount
select
       c.customer_id,
	   c.CustomerFullName,
	   p.PurchasePrice,
	   rank() over(order by p.PurchasePrice desc) as ranked_total_purchase_amount
from customer c
inner join sales s on c.customer_id = s.customer_id
inner join product p on s.Product_id = p.Product_id;

-- Rank products based on their sales quantity
select 
      Product_id,
	  Quantity,
	  rank() over(order by quantity desc) as ranked_quantity
from sales
;


--Rank orders based on their order amount within each customer group
select 
      inventory_id ,
	  customer_id,
	  TotalPrice,
	  rank() over(PARTITION BY customer_id order by TotalPrice desc)
from sales;	  



--Case:

--Classify orders as 'High', 'Medium', or 'Low' value based on the sales amount
select
       shipping_id,
	   TotalPrice,
	   case
	       when TotalPrice <=1000 then 'Low'
		   when TotalPrice >1000 and TotalPrice<=2000 then 'Medium'
		   else 'High'
		end as   classified_sales
from sales;	

--Determine the customer status based on their total purchase amount
select customer.customer_id,
       CustomerFullName,
	   FinalPrice,
	   case
	       when FinalPrice <=800 then 'Low'
		   when FinalPrice >1100 and FinalPrice<=2000 then 'Medium'
		   else 'High'
		end as   classified_purchases
from customer
join sales on customer.customer_id = sales.customer_id ;


--WIth Functions

--Calculate the average sales amount per customer and list customers whose sales are above this average
with temporarytable (averagevalue) as(
     select avg(TotalPrice) from sales
)
		select sales.customer_id from sales ,temporarytable
		where sales.TotalPrice > temporarytable.averagevalue ;


--List the top 5 products by sales amount along with their category names

-- get the highest sale price
select Distinct(FinalPrice) as dis from sales order by dis desc limit 1;

-- solution
select Product_name,Category 
from product
join
(with temporarytable (highestsales) as(
        select Distinct(FinalPrice) as dis from sales order by dis desc limit 1
)
          select Product_id 
		  from sales , temporarytable
		  where sales.FinalPrice >= temporarytable.highestsales ) as top_products
on product.Product_id = top_products.Product_id ;		-- It gives only 3 products


--Find the total number of orders and the total sales amount for each month
select
      to_char(Date ,'Month') as month ,
      count(*) as total_orders,
	  sum(TotalPrice) as total_sales
from sales
group by month;
	  