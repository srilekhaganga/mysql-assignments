USE sakila;

-- SUBQUERIES: Questions 1–5
-- A subquery is a query inside another query.
-- It is useful when one query needs a result calculated or retrieved by another query.

-- Question 1: Display all customer details for customers who have made more than 5 payments.
#-- IN checks whether the customer's ID appears in the list of IDs returned by the subquery
-- Useful because several customers can meet the condition.
-- GROUP BY collects payment rows for each customer.
-- COUNT(*) counts each customer's payments.
-- HAVING filters groups after the count is calculated.
-- WHERE cannot filter an aggregate count at this level.
SELECT *
FROM customer 
WHERE customer_id IN (
    SELECT customer_id 
    FROM payment
    GROUP BY customer_id
    HAVING COUNT(*) > 5
);
-- The subquery finds qualifying customer IDs.
-- The outer query retrieves their complete customer details.

# Question 2: Find the names of actors who have acted in more than 10 films ,IN matches actors against the qualifying actor IDs.
-- film_actor connects each actor to their films.
-- Grouping by actor_id lets us count films per actor.
-- Keep only actors linked to more than 10 films.
-- Useful because film counts come from film_actor,
-- while actor names come from the actor table.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    HAVING COUNT(*) > 10
);

# Question 3: Find the names of customers who have never made a payment. c is a short name (alias) for the customer table.
-- NOT EXISTS keeps a customer when the subquery finds no matching payment. SELECT 1 is used because we only need to check
-- whether a row exists; we do not need its details, Useful for finding missing relationships:
-- customers without payments, orders without shipments, etc.
SELECT c.customer_id, c.first_name, c.last_name
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM payment AS p
    WHERE p.customer_id = c.customer_id
);
# Question 4: List all films whose rental rate is higher than the average rental rate of all films.
-- Compare each film's rate with one calculated value.
-- AVG returns the average rental rate across all films.
-- Useful because we do not have to calculate the average
-- separately and manually enter it into the query.
SELECT film_id, title, rental_rate
FROM film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
);

# Question 5: List the titles of films that were never rented.
-- Keep a film only when no rental of any copy is found. rental stores inventory_id, which identifies a copy.
-- Join inventory to rental to connect copies to rentals. Look only for copies belonging to the current film.
-- Useful because one film may have several inventory copies. A film qualifies only if none of its copies was rented.
#Films with no inventory copies also qualify.
SELECT f.film_id, f.title
FROM film AS f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory AS i
    INNER JOIN rental AS r
        ON r.inventory_id = i.inventory_id
    WHERE i.film_id = f.film_id
);
-- CTEs: Questions 6–8
-- A CTE uses WITH to name a query result.It exists only for the statement immediately following it.
-- Useful for breaking a query into readable steps.


-- Question 6: Display customers who rented films in the same month as customer with ID 5.
-- Here, "same month" means the same month AND year.Customer 5 is excluded to show other customers.
-- DISTINCT removes repeated year/month combinations.Customer 5 may have rented several times in one month.
-- DISTINCT displays each customer only once,even if they made several matching rentals.
-- Join customers to their rental records. Match each rental against customer 5's rental months.
-- <> means "not equal to". Useful because the CTE clearly separates finding
-- customer 5's months from finding matching customers.

WITH customer_5_months AS (
    SELECT DISTINCT
        YEAR(rental_date) AS rental_year,
        MONTH(rental_date) AS rental_month
    FROM rental
    WHERE customer_id = 5
)
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
INNER JOIN rental AS r
    ON r.customer_id = c.customer_id
INNER JOIN customer_5_months AS m
    ON YEAR(r.rental_date) = m.rental_year
   AND MONTH(r.rental_date) = m.rental_month
WHERE c.customer_id <> 5;

-- Question 7: Find all staff members who handled atleast one payment greater than the average payment.
-- This CTE returns one row containing the average.DISTINCT prevents staff members from appearing repeatedly
-- when they handled multiple above-average payments. Connect each payment to the staff member who handled it.
-- CROSS JOIN pairs every payment row with the single. average row, making avg_amount available for comparison.
-- Useful because the named CTE makes the average calculation . easy to identify and keeps the main query readable.
WITH average_payment AS (
    SELECT AVG(amount) AS avg_amount
    FROM payment
)
SELECT DISTINCT
    s.staff_id,
    s.first_name,
    s.last_name
FROM staff AS s
INNER JOIN payment AS p
    ON p.staff_id = s.staff_id
CROSS JOIN average_payment AS a
WHERE p.amount > a.avg_amount;

-- Question 8: Show the title and rental duration of films whose rental duration is greater than average.
 -- Calculate the average allowed rental duration.Pair each film with the one-row average result.
 -- Keep films whose allowed rental duration is above average. Useful because the calculation has a meaningful name.
-- A subquery could also solve this question;
-- a CTE is used here to meet the assignment requirement.
WITH average_duration AS (
    SELECT AVG(rental_duration) AS avg_duration
    FROM film
)
SELECT f.title, f.rental_duration
FROM film AS f
CROSS JOIN average_duration AS a
WHERE f.rental_duration > a.avg_duration;

-- TEMPORARY TABLE: Question 9
-- A temporary table stores results within the current database connection and can be used by later statements.
-- Useful when intermediate results need to be reused.


-- Question 9: Find all other customers who have the same address as customer with ID 1.
-- Remove an existing temporary table with this name.IF EXISTS avoids an error when the table is absent.
-- Useful when running this script multiple times.
-- Create a temporary table and store customer 1's address ID.Match customers against the stored address ID.
-- Exclude customer 1 to show other customers only.Remove the intermediate table once we finish using it.
-- It would also disappear when the connection closes.For this small question, a subquery would also work.
-- The temporary table demonstrates storing a result and using it in a separate statement.
DROP TEMPORARY TABLE IF EXISTS customer_1_address;
CREATE TEMPORARY TABLE customer_1_address AS
SELECT address_id
FROM customer
WHERE customer_id = 1;
SELECT c.*
FROM customer AS c
INNER JOIN customer_1_address AS a
    ON a.address_id = c.address_id
WHERE c.customer_id <> 1;
DROP TEMPORARY TABLE IF EXISTS customer_1_address;

-- VIEW: Question 10
-- A regular view saves a SELECT query under a name.
-- Useful for running the same query repeatedly.
-- =====================================================

-- Question 10: List all payments that are greater than the average of all payments.
-- CREATE creates the view if it does not exist.OR REPLACE updates its definition if it already exists.
-- The subquery calculates the average payment amount. The outer query keeps payments greater than that average.
-- Retrieve the results using the view's name.
-- Useful because we can reuse this short SELECT statement.
-- The view stores the query definition, not a fixed
-- snapshot of the results, so it reflects current data.
CREATE OR REPLACE VIEW above_average_payments AS
SELECT *
FROM payment
WHERE amount > (
    SELECT AVG(amount)
    FROM payment
);
SELECT *
FROM above_average_payments;







