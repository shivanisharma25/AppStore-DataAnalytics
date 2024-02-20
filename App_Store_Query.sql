CREATE TABLE appleStore_description_combined AS

select * from appleStore_description1

union all

select * from appleStore_description2

UNION ALL

select * from appleStore_description3

UNION ALL

select * from appleStore_description4

** EXPLORATORY DATA ANALYSIS **

-- Check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is null or user_rating is null OR prime_genre is null

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc is null 

-- Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
Group By prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps' ratings

SELECT min(user_rating) AS MinRating, 
       max(user_rating) AS MaxRating, 
       avg(user_rating) AS AvgRating
FROM AppleStore

** DATA ANALYSIS **

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
           WHEN price > 0 Then 'Paid'
           ELSE 'Free'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratings

SELECT CASE
       when lang_num < 10 THEN '<10 languages'
       WHEN lang_num BETWEEN 10 AND 20 THEN '10-30 languages'
       ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
 FROM AppleStore
 GROUP By language_bucket
 ORDER BY Avg_Rating DESC
 
 -- Check the genres with low ratings
 
 SELECT prime_genre, 
        avg(user_rating) AS Avg_Rating
from AppleStore
Group by prime_genre
order by Avg_Rating ASC
LIMIT 10

-- Check if there is correlation between the length of the app description and the user rating

SELECT case
            when length(b.app_desc) < 500 then 'Short'
            when length(b.app_desc) between 500 and 1000 then 'Medium' 
            else 'Long' 
       end as description_length_bucket, 
       avg(a.user_rating) as average_rating
FROM 
   AppleStore as a
join
   appleStore_description_combined as b 
on
   a.id = b.id
   
group by description_length_bucket
order by average_rating desc

-- Check the top-rated apps for each genre

SELECT
    prime_genre,
    track_name,
    user_rating
from (
      SELECT
      prime_genre, 
      track_name, 
      user_rating,
      RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating desc, rating_count_tot desc) as rank
      from
      AppleStore
     ) as a 
WHERE
a.rank = 1

