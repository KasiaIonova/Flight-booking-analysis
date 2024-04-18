create extension cube

create extension earthdistance

--1.Выведите название самолетов, которые имеют менее 50 посадочных мест?

explain analyze --34,57

select a.aircraft_code, a.model, count(s.seat_no) as "Количество мест"
from aircrafts a
join seats s on s.aircraft_code = a.aircraft_code 
group by a.aircraft_code
having count(s.seat_no) < 50

--2.Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
--доработка:

select date_trunc ('month', book_date), sum (total_amount),
ROUND(
	((sum (total_amount)- lag( sum (total_amount),1 ) over (order by date_trunc ('month', book_date)))/
	 lag( sum (total_amount),1) over (order by date_trunc ('month', book_date)))* 100, 2
	 )as per_change
from bookings 	
group by 1

--3.Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

select
 *
from (
  select
   a.model,
   array_agg(distinct fare_conditions) as conditions
   	FROM aircrafts a
	INNER JOIN seats s ON (s.aircraft_code = a.aircraft_code)
	GROUP BY a.model
) ff
where not 'Business' = any(conditions)

--4.Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, 
учитывая только те самолеты, которые летали пустыми и только те дни, 
где из одного аэропорта таких самолетов вылетало более одного.
В результате должны быть код аэропорта, дата вылета, количество пустых мест и накопительный итог.

select fl.departure_airport,
	fl.scheduled_departure,
	count( s.seat_no) as empty_seats,
	sum(count(s.seat_no)) OVER (ORDER BY fl.scheduled_departure, fl.departure_airport)
from flights fl
join bookings.aircrafts plane on plane.aircraft_code  = fl.aircraft_code
join bookings.seats s on s.aircraft_code  = plane.aircraft_code
where flight_id in 
	(select distinct
		fl.flight_id
	FROM bookings.flights fl
	join bookings.ticket_flights tf on tf.flight_id = fl.flight_id
	right outer join bookings.boarding_passes bp on bp.flight_id = tf.flight_id)
group by fl.flight_id, fl.departure_airport, fl.scheduled_departure
having Count(fl.flight_id) > 1

--Доработка:
--Второй запрос использует OVER(), чтобы вычислить накопительный итог для каждого аэропорта,
-- разбивая результаты на группы по аэропорту и упорядочивая их по дате. Это дает правильные 
--результаты для накопительного итога. Также во втором запросе используется LEFT JOIN,
--чтобы правильно выбрать только те рейсы, где самолеты летали пустыми.

SELECT
    fl.departure_airport,
    fl.scheduled_departure,
    COUNT(s.seat_no) AS empty_seats,
    SUM(COUNT(s.seat_no)) OVER (PARTITION BY fl.departure_airport ORDER BY fl.scheduled_departure) AS cumulative_total
FROM
    bookings.flights fl
JOIN bookings.aircrafts plane ON plane.aircraft_code = fl.aircraft_code
JOIN bookings.seats s ON s.aircraft_code = plane.aircraft_code
LEFT JOIN (
    SELECT DISTINCT
        fl.flight_id
    FROM
        bookings.flights fl
    JOIN bookings.ticket_flights tf ON tf.flight_id = fl.flight_id
    RIGHT JOIN bookings.boarding_passes bp ON bp.flight_id = tf.flight_id
) AS subq ON fl.flight_id = subq.flight_id
GROUP BY
    fl.departure_airport,
    fl.scheduled_departure
HAVING
    COUNT(fl.flight_id) > 1

--5.Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.

select
	flight_no
	,count(flight_id) as count
	,COUNT(flight_id) / SUM(COUNT(flight_id)) OVER () * 100 percent
from flights
group by flight_no
order by 1

--Доработка:
--SUM(COUNT(flight_id)) OVER () вычисляет общее количество перелетов.
--(COUNT(flight_id) * 100.0) / SUM(COUNT(flight_id)) OVER () вычисляет процентное отношение для каждого маршрута от общего числа перелетов.
--GROUP BY flight_no группирует результаты по маршруту перелета.
--ORDER BY flight_no упорядочивает результаты по номеру перелета.

SELECT
    flight_no,
    COUNT(flight_id) AS count,
    (COUNT(flight_id) * 100.0) / SUM(COUNT(flight_id)) OVER () AS percent
FROM
    flights
GROUP BY
    flight_no
ORDER BY
    flight_no

--6.Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7


SELECT count (t.passenger_id),substring(t.contact_data ->> 'phone' from 3 for 3)
from tickets t 
group by substring(t.contact_data ->> 'phone' from 3 for 3)

--7.Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе.

select distinct
CASE 
    WHEN sum(tf.amount) < 50000000 THEN 'low'
    WHEN sum(tf.amount) >= 50000000 AND sum(tf.amount) < 150000000 THEN 'middle'
    WHEN sum(tf.amount) >= 150000000 THEN 'high'
  END
  ,count(f.flight_no)
	over (order by
	CASE 
		WHEN sum(tf.amount) < 50000000 THEN 'low'
	    WHEN sum(tf.amount) >= 50000000 AND sum(tf.amount) < 150000000 THEN 'middle'
	    WHEN sum(tf.amount) >= 150000000 THEN 'high'
	end
	)
  FROM flights f
join ticket_flights tf on tf.flight_id = f.flight_id
group by f.flight_no

--Доработка:
--Исправленный запрос должен сначала сгруппировать данные по маршрутам, а затем классифицировать финансовые обороты по маршрутам
--Мы сначала выполняем подзапрос, чтобы сгруппировать данные по маршрутам и вычислить общую сумму стоимости билетов для каждого маршрута.
--Затем мы используем этот подзапрос во внешнем запросе, чтобы классифицировать обороты по маршрутам на основе их суммы.
--Результаты группируются по классификации, и для каждого класса выводится количество маршрутов.

SELECT
    CASE 
        WHEN route_total_amount < 50000000 THEN 'low'
        WHEN route_total_amount >= 50000000 AND route_total_amount < 150000000 THEN 'middle'
        WHEN route_total_amount >= 150000000 THEN 'high'
    END AS classification,
    COUNT(*) AS route_count
FROM (
    SELECT
        f.flight_no,
        SUM(tf.amount) AS route_total_amount
    FROM
        flights f
    JOIN ticket_flights tf ON tf.flight_id = f.flight_id
    GROUP BY
        f.flight_no
) AS route_totals
GROUP BY
    CASE 
        WHEN route_total_amount < 50000000 THEN 'low'
        WHEN route_total_amount >= 50000000 AND route_total_amount < 150000000 THEN 'middle'
        WHEN route_total_amount >= 150000000 THEN 'high'
    END

--8.Вычислите медиану стоимости билетов, медиану стоимости бронирования и отношение медианы бронирования к медиане стоимости билетов, 
--округленной до сотых.

		
select
	percentile_cont(0.5) WITHIN GROUP (ORDER BY amount) AS median_price, 
	percentile_cont(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_booking_price,
	round ((percentile_cont(0.5) WITHIN GROUP (ORDER BY total_amount)::numeric)  /
		(percentile_cont(0.5) WITHIN GROUP (ORDER BY amount)::numeric)*100, 2)as "Отношение бронирования к стоимости билетов"
FROM ticket_flights tf
join tickets t on t.ticket_no =tf.ticket_no 
join bookings b on b.book_ref =t.book_ref 

--Доработка:

SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tf.amount) AS median_ticket_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.total_amount) AS median_booking_price,
    ROUND(
        (
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.total_amount) /
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tf.amount)
        )::numeric,
        2
    ) AS booking_to_ticket_ratio
FROM
    ticket_flights tf
JOIN
    tickets t ON tf.ticket_no = t.ticket_no
JOIN
    bookings b ON t.book_ref = b.book_ref


--9.Найдите значение минимальной стоимости полета 1 км для пассажира. То есть нужно найти расстояние между аэропортами 
--и с учетом стоимости билетов получить искомый результат.
--Для поиска расстояния между двумя точка на поверхности Земли нужно использовать дополнительный модуль 
--earthdistance (https://postgrespro.ru/docs/postgresql/15/earthdistance). 
--Для работы данного модуля нужно установить еще один модуль cube (https://postgrespro.ru/docs/postgresql/15/cube). 
--Установка дополнительных модулей происходит через оператор create extension название_модуля.
--Функция earth_distance возвращает результат в метрах.
--В облачной базе данных модули уже установлены.

SELECT 
	--departs.city 
	--, arrivals.city,
	( (point(departs.longitude , departs.latitude) <@> point(arrivals.longitude , arrivals.latitude))* 1.609344  / tf.amount) as price_per_km
FROM flights f
join airports departs on departs.airport_code = f.departure_airport
join airports arrivals on arrivals.airport_code = f.arrival_airport
join ticket_flights tf on tf.flight_id = f.flight_id
order by 1
limit 1

--Доработка:
--Здесь добавлено вычисление расстояния между аэропортами с использованием функции earth_distance, 
--а также расчет стоимости одного километра путешествия.

SELECT 
    tf.amount / earth_distance(
        ll_to_earth(departs.latitude, departs.longitude),
        ll_to_earth(arrivals.latitude, arrivals.longitude)
    ) AS price_per_km
FROM 
    flights f
JOIN 
    airports departs ON departs.airport_code = f.departure_airport
JOIN 
    airports arrivals ON arrivals.airport_code = f.arrival_airport
JOIN 
    ticket_flights tf ON tf.flight_id = f.flight_id
ORDER BY 
    price_per_km
LIMIT 1


