--1.Количество матчей, в которых first_blood_time больше 1 минуты, но меньше 3.
select count(first_blood_time) as count_mathes
from match
where (first_blood_time > 1) and (first_blood_time < 3);

--2.Идентификаторы участников (!=0), где победа сил Света и pos_votes > neg_votes
select  players.account_id, players.match_id
from players
    inner join match on (players.match_id = match.match_id)
where (players.account_id != 0) and (match.positive_votes > match.negative_votes) and (match.radiant_win = 'True');

--3.Вывести идентификаторы игроков и среднюю продолжитьльность матчей данного игрока
select players.account_id,
       avg(match.duration) as average_duration_player
from players
    inner join match on (players.match_id = match.match_id)
group by players.account_id;

--4.Для анонимных игроков вывести: суммарное потр-е золото, уник-е кол-во исп-х персонажей, среднюю пр-ть матчей
select  sum(players.gold_spent) as sum_gold_spent,
        avg(match.duration) as average_duration_player,
        count(distinct players.hero_id) as number_of_heroes,
        avg(match.duration) as average_duration_player
from players
    left join match on (players.match_id = match.match_id)
where (players.account_id = 0);

--5.Для каждого hero_name вывести: кол-во матчей где был исп-н, среднее кол-во убийств, минимальное кол-во смертей,
--макс. кол-во потраченного золота, сумм-е кол-во позитинвых отзывов, и сум-е кол-во нег-х отзывов.
select hero_names.localized_name,
       count(players.hero_id) as number_of_use_hero,
       avg(players.kills) as avg_hero_kills,
       min(players.deaths) as min_deaths_hero,
       max(players.gold_spent) as max_gold_spent_hero,
       sum(match.negative_votes) as sum_neg_votes,
       sum(match.positive_votes) as sum_neg_votes
from players
    right join hero_names on (hero_names.hero_id = players.hero_id)
    left join match on (players.match_id = match.match_id)
group by hero_names.localized_name;

--6.Вывести матчи, в которых хотя бы одна покупка item_id = 42 совершена позднее 100 секунд с начала матча
select distinct match_id
from purchase_log
where (item_id = 42) and (time > 100)

--7.Получить первые 20 строк из всех данны таблиц с матчами и оплатами
select *
from purchase_log
limit 20;

select *
from match
limit 20;

