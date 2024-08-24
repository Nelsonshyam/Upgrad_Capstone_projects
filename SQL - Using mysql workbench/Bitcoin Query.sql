DROP DATABASE IF EXISTS bitcoin;

CREATE DATABASE bitcoin;

USE bitcoin;
RENAME TABLE pricedata to cryptopunkdata;
# 1. How many sales occurred during this time period? 
SELECT COUNT(*) AS Total_sales FROM cryptopunkdata;

# 2. Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
SELECT name,eth_price,usd_price,event_date FROM cryptopunkdata
ORDER BY usd_price DESC
LIMIT 5;

# 3. Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
SELECT event_date,AVG(usd_price) OVER(ORDER BY event_date ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) AS Average_of_50 FROM cryptopunkdata;

# 4. Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
SELECT name,AVG(usd_price) AS average_price FROM cryptopunkdata
GROUP BY name
ORDER BY average_price DESC;

# 5. Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.
SELECT DAYNAME( event_date) AS day_of_week,COUNT(*) AS `Day Count`,AVG(eth_price) AS eth_pirce FROM cryptopunkdata
GROUP BY day_of_week
ORDER BY `Day Count` ASC;

# 6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
SELECT CONCAT(name," was sold for ",usd_price," to ",buyer_address," from ",transaction_hash," on ", event_date) AS summary FROM cryptopunkdata;

# 7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
CREATE VIEW 1919_purchases1 AS
SELECT * FROM cryptopunkdata
WHERE buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

SELECT * FROM 1919_purchases1;

# 8. Create a histogram of ETH price ranges. Round to the nearest hundred value. 
SELECT ROUND(eth_price,-2) AS `ETH price ranges` ,COUNT(*) AS Count, RPAD('',COUNT(*),"*") FROM cryptopunkdata
GROUP BY `ETH price ranges`;

# 9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. 
SELECT name,MAX(usd_price) AS Price,"highest" AS status FROM cryptopunkdata
GROUP BY name
UNION
SELECT name,MIN(usd_price) AS Price,"lowest" AS status FROM cryptopunkdata
GROUP BY name;

# 10. What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 
SELECT name ,ROUND(usd_price,0) ,MONTH( event_date),YEAR( event_date),COUNT(*) FROM cryptopunkdata
GROUP BY name , ROUND(usd_price,0),MONTH( event_date),YEAR( event_date)
ORDER BY COUNT(*) DESC; 

# 11. Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
SELECT MONTH( event_date) AS Month,SUM(usd_price) FROM cryptopunkdata
GROUP BY Month;

# 12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
SELECT COUNT(*) AS "Transaction count" FROM cryptopunkdata
WHERE buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

SELECT COUNT(*) AS "Transaction count" FROM cryptopunkdata
WHERE seller_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

# 13. a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
CREATE TEMPORARY TABLE average_daily AS
SELECT utc_timestamp,usd_price,AVG(usd_price) OVER(PARTITION BY utc_timestamp) AS `Daily AVerage`
FROM cryptopunkdata;

#  b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data.
SELECT ROUND(AVG(usd_price),3) AS `estimated average value`
FROM average_daily
WHERE usd_price>=0.1*`Daily Average`;
