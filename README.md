# SQL Queries for  Music store Database

## Database System: PostgreSQL

These queries were written and executed using **PostgreSQL**, a powerful, open-source object-relational database system known for its advanced features and standards compliance. PostgreSQL was used for this project to manage, query, and analyze the relational data in the DVD rental and music database.

---

## 1. Senior Most Employee Based on Job Title
```sql
SELECT * FROM employee
WHERE title LIKE 'senior%';
```
Explanation: This query retrieves all employees whose job titles start with "Senior". It helps identify the most senior employees within the organization.


## 2. Country with the Most Invoices
```sql
SELECT TOP 1 billing_country, COUNT(*)
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;
```
Explanation: This query returns the country with the highest number of invoices by counting how many invoices are associated with each billing country and then sorting them in descending order.
## 3. Top 3 Invoice Values
```sql
SELECT TOP 3 * FROM invoice
ORDER BY total DESC;
```
Explanation: This query retrieves the top 3 invoices based on the highest total invoice amount.
## 4. City with the Best Customers
```sql
SELECT TOP 1 billing_city, SUM(total)
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC;
```
Explanation: This query identifies the city with the highest customer spending, using the total amount of invoices for each city.
## 5. Best Customer (Customer with the Highest Spending)
sql
```
SELECT invoice.customer_id, customer.first_name + ' ' + customer.last_name, SUM(total)
FROM invoice
JOIN customer ON invoice.customer_id = customer.customer_id
GROUP BY invoice.customer_id, customer.first_name + ' ' + customer.last_name
ORDER BY SUM(total) DESC;
```
Explanation: This query returns the customer who has spent the most money by summing up their total invoice amounts.
## 6. Rock Music Listeners' Emails and Names
``` sql
SELECT DISTINCT email, first_name, last_name, genre.name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'rock'
ORDER BY email;
```
Explanation: This query lists the email, first name, last name, and genre of all customers who have listened to Rock music, showing unique entries.
## 7. Top 10 Rock Bands by Track Count
```sql
SELECT TOP 10 artist.name, COUNT(genre.name)
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'rock'
GROUP BY artist.name
ORDER BY COUNT(genre.name) DESC;
```
Explanation: This query retrieves the top 10 rock bands by counting the number of tracks they have in the Rock genre.

## 8. Tracks Longer Than the Average Song Length
```sql
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;
```
Explanation: This query returns the names and durations of all tracks that are longer than the average track length.

## 9. Amount Spent by Each Customer on Artists
``` sql

WITH t1 AS (
    SELECT TOP 1 artist.name AS artist_name, SUM(invoice_line.quantity * invoice_line.unit_price) AS total_sales
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON invoice_line.track_id = track.track_id
    JOIN album ON track.album_id = album.album_id
    JOIN artist ON album.artist_id = artist.artist_id
    GROUP BY artist.name
    ORDER BY total_sales DESC
), 
t2 AS (
    SELECT customer.first_name + ' ' + customer.last_name AS customer_name, customer.customer_id, artist.name AS artist_name, SUM(invoice_line.quantity * invoice_line.unit_price) AS customer_sales
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON invoice_line.track_id = track.track_id
    JOIN album ON track.album_id = album.album_id
    JOIN artist ON album.artist_id = artist.artist_id
    GROUP BY customer.first_name + ' ' + customer.last_name, customer.customer_id, artist.name
)
SELECT t2.customer_name, t2.customer_id, t2.artist_name, t2.customer_sales, t1.total_sales
FROM t2
JOIN t1 ON t2.artist_name = t1.artist_name
ORDER BY t2.customer_sales DESC;
```
Explanation: This query returns the amount spent by each customer on artists, showing the customer name, artist name, and the total amount they spent.

## 10. Top Genre by Country
```sql

SELECT t1.country, MAX(t1.purchase)
FROM (
    SELECT customer.country, genre.name, COUNT(invoice_line_id) AS purchase
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON invoice_line.track_id = track.track_id
    JOIN genre ON track.genre_id = genre.genre_id
    GROUP BY customer.country, genre.name
) t1
GROUP BY t1.country;
```
Explanation: This query returns the top genre by country based on the number of purchases. For countries where the purchase count is the same across multiple genres, it shows all such genres.

## 11. Top Customer by Country
```sql

WITH ranked_customers AS (
    SELECT customer.first_name + ' ' + customer.last_name AS customer_name, billing_country, SUM(total) AS total_spending, ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rank
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY customer.first_name + ' ' + customer.last_name, billing_country
)
SELECT customer_name, billing_country, total_spending
FROM ranked_customers
WHERE rank = 1;
```
Explanation: This query returns the top customer in each country based on their spending. It partitions the data by billing country and ranks customers based on their total spending.

