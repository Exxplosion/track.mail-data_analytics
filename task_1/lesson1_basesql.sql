-- стандартный запрос
SELECT distinct account_id,
                kills  as totall_kills,
                deaths as total_deaths,
                level
from players
where gold_spent > 0
  and kills between 1 and 20
  and (hero_id = 98 or hero_id = 111)
ORDER BY kills ASC, level DESC;


-- агрегатные функции

select avg(duration)          as average_match_duration
     , min(duration)          as min_match_duration
     , max(duration)          as max_match_duration
     , sum(duration)          as sum_matсh_duration

from match;

-- группировка
select game_mode,
       avg(duration) as average_match_duration,
       min(duration) as min_match_duration,
       max(duration) as max_match_duration,
       sum(duration) as sum_match_duration
from match
GROUP BY game_mode;

-- сделаем красиво (CASE)
select case when game_mode = 2 then 'Captains Mode' else 'Ranked Matchmaking' end as mode,
       round(avg(duration),2) as average_match_duration,
       min(duration) as min_match_duration,
       max(duration) as max_match_duration,
       sum(duration) as sum_match_duration
from match
GROUP BY mode;


-- группировка по 2м и более полям
select case
           when game_mode = 2
               then 'Captains Mode'
           else 'Ranked Matchmaking' end as mode,
       cluster,
       avg(duration)                     as average_match_duration
from match
GROUP BY game_mode, cluster;


-- having
select account_id,
       count(distinct hero_id) as number_of_heroes,
       sum(kills)              as total_kills,
       sum(deaths)             as total_deaths,
       min(gold_spent)         as minumum_gold_spent
from players
where account_id != 0
group by account_id
having count(match_id) > 1;


-- работа с несколькими таблицами
--- inner join
select reg.region,
       avg(m.duration) as average_match_duration,
       min(m.duration) as min_match_duration,
       max(m.duration) as max_match_duration,
       sum(m.duration) as sum_math_duration
from match m
         join cluster_regions reg on m.cluster = reg.cluster
group by reg.region;


-- left outer join
select pl.account_id, rat.total_wins, pl.gold, hn.localized_name
from players pl
         left join player_ratings rat on pl.account_id = rat.account_id
         left join hero_names hn on pl.hero_id = hn.hero_id
where pl.account_id > 0;

--1.Количество матчей, в которых first_blood_time больше 1 минуты, но меньше 3.
select count(first_blood_time) as count_mathes
from match
where (first_blood_time > 1) and (first_blood_time < 3);

--2.Идентификаторы участников (!=0), где победа сил Света и pos_votes > neg_votes
select  players.account_id, players.match_id
from players
    inner join match on (players.match_id = match.match_id)
where (players.account_id != 0) and (match.positive_votes > match.negative_votes) and (match.radiant_win = 'True');
--group by players.account_id;

--3.Вывести идентификаторы игроков и среднюю продолжитьльность матчей данного игрока
select players.account_id,
       avg(match.duration) as average_duration_player
from players
    inner join match on (players.match_id = match.match_id)
group by players.account_id;

--Для анонимных игроков вывести: суммарное потр-е золото, уник-е кол-во исп-х персонажей, среднюю пр-ть матчей
select  sum(players.gold_spent) as sum_gold_spent,
        avg(match.duration) as average_duration_player,
        count(distinct players.hero_id) as number_of_heroes,
        avg(match.duration) as average_duration_player
from players
    left join match on (players.match_id = match.match_id)
where (players.account_id = 0);

--Для каждого hero_name вывести: кол-во матчей где был исп-н, среднее кол-во убийств, минимальное кол-во смертей,
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

--Вывести матчи, в которых хотя бы одна покупка item_id = 42 совершена позднее 100 секунд с начала матча
select distinct match_id
from purchase_log
where (item_id = 42) and (time > 100)

--7.Получить первые 20 строк из всех данны таблиц с матчами и оплатами (purshace log)
select *
from purchase_log
limit 20;

select *
from match
limit 20;

