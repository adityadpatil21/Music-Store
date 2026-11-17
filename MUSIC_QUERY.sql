SELECT *FROM ALBUM
-- 1.WHO IS THE SENIOR MOST EMPLOYEE BASED ON THE JOB TITLE
SELECT*FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1

-- 2 WHICH COUNTRY HAVE THE MOST INVOICE?(COUNT)
SELECT COUNT(*)cout, billing_country FROM invoice
GROUP BY billing_Country
ORDER BY cout desc;

--3 WHAT ARE TOP 3 VALUE OF TOTAL INVOICE
SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3

-- 4 WHICH CITY HAS BEST CUTOMER ? WE WOULD LIKE TO THROW A PROMOTIONAL MUSIC FESTIVAL IN THE CITY.
-- WE MADE THE MOST MONEY. WRITE A QUERY THAT RETURN ARE CITY THAT HAS THE HIGHEST SUM OF INVOICE TOTALS.
-- RETURN BOTH THE CITY NAME & SUM OF ALL INVOICE TOTALS.

SELECT SUM(total) AS invoice_total, billing_city FROM invoice
GROUP BY billing_city 
ORDER BY invoice_total DESC;

--5 WHO IS THE BEST CUSTOMER ? THE CUSTOMER WHO HAS SPENT THE MOST MONEY WILL BE DECALRED THE BEST CUSTOMER.
-- WRITE A QUERY THAT RETURN THE PERSON WHO HAS SPENT THE MOST MONEY.

SELECT customer.customer_id, customer.first_name, customer.last_name, 
SUM(invoice.total) AS total from customer
JOIN invoice ON
customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

 -- 5 WRITE QUERY TO RETURN THE EMAIL, FIRST NAME, LAST NAME AND GENRE 
 -- OF ALL ROCK MUSIC LISTNERS, RETURN YOUR LIST ORDERED ALPHABETICALLY BY EMAIL STARTING A

SELECT DISTINCT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
SELECT track_id FROM track
JOIN genre ON track.genre_id =genre.genre_id
WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
-- 2 LETS INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASET.
-- WRITE QUERY THAT RETURN THE ARTIST NAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS.

SELECT artist.artist_id, artist.name, 
COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id =track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10

-- 3 RETURN ALL THE TRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN THE AVERAGE SONG LENGTH.
-- RETURN THE NAME OF MILLISECOUNDS FOR EACH TRACK.
-- ORDER BY THE SONG LENGTH WITH THE LONGEST SONGS LISTED FIRST.

SELECT  name, milliseconds from track
WHERE milliseconds > (SELECT AVG(milliseconds)AS avg_track_length FROM track)
ORDER BY milliseconds DESC;



-- 1 FIND THE HOW MUCH AMOUNT SPENT BY EACH CUSTOMER ON ARTISTS?
-- WRITE A QUERY TO RETURN CUSTOMER NAME, ARTIST NAME AND TOTAL SPENT
WITH best_Selling_artist AS (
SELECT artist.artist_id As artist_id, artist.name As artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity )AS total_sales 
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.customer_id , c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity)AS amount_spent
from invoice i
JOIN customer c ON c.customer_id =i.customer_id
JOIN invoice_line il ON il.invoice_id =i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_Selling_artist bsa ON bsa.artist_id= alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- 2 WE WANT TO FIND OUT THE MOST POPULAR MUSIC GNE FOR EACH COUNTRY .WE DETERMINE THE MOST POPULAR GENRE A THE GENRE WITH THE HIGHEST
-- AMOUNT OF PURCHASES. WRITE  A QUERY THAT RETURN EACH COUNTRY ALONG WITH THE TOP GENRE. 
-- FOR COUNTRIES WHERE THE MAXIMUM NUMBER OF PURCHASES IS SHARED RETURN ALL GENRES.
WITH popular_genre AS(
SELECT COUNT(invoice_line.quantity)AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER()OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC)AS RowNO
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id =invoice.customer_id
JOIN track ON track.track_id =invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC

)
SELECT * FROM popular_genre WHERE RowNO <=1

-- 3.WRITE A QUERY THAT DERTERMINE THE CUSTOMER THAT HAS SPENT THE MOST  ON MUSIC FOR EACH COUNTRY.
-- WRITE  A QUERY THAT RETURNS THE COUNTRY  ALONG WITH THE TOP CUSTOMER AND NOW HOW MUCH THEY SPENT 
-- FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED,
-- PROVIED OF CUSTOMERS WHO SPENT THIS AMOUNT.


WITH customer_with_country AS(
SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total)As total_spending,
ROW_NUMBER()OVER (PARTITION BY billing_country ORDER BY SUM(total)DESC )AS RowNO
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 4 ASC, 5 DESC)
SELECT*FROM customer_with_country WHERE RowNo <=1




