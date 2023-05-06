---Q1: who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1

---Q2: which country have the most invoices?

select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc

--Q3: what are the top values of total invoice

select total from invoice 
order by total desc
limit 3

---Q4 which country have the best customers? we would like to throw a promotional Music festival in the city
---we made the most money. write a query that returns one city that has the highest sum of invoice totals
---return both the 	city name & sum of all invoice totals

select sum (total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc

---Q5 who is the best customer? the customer who has spent the most money will be declared the best customer.
---write a query that returns the person who has spent the most money

select customer.customer_id, customer.first_name, customer.last_name, sum(total)as total
from customer 
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

---Q6.lets invite the artist who have written	the most rock music in our dataset. 
---write a query that returns the artist name and total track count of the top 10 rock 	bands



select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

--- Q7: return all the track names that have as song length longer then the average song length 
--- return the name and milliseconds for each track. order by the song length with the longest 
--- listed first.


select name, milliseconds
from track
where milliseconds > (
	select avg (milliseconds) as avg_track_length
	from track)
order by milliseconds desc


---Q8 Find how much amount spent by the customer on artist? write a query to return 
---customer name, artist name and total spent.

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id=track.album_id
	join artist on artist.artist_id=album.artist_id
	group by 1
	order by 3 desc
	limit 1
)

---Q9.We want tofind out the most populer music genre fro each country.
---(we determine the most populer genre as the genre with the highest amount of purchase)

with populer_genre as 
(
	select count(invoice_line.quantity)as purchases, customer.country, genre.name, genre.genre_id,
	Row_number() over(partition by customer.country order by count (invoice_line.quantity) desc)as Rowno
	from invoice_line
	join invoice on invoice.invoice_id=Invoice_line.invoice_id
	join customer on customer.customer_id=invoice.invoice_id
	join track on track.track_id=Invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)

---Q10.Write a query that determines the customer that has spent the most on music for each country.
---Write a query that returns the country along with the top customer and how much they spent.
---for countries where the top amount spent is shared, provide all customers who spent this amount

with recursive
	customer_with_country as (
	select customer.customer_id,first_name, last_name, billing_country,sum(total)as total_spending
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 2,3 desc ),
	
	country_max_spending as(
	select billing_country, max(total_spending)as max_spending
	from customer_with_country
	group by billing_country)
	
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending = ms.max_spending
order by 1









