---------------------------Question Set 1 - Easy-----------
-------------------------------Who is the senior most employee based on job title?-----------------------------------------

select *from employee
where title like 'senior%'
------------------Which countries have the most Invoices?---------------------
select  top 1 billing_country,COUNT(*)
from invoice
group by billing_country
order by count(*) desc
-----------------What are top 3 values of total invoice?----------------------
select top 3 * from invoice
order by total desc
--------------------Which city has the best customers?-------------------
select top 1 billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc

--------------------Who is the best customer? The customer who has spent the most money --------------------
select invoice.customer_id,customer.first_name+' '+last_name, SUM(total) from 
invoice
join 
customer
on invoice.customer_id = customer.customer_id
group by invoice.customer_id,customer.first_name+' '+last_name
order by SUM(total) desc
----------------------------------------------moderate-------------------------------------------------
----------------------------------------Write query to return the email, first name, last name, & Genre of all Rock Music listeners-----------------------------------
select  distinct email,first_name,last_name,genre.name from 
customer
join 
invoice 
on customer.customer_id = invoice.customer_id
join invoice_line 
on invoice.invoice_id = invoice_line.invoice_id
join track
on invoice_line.track_id = track.track_id
join genre
on track.genre_id= genre.genre_id
where genre.name = 'rock'
order by email
----------------------------------q2 Write aquery that returns the Artist name and total track count of the top 10 rock bands---------------------------------------------------------------------------
select  top 10 artist.name, COUNT(genre.name) from 
artist
join album 
on artist.artist_id = album.artist_id
join track
on album.album_id =track.album_id
join genre
on track.genre_id = genre.genre_id
where genre.name='rock'
group by artist.name
order by COUNT(genre.name) desc
----------------------------------------q3 Return all the track names that have a song length longer than the average song length----------------------------------------------------
select name,milliseconds from track 
where milliseconds>
(select AVG(milliseconds) from track
)
order by milliseconds desc
-----------------------------------------------------------advanced------------------------------------------------------
--------------------------------------------q1Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent------------
WITH t1 AS (
    SELECT TOP 1 
        artist.name AS artist_name, 
        SUM(invoice_line.quantity * invoice_line.unit_price) AS total_sales
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
    SELECT 
        customer.first_name + ' ' + customer.last_name AS customer_name, 
        customer.customer_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.quantity * invoice_line.unit_price) AS customer_sales
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
order by t2.customer_sales desc
-------------------------------------------q2 Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres----------------------------
select t1.country,max(t1.purchase)
 from(
 
 select customer.country, genre.name ,count(invoice_line_id) as purchase  from
customer 
    JOIN invoice ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON invoice_line.track_id = track.track_id
join genre on track.genre_id =genre.genre_id
group by customer.country ,genre.name
)t1
group by t1.country
----------------------------------------------q3-Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amoun---------
WITH ranked_customers AS (
    SELECT 
        customer.first_name + ' ' + customer.last_name AS customer_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rank
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY customer.first_name + ' ' + customer.last_name, billing_country
)
SELECT customer_name, billing_country, total_spending
FROM ranked_customers
WHERE rank = 1;

