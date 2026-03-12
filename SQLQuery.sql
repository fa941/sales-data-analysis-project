SELECT DISTINCT Customer_Key
FROM Fact_Sales
WHERE Customer_Key NOT IN (
    SELECT CustomerID FROM Dim_Customer
);
DELETE FROM Fact_Sales
WHERE Customer_Key NOT IN (
    SELECT CustomerID FROM Dim_Customer
);
-----------------------------------------------

--->Total_Sales Before & After Tax
select format(sum(fs.Total_Excluding_Tax),'N0')as totalsales_before_addedtax,
       format(sum(fs.Total_Including_Tax),'N0')as totalsales_after_addedtax 
  from Fact_Sales fs
--->Total Sales & Quantity by Package
select fs.Package,
       format(sum(fs.Total_Including_Tax),'N0')as total_sales ,
       format(sum(fs.Quantity),'N0')as total_quantity 
  from Fact_Sales fs
    group by fs.Package 
--->Total Sales & num.customer & num.orders by Location.customer
select top(10)
       dc.Location as Customer_Location,
       count(fs.Delivery_Date_Key) as num_orders,
       count(DISTINCT(dc.CustomerID)) as num_customer,
       format(sum(fs.Total_Including_Tax),'N0')as total_sales
  from Fact_Sales fs
    inner join Dim_Customer dc
      on fs.Customer_Key = dc.CustomerID
  group by dc.Location
  order by sum(fs.Total_Including_Tax) DESC
---> Year-Over-Year Performance Analysis
select dd.Calendar_Year,
       format(sum(fs.Total_Including_Tax),'N0') as total_sales ,
       sum(fs.Total_Including_Tax) - lag(sum(fs.Total_Including_Tax))
         over (order by dd.Calendar_Year) as Sales_Difference
  from Fact_Sales fs
    inner join Dim_Date dd
      on dd.Date = fs.Invoice_Date_Key
  Group by dd.Calendar_Year 
  order by dd.Calendar_Year
 --->Total Sales & num.customer BY State_Province 
select dc.State_Province ,
       count(DISTINCT(fs.Customer_Key)) as num_Customer,
       format(sum(fs.Total_Including_Tax),'N0') as total_sales
  from Fact_Sales fs 
inner join Dim_City dc 
 on fs.City_Key=dc.CityID
group by dc.State_Province
order by sum(fs.Total_Including_Tax) DESC
--->Total Sales & num.Employees & Num_Orders BY Employee_Type
select case           
          when de.Is_Salesperson = 1 then 'Salesperson'
          else 'Non-Salesperson'
       end as Employee_Type,
       count(distinct(de.Employee_ID))as num_Employee,
       count(fs.Invoice_Date_Key) as Num_Orders,
       format(sum(fs.Total_Including_Tax),'N0') as Total_Sales
from Dim_Employee de
   left join Fact_Sales fs
     on fs.Salesperson_Key = de.WWI_Employee_ID
group by de.Is_Salesperson
order by sum(fs.Total_Including_Tax) DESC

