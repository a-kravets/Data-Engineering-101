--STAFF AKA PEOPLE

--creating a table
drop table if exists staff_dim ;
CREATE TABLE "staff_dim"
(
 "staff_id" serial NOT NULL,
 "person"   varchar(17) NOT NULL,
 "region"   varchar(17) NOT NULL,
 CONSTRAINT "PK_people" PRIMARY KEY ( "staff_id" )
);

--deleting rows
truncate table staff_dim;

--generating ship_id and inserting ship_mode from orders
insert into staff_dim 
select 100+row_number() over(), person, region from (select distinct person, region from people ) a
--checking
select * from staff_dim sd 





--RETURNS

--creating a table
drop table if exists returns_dim ;
CREATE TABLE "returns_dim"
(
 "order_id"   varchar(25) NOT NULL,
 "returned" varchar(3) NOT NULL,
 CONSTRAINT "PK_returns" PRIMARY KEY ( "order_id" )
);

--deleting rows
truncate table returns_dim;

--generating ship_id and inserting ship_mode from orders
insert into returns_dim 
select order_id, returned from (select distinct order_id, returned from returns ) a
--checking
select * from returns_dim r



--SHIPPING

--creating a table
drop table if exists shipping_dim ;
CREATE TABLE "shipping_dim"
(
 "ship_id"       serial NOT NULL,
 "shipping_mode" varchar(14) NOT NULL,
 CONSTRAINT "PK_shipping_dim" PRIMARY KEY ( "ship_id" )
);

--deleting rows
truncate table shipping_dim;

--generating ship_id and inserting ship_mode from orders
insert into shipping_dim 
select 100+row_number() over(), ship_mode from (select distinct ship_mode from orders ) a
--checking
select * from shipping_dim sd 




--CUSTOMER

--creating a table
drop table if exists customer_dim ;
CREATE TABLE "customer_dim"
(
 "customer_id"   varchar(8) NOT NULL,
 "customer_name" varchar(22) NOT NULL,
 CONSTRAINT "PK_customer_dim" PRIMARY KEY ( "customer_id" )
);

--deleting rows
truncate table customer_dim;
--inserting
insert into customer_dim 
select customer_id, customer_name from (select distinct customer_id, customer_name from orders ) a
--checking
select * from customer_dim cd  




--GEOGRAPHY

--creating a table
drop table if exists geo_dim ;
CREATE TABLE "geo_dim"
(
 "geo_id"      serial NOT NULL,
 "country"     varchar(13) NOT NULL,
 "city"        varchar(17) NOT NULL,
 "state"       varchar(20) NOT NULL,
 "postal_code" int4 NULL,
 CONSTRAINT "PK_geo_dim" PRIMARY KEY ( "geo_id" )
);

--deleting rows
truncate table geo_dim ;
--generating geo_id and inserting rows from orders
insert into geo_dim 
select 100+row_number() over(), country, city, state, postal_code from (select distinct country, city, state, postal_code from orders ) a
--checking
select * from geo_dim gd 




--PRODUCT

--creating a table
drop table if exists product_dim ;
CREATE TABLE "product_dim"
(
 "product_id"   serial NOT NULL,
 "product_name" varchar(127) NOT NULL,
 "category"     varchar(15) NOT NULL,
 "sub_category" varchar(11) NOT NULL,
 "segment"      varchar(11) NOT NULL,
 CONSTRAINT "PK_product_dim" PRIMARY KEY ( "product_id" )
);

--deleting rows
truncate table product_dim ;
--
insert into product_dim 
select 100+row_number() over(), product_name, category, subcategory, segment from (select distinct product_id, product_name, category, subcategory, segment from orders ) a
--checking
select * from product_dim cd  



--CALENDAR

--creating a table
drop table if exists calendar_dim ;
CREATE TABLE "calendar_dim"
(
 "calendar_id" serial NOT NULL,
 "year"        date NOT NULL,
 "quarter"     date NOT NULL,
 "month"       date NOT NULL,
 "week"        date NOT NULL,
 "week_day"    date NOT NULL,
 "order_date"  date NOT NULL,
 "ship_date"   date NOT NULL,
 CONSTRAINT "PK_calendar_dim" PRIMARY KEY ( "calendar_id" )
);

--deleting rows
truncate table calendar_dim ;
--
insert into calendar_dim 
select
	100+row_number() over()
	,order_date
	,ship_date
	,date_trunc('year',order_date)::date
	,date_trunc('quarter',order_date)::date
	,date_trunc('month',order_date)::date
	,date_trunc('week',order_date)::date
	,date_trunc('day',order_date)::date
from (select distinct order_date, ship_date from orders) a
--checking
select * from calendar_dim 





--METRICS

--creating a table
drop table if exists metrics_fact ;
CREATE TABLE "metrics_fact"
(
 "row_id"      serial NOT NULL,
 "sales"       numeric(9,4) NOT NULL,
 "profit"      numeric(21,16) NOT NULL,
 "customer_id" varchar(8) NOT NULL,
 "product_id"  integer NOT NULL,
 "quantity"    int4 NOT NULL,
 "discount"    numeric(4,2) NOT NULL,
 "ship_id"     integer NOT NULL,
 "geo_id"      integer NOT NULL,
 "calendar_id" integer NOT NULL,
 "staff_id"    integer NOT NULL,
 "order_id"    varchar(25) NOT NULL,
 CONSTRAINT "PK_sales_fact" PRIMARY KEY ( "row_id" ),
 --CONSTRAINT "FK_107" FOREIGN KEY ( "order_id" ) REFERENCES "returns_dim" ( "order_id" ),
 CONSTRAINT "FK_30" FOREIGN KEY ( "customer_id" ) REFERENCES "customer_dim" ( "customer_id" ),
 CONSTRAINT "FK_43" FOREIGN KEY ( "product_id" ) REFERENCES "product_dim" ( "product_id" ),
 CONSTRAINT "FK_50" FOREIGN KEY ( "ship_id" ) REFERENCES "shipping_dim" ( "ship_id" ),
 CONSTRAINT "FK_60" FOREIGN KEY ( "geo_id" ) REFERENCES "geo_dim" ( "geo_id" ),
 CONSTRAINT "FK_84" FOREIGN KEY ( "calendar_id" ) REFERENCES "calendar_dim" ( "calendar_id" ),
 CONSTRAINT "FK_92" FOREIGN KEY ( "staff_id" ) REFERENCES "staff_dim" ( "staff_id" )
);

CREATE INDEX "fkIdx_107" ON "metrics_fact"
(
 "order_id"
);

CREATE INDEX "fkIdx_30" ON "metrics_fact"
(
 "customer_id"
);

CREATE INDEX "fkIdx_43" ON "metrics_fact"
(
 "product_id"
);

CREATE INDEX "fkIdx_50" ON "metrics_fact"
(
 "ship_id"
);

CREATE INDEX "fkIdx_60" ON "metrics_fact"
(
 "geo_id"
);

CREATE INDEX "fkIdx_84" ON "metrics_fact"
(
 "calendar_id"
);

CREATE INDEX "fkIdx_92" ON "metrics_fact"
(
 "staff_id"
);


--deleting rows
truncate table metrics_fact ;
--Preparing orders tably by adding missing columns
insert into metrics_fact 
select
	 100+row_number() over()
	 ,sales
	 ,profit
	 ,customer_id
	 ,p.product_id
	 ,quantity
	 ,discount
	 ,ship_id
	 ,geo_id
	 ,calendar_id
	 ,staff_id
	 ,o.order_id
from orders o 
inner join shipping_dim s on o.ship_mode = s.shipping_mode
inner join calendar_dim c on o.order_date = c.order_date
inner join geo_dim g on o.postal_code = g.postal_code
inner join product_dim p on o.product_name = p.product_name
inner join staff_dim sd on o.region = sd.region;

select * from metrics_fact mf 

select * from returns_dim rd 
where order_id = 'US-2018-116400'


--checking
select
	distinct cd.customer_name
	,order_date
	,sales
from
	customer_dim cd 
left join metrics_fact mf on mf.customer_id = cd.customer_id 
left join calendar_dim c on c.calendar_id = mf.calendar_id
left join product_dim p on p.product_id = mf.product_id
left join shipping_dim s on mf.ship_id = s.ship_id 
left join staff_dim sd on sd.staff_id = mf.staff_id 
left join returns_dim rd on rd.order_id = mf.order_id 
where mf.geo_id in (select geo_id from geo_dim gd where state = 'California')
	and p.category = 'Technology'
	and shipping_mode = 'First Class'
	and region = 'West'
	and returned = 'Yes'







