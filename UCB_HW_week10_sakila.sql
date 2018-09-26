use sakila;
/**
-- 1a. Display the first and last names of all actors from the table actor.
     select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
     select CONCAT(first_name,' ',last_name) as Actor_Name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
    select actor_id, first_name, last_name from actor where first_name like "Joe";
       
-- 2b. Find all actors whose last name contain the letters GEN:
 	   select * from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
     select * from actor where last_name like "%LI%" order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
     select country_id, country from country WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
  ALTER TABLE actor ADD description BLOB;
  select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
 ALTER TABLE actor
 DROP COLUMN description;
 select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
 select last_name, count(*) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
  CREATE VIEW count_last_name AS
  SELECT last_name, count(*) AS count_lastname from actor group by last_name;

  select * from count_last_name where count_lastname > 1;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
 UPDATE actor SET first_name='HARPO' WHERE first_name like 'GROUCHO' and last_name like 'WILLIAMS';
 select * from actor where last_name like 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
 UPDATE actor SET first_name='GROUCHO' WHERE first_name like 'HARPO' and last_name like 'WILLIAMS';
 select * from actor where last_name like 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
 SHOW CREATE TABLE address;
 
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
-- 
-- 
-- 
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
 select staff.first_name, staff.last_name, address.address,address.district from staff 
 left join address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
 select staff.first_name, staff.last_name, b.* from staff 
 inner join (
 select staff_id,sum(amount) as total_amount_rung from payment where payment_date like '2005-08%' group by staff_id) b ON 
 staff.staff_id = b.staff_id;



-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.title,b.number_of_actors from film inner join
( select sum(actor_id) as number_of_actors,film_id from film_actor group by film_id) b
on film.film_id = b.film_id;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as copies from inventory where 
film_id = (select film_id from film where title like 'Hunchback Impossible');


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
 select customer.first_name,customer.last_name,b.total_amount from customer inner join
 (select sum(amount) as total_amount,customer_id  from payment group by customer_id) b
 on customer.customer_id = b.customer_id Order by customer.last_name asc;

 
-- 
--     ![Total amount paid](Images/total_payment.png)
-- 
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from film where title like 'K%' or title like 'Q%' and language_id =
(select language_id from language where name like 'English');


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id IN
 (select actor_id from film_actor where film_id = 
  (select film_id from film where title like 'Alone Trip%'));
  
 
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
   select customer.first_name,customer.last_name, customer.email from customer 
   INNER JOIN 
	( select address.address_id, b.city_id from address 
		INNER JOIN 
		( select city.city_id from city 
			INNER JOIN
				country 
			ON city.country_id = country.country_id where country like 'Canada%') as b 
		ON address.city_id = b.city_id ) as c 
	ON c.address_id = customer.address_id;
  

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film.film_id, film.title from film INNER JOIN 
	(	select film_category.film_id from film_category 
			INNER JOIN category ON film_category.category_id = category.category_id 
			where category.name like 'Family%') as b
				where film.film_id = b.film_id;

-- 7e. Display the most frequently rented movies in descending order.
	CREATE VIEW count_film AS
	select inventory.film_id, count(film_id) as frequency from inventory group by film_id;
	select film.film_id, film.title, b.frequency from film INNER JOIN 
	(select * from count_film) as b ON film.film_id = b.film_id ORDER by b.frequency desc;
**/

-- 7f. Write a query to display how much business, in dollars, each store brought in.

-- 7g. Write a query to display for each store its store ID, city, and country.
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 8b. How would you display the view that you created in 8a?
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.1a. Display the first and last names of all actors from the table actor.
