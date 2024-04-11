# The-final-project-for-the-course-SQL-and-data-acquisition

Проектная работа по модулю
“SQL и получение данных”

Project work on the module "SQL and Data Retrieval"


Перечень вопросов:

List of questions:


№
Вопрос
1
Выведите название самолетов, которые имеют менее 50 посадочных мест?

Retrieve the names of airplanes that have fewer than 50 seats.
2
Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

Output the percentage change in the monthly sum of ticket reservations, rounded to the nearest hundredth.
3
Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

Output the names of airplanes that do not have a business class. The solution should utilize the array_agg function.
4
Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
В результате должны быть код аэропорта, дата вылета, количество пустых мест и накопительный итог.

Output the cumulative total of seat counts in airplanes for each airport on each day, considering only the airplanes that flew empty and only the days where more than one such airplane departed from one airport. The result should include the airport code, departure date, the count of empty seats, and the cumulative total.
5
Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
Выведите в результат названия аэропортов и процентное отношение.
Решение должно быть через оконную функцию.

Find the percentage distribution of flights by routes from the total number of flights. Output the airport names and their percentage ratios. The solution should utilize a window function.
6
Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7

Output the number of passengers for each mobile operator code, considering that the operator code consists of three characters after +7
7
Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
До 50 млн - low
От 50 млн включительно до 150 млн - middle
От 150 млн включительно - high
Выведите в результат количество маршрутов в каждом полученном классе

Classify financial turnovers (total ticket cost) by routes:
Up to 50 million - low
From 50 million inclusive to 150 million - middle
From 150 million inclusive - high
Output the number of routes in each resulting class.
8*
Вычислите медиану стоимости билетов, медиану стоимости бронирования и отношение медианы бронирования к медиане стоимости билетов, округленной до сотых.

Calculate the median ticket cost, the median booking cost, and the ratio of the median booking cost to the median ticket cost, rounded to the nearest hundredth.
9*
Найдите значение минимальной стоимости полета 1 км для пассажира. То есть нужно найти расстояние между аэропортами и с учетом стоимости билетов получить искомый результат.
Для поиска расстояния между двумя точка на поверхности Земли нужно использовать дополнительный модуль earthdistance (https://postgrespro.ru/docs/postgresql/15/earthdistance). Для работы данного модуля нужно установить еще один модуль cube (https://postgrespro.ru/docs/postgresql/15/cube). 
Установка дополнительных модулей происходит через оператор create extension название_модуля.
Функция earth_distance возвращает результат в метрах.
В облачной базе данных модули уже установлены.

Find the minimum cost of flying 1 km per passenger. In other words, you need to find the distance between airports and, considering the ticket prices, obtain the desired result. To find the distance between two points on the Earth's surface, you need to use the additional module earthdistance (https://postgrespro.ru/docs/postgresql/15/earthdistance). To work with this module, you also need to install another module cube (https://postgrespro.ru/docs/postgresql/15/cube). Installation of additional modules is done using the create extension module_name operator. The earth_distance function returns the result in meters. In the cloud database, the modules are already installed.


Пояснения:	
Рейс, перелет - это flight_id, разовый перелет между двумя аэропортами
Маршрут - это все перелеты между двумя аэропортами.

Explanations:
A flight or journey is a flight_id, a one-time flight between two airports.
A route is all flights between two airports.

