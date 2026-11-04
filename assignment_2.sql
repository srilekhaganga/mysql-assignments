-- MySQL Assignment - 2
-- Database: Sakila
-- Topic: SQL JOINS

USE sakila;

-- #1: List all customers along with the films they have rented.
-- INNER JOIN - " I joined four tables to find the customer name and the movie they rented. I connected them using their common IDs."

select c.first_name, c.last_name, f.title
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id;
    
  #  --2: List all customers and show their rental count,
-- including those who haven't rented any films.
-- LEFT JOIN -" Because an ordinary JOIN would exclude customers with no rentals. " 

select c.first_name, c.last_name, count(r.rental_id) as rental_count
from customer c
left join rental r on c.customer_id = r.customer_id
group by c.customer_id, c.first_name, c.last_name;

#3. Show all films along with their category.
-- Include films that don't have a category assigned
#--Because film and category don't have a direct relationship in the Sakila database. We need film_category to connect them.
#I connected the film table with the category table using film_category. I used LEFT JOIN so films without categories are also displayed.

select f.title, c.name
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on fc.category_id = c.category_id;

#4. Show all customers and staff emails from both customer and staff tables using a full outer join (simulate using LEFT + RIGHT + UNION).
#"MySQL doesn't support FULL OUTER JOIN directly, so I combined LEFT JOIN and RIGHT JOIN using UNION to include records from both tables "

select c.email, s.email
from customer c
left join staff s on c.email = s.email
union
select c.email, s.email
from customer c
right join staff s on c.email = s.email;

#5. Find all actors who acted in the film "ACADEMY DINOSAUR".
# --- I joined actor, film_actor, and film tables and used WHERE to filter actors who appeared in ACADEMY DINOSAUR.
select a.first_name, a.last_name
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
where f.title = 'ACADEMY DINOSAUR';

#6. List all stores and the total number of staff members working in each store, even if a store has no staff.
# --- I used LEFT JOIN to include every store, COUNT to calculate the number of employees, and GROUP BY to get the total for each store.
select st.store_id, count(s.staff_id) as total_staff
from store st
left join staff s on st.store_id = s.store_id
group by st.store_id;

#7. List the customers who have rented films more than 5 times. Include their name and total rental count.
#I joined customer and rental tables, counted the rentals for each customer, and used HAVING to display only customers with more than five rentals.

select c.first_name, c.last_name, count(r.rental_id) as total_rentals
from customer c
join rental r on c.customer_id = r.customer_id
group by c.customer_id, c.first_name, c.last_name
having count(r.rental_id) > 5;
