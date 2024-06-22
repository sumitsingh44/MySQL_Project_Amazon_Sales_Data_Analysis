--#SQL CAPSTONE PROJECT--#

--#First see the available data--# 
SELECT * FROM amazon_sales;

--#Lets count the number of rows--#
SELECT COUNT(*) FROM amazon_sales;   --# There are 1000 Rows in dataset --#

--#Lets check the datatype and null values of all the columns--#
DESCRIBE amazon_sales;  --# By this we observed that some columns have diff datatypes so we need to change that and there is no null values --#

--#To disable the safe mode in SQL--#
SET SQL_SAFE_UPDATES = 0;

--#Update date_ column to the correct date format--#
UPDATE amazon_sales
SET date_ = STR_TO_DATE(date_, '%m/%d/%Y');

--#Lets modify the datatype for better analysis of data--#
ALTER TABLE amazon_sales
MODIFY COLUMN invoice_id VARCHAR(30),
MODIFY COLUMN branch VARCHAR(5),
MODIFY COLUMN city VARCHAR(30),
MODIFY COLUMN customer_type VARCHAR(30),
MODIFY COLUMN gender VARCHAR(10),
MODIFY COLUMN product_line VARCHAR(100),
MODIFY COLUMN unit_price DECIMAL(10,2),
MODIFY COLUMN quantity INT,
MODIFY COLUMN date_ DATE,
MODIFY COLUMN time_ TIME,
MODIFY COLUMN payment_method VARCHAR(20),
MODIFY COLUMN cogs DECIMAL(10,2),
MODIFY COLUMN gross_margin_percentage FLOAT(11,9),
MODIFY COLUMN gross_income DECIMAL(10,2),
MODIFY COLUMN rating DECIMAL(10,2);

--#Lets Extract the year from Date Column and create a new column--#
ALTER TABLE amazon_sales
ADD COLUMN year_date YEAR;
UPDATE amazon
SET year_date = YEAR(date_);

--#Update time column format for analysis purpose--#
UPDATE amazon_sales
SET time_ = str_to_date(time_,'%H:%i:%s');

--------------------------#DATA WRANGLING---------------------------------------------------------------------#
--#First step is to build a data base we did that.--#
--#Second step is to create a tables to insert data we also did that.--#
--#Third step is to check the null values in our database here below is query for that--#
SELECT * FROM amazon_sales WHERE rating IS NULL; --# It gives zero output in result it shows we have no null value in our table--#

--#In last checking the datatypes of all columns--#
DESCRIBE amazon_sales;

--------------------------------#FEATURE ENGINEERING-------------------------------------------------#
--#Adding a column named timeofday to bifurcate the sales timing in three section i.e Morning, Afternoon & Evening--#

--#It will give insights about at what time mostly customer are placing order so we can track that and introduce more schemes to boost sales--#

ALTER TABLE amazon_sales
ADD COLUMN time_of_day VARCHAR(30); 

UPDATE amazon_sales
SET time_of_day =
CASE
	WHEN TIME(time_) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(time_) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END;   

--#Adding a column named dayname to bifurcate the days which have more sales and which have less--# 

--#It will give insights about at what day mostly customer are free to placing order so we can track that and introduce more schemes to boost sales--#

    ALTER TABLE amazon_sales
ADD COLUMN day_name VARCHAR(30); 

UPDATE amazon_sales
SET day_name = dayname(date_);

--#Adding a column named monthname to bifurcate the month which have more sales and which have less--# 

--#It will give insights about at what month mostly customer are placing order so we can track that and introduce more schemes to boost sales--#

ALTER TABLE amazon_sales
ADD COLUMN month_name VARCHAR(30); 

UPDATE amazon_sales
SET month_name = monthname(date_);

SELECT * FROM amazon_sales;

--------------------------#EXPLORATORY DATA ANALYSIS-----------------------------------------------##

--#Lets find out Count of sales at which time of a day is highest and lowest--# 
SELECT time_of_day, COUNT(*) AS sales_count
FROM amazon_sales
GROUP BY time_of_day;

--#By analyzing this we can clearly state that Highest Sales Count is in Afternoon and Lowest is in Morning--#
--# Afternoon	454
--# Morning	    191
--# Evening	    355

--#Lets find out Which Branch has highest sales and which one have lowest--# 
SELECT branch, month_name, SUM(total) AS total_sales_amount
FROM amazon_sales
GROUP BY branch, month_name;

--#By analyzing this we can clearly state that Highest Sales is from Branch C and Lowest in Branch A--#

-----------------------------------------#BUSINESS QUESTIONS AND ANSWERS---------------------------------------------##

--#Q1. What is the count of distinct cities in the dataset?--# 

SELECT city, COUNT(DISTINCT city) AS distinct_city_count
FROM amazon_sales GROUP BY city; --# ANS - 3 Cities and Name of this Cities are Mandalay, Naypyitaw, Yangon--#

--#Q2. For each branch, what is the corresponding city?--# 

SELECT branch, city FROM amazon_sales
GROUP BY branch, city; --# ANS - Branch A - City Yangon, Branch B - City Mandalay, Branch C - City Naypyitaw--#

--#Q3. What is the count of distinct product lines in the dataset?--# 

SELECT product_line, COUNT(DISTINCT product_line) AS distinct_product_line_count
FROM amazon_sales GROUP BY product_line; --# ANS - 6 Distinct product line i.e Electronic accessories,Fashion accessories.Food and beverages,Health and beauty,Home and lifestyle,Sports and travel--#

--#Q4. Which payment method occurs most frequently?--# 
SELECT payment_method, COUNT(*) AS frequency FROM amazon_sales
GROUP BY payment_method
ORDER BY frequency DESC; --# ANS - Ewallet-345, Cash-344 ,Credit card-311 It is clearly visible Ewallet is most frequent--#

--#Q5. Which product line has the highest sales?--# 

SELECT product_line AS Product_Line,SUM(quantity) AS Total_Sales
FROM amazon_sales
GROUP BY product_line
ORDER BY Total_Sales DESC
LIMIT 1; --# ANS - Electronic Accessories product line is having highest sales i.e 971--#

--#Q6. How much revenue is generated each month?--# 

SELECT month_name AS Month,SUM(total) AS Revenue
FROM amazon_sales
GROUP BY month_name; --# ANS - JAN - 116291.868, FEB - 97219.373, MAR - 109455.507 Its clearly visible JAN have highest revenue and FEB have lowest--#

--#Q7. In which month did the cost of goods sold reach its peak?--# 

SELECT month_name AS Month,SUM(cogs) AS Total_COGS
FROM amazon_sales
GROUP BY month_name
ORDER BY Total_COGS DESC; --# ANS - January	110754.16, February 92589.88, March 104243.34 JAN have highest COGS --#


--# Q8. Which product line generated the highest revenue? --#

SELECT product_line AS Product_Line,SUM(total) AS Total_Revenue
FROM amazon_sales
GROUP BY product_line
ORDER BY Total_Revenue DESC
LIMIT 1; --# ANS - The Food and Beverages is the product line have highest revenue i.e - 56144.844--#

--# Q9. In which city was the highest revenue recorded? --#

SELECT city AS City,SUM(total) AS Total_Revenue
FROM amazon_sales
GROUP BY city ORDER BY Total_Revenue DESC
LIMIT 1;--# ANS. Naypyitaw has highest revenue recoreded i.e 110568.706

--# Q10. Which product line incurred the highest Value Added Tax? --#

SELECT product_line AS Product_Line,SUM(VAT) AS Total_VAT
FROM amazon_sales
GROUP BY product_line
ORDER BY Total_VAT DESC
LIMIT 1;--# Food and Beverages have incurred highest VAT i.e 2673.563

--# Q11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." --#

SELECT product_line AS Product_Line,SUM(quantity) AS Total_Sales,
    CASE 
        WHEN SUM(quantity) > avg_data.avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Status
FROM amazon_sales
CROSS JOIN (
    SELECT AVG(quantity) AS avg_sales
    FROM amazon_sales
) AS avg_data
GROUP BY product_line, avg_data.avg_sales;

--# Q12. Identify the branch that exceeded the average number of products sold. --#
																																																	
SELECT branch AS Branch,SUM(quantity) AS Total_Sales
FROM amazon_sales
GROUP BY branch
HAVING 
    SUM(quantity) > (SELECT AVG(quantity) AS avg_sales
        FROM amazon_sales);--# ANS - The average number of product sold is 1836.666 and the Branch which exceeds that is Branch A i.e 1859
        
--# Q13. Which product line is most frequently associated with each gender? --#

SELECT gender,product_line AS Most_Frequent_Product_Line,
    COUNT(*) AS Frequency
FROM amazon_sales
GROUP BY gender, product_line
ORDER BY gender, Frequency DESC; --#ANS - The line which is most frequently associate with female is Fashion Accessories and Male is Health and Beauty--#

--# Q14. Calculate the average rating for each product line. --#

SELECT product_line AS Product_Line,AVG(rating) AS Average_Rating
FROM amazon_sales
GROUP BY product_line;

--#ANS - Health and beauty	    7.003289
--#      Electronic accessories	6.924706
--#      Home and lifestyle	    6.837500
--#      Sports and travel	    6.916265
--#      Food and beverages	    7.113218
--#      Fashion accessories	7.029213

--# Q15. Count the sales occurrences for each time of day on every weekday. --#

SELECT 
    day_name AS Day_Name,
    time_of_day AS Time_Of_Day,
    COUNT(*) AS Sales_Occurrences
FROM 
    amazon_sales
GROUP BY 
    day_name, time_of_day
ORDER BY 
    FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), 
    CASE 
        WHEN time_of_day = 'Morning' THEN 1 
        WHEN time_of_day = 'Afternoon' THEN 2 
        WHEN time_of_day = 'Evening' THEN 3 
        ELSE 4 
    END;
    
    --#ANS - Monday	    Morning		21
--#          Monday	    Afternoon	64
--#          Monday		Evening		40
--# 		 Tuesday	Morning		36
--# 		 Tuesday	Afternoon	62
--# 		 Tuesday	Evening		60
--# 		 Wednesday	Morning		22
--# 		 Wednesday	Afternoon	71
--# 		 Wednesday	Evening		50
--# 		 Thursday	Morning		33
--# 		 Thursday	Afternoon	61
--# 		 Thursday	Evening		44
--# 		 Friday		Morning		29
--# 		 Friday		Afternoon	68
--# 		 Friday		Evening		42
--# 		 Saturday	Morning		28
--# 		 Saturday	Afternoon	69
--# 		 Saturday	Evening		67
--# 		 Sunday		Morning		22
--# 		 Sunday		Afternoon	59
--# 		 Sunday		Evening		52

--# Q16. Identify the customer type contributing the highest revenue. --#

SELECT customer_type AS Customer_Type,SUM(total) AS Total_Revenue
FROM amazon_sales
GROUP BY customer_type
ORDER BY Total_Revenue DESC
LIMIT 1; --#ANS - Member customer type is having Highest Revenue i.e 164223.444 --#

--# Q17. Determine the city with the highest VAT percentage. --#

SELECT city AS City,(SUM(VAT) / SUM(unit_price * quantity)) * 100 AS VAT_Percentage
FROM amazon_sales
GROUP BY city ORDER BY 
VAT_Percentage DESC
LIMIT 1;--# ANS - Mandalay City have highest VAT percentage i.e 5.000 --#

--# Q18. Identify the customer type with the highest VAT payments. --#

SELECT customer_type AS Customer_Type,SUM(VAT) AS Total_VAT_Payments
FROM amazon_sales
GROUP BY customer_type ORDER BY Total_VAT_Payments DESC
LIMIT 1;--# ANS - Member have highest VAT payments i.e 7820.164 --#

--# Q19. What is the count of distinct customer types in the dataset? --#

SELECT COUNT(DISTINCT customer_type) AS Distinct_Customer_Types
FROM amazon_sales;--# ANS - 2 Distinct Types of Customer--#

--# Q20. What is the count of distinct payment methods in the dataset? --#

SELECT COUNT(DISTINCT payment_method) AS Distinct_Payment_Methods
FROM amazon_sales;--# ANS - 3 Distinct type of payment methods --#

--# Q21. Which customer type occurs most frequently? --#

SELECT customer_type AS Most_Frequent_Customer_Type,COUNT(*) AS Frequency
FROM amazon_sales
GROUP BY customer_type
ORDER BY Frequency DESC
LIMIT 1; --# ANS - Member customer type is most frequent one with 501 occurence --#

--# Q22. Identify the customer type with the highest purchase frequency. --#

SELECT customer_type AS Customer_Type,COUNT(*) AS Purchase_Frequency
FROM amazon_sales
GROUP BY customer_type ORDER BY Purchase_Frequency DESC
LIMIT 1; --# ANS - Member customer type is having highest purchase frequency

--# Q23. Identify the customer type with the highest purchase frequency. --#

SELECT gender AS Predominant_Gender,COUNT(*) AS Frequency
FROM amazon_sales
GROUP BY gender
ORDER BY Frequency DESC
LIMIT 1; --# ANS - Female gender is Pre Dominant in purchase frequency

--# Q24. Examine the distribution of genders within each branch. --#

SELECT branch AS Branch,gender AS Gender,COUNT(*) AS Frequency
FROM amazon_sales
GROUP BY branch, gender;

--# ANS - A	Female	161
--#       A	Male	179
--#       B	Female	162
--#       B	Male	170
--#       C	Female	178
--#		  C	Male	150

--# Q25. Identify the time of day when customers provide the most ratings. --#

SELECT time_of_day AS Time_Of_Day,COUNT(*) AS Rating_Count
FROM amazon_sales
GROUP BY time_of_day
ORDER BY Rating_Count DESC
LIMIT 1; --# ANS - Afternoon is the time when mostly customer provide rating --#

--# Q26. Determine the time of day with the highest customer ratings for each branch. --#

SELECT branch AS Branch, time_of_day AS Time_Of_Day, COUNT(*) AS Rating_Count
FROM amazon_sales
WHERE rating IS NOT NULL
GROUP BY branch, time_of_day
ORDER BY branch, Rating_Count DESC; --# Afternoon is the time of day with highest customer rating i.e 454 --#

--# Q27. Identify the day of the week with the highest average ratings. --#

SELECT day_name AS Day_Of_Week,AVG(rating) AS Average_Rating
FROM amazon_sales
WHERE rating IS NOT NULL
GROUP BY day_name
ORDER BY Average_Rating DESC
LIMIT 1;--# ANS - Monday is the day which have highest average rating i.e 7.1536 --#

--# Q28. Determine the day of the week with the highest average ratings for each branch. --#

SELECT branch AS Branch,day_name AS Day_Of_Week,AVG(rating) AS Average_Rating
FROM amazon_sales
WHERE rating IS NOT NULL
GROUP BY branch, day_name
ORDER BY branch, Average_Rating DESC; --# ANS - BRANCH A - Friday - 7.312, BRANCH B - Monday - 7.335, BRANCH C - Friday - 7.278






