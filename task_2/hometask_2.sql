--1.    Первый запрос довольно интересный. В игре иногда очень хорошо решают какие-либо связки героев (например пудж+текис+... и т.п.)
--поэтому я хотел посмотреть на винрейт уникальных кортежей героев (ну типа 5-кой героев "пудж, текис, тини, тинкер, виверна" выиграли в 70% случаев)
--но как окажется далее, в таблице мало записей для такого запроса (не удивительно конечно, количество уникальных таких кортежей с учетом позиции
-- порядка 10**10, что намного больше чем количество 5-ок героев которые у нас есть (их оказываеся порядка 10**4)

with cte_1 as materialized (
    select hero_id,
           match_id,
           player_slot,
           string_agg(hero_id::character varying, ',') over (partition by match_id, player_slot) as heroes_id
    from players
)
--здесь я использовал неизученную на лекции функцию, в выводе понятно что она делает

select heroes_id,
       count(*) as number_unique_her
    from
(
            select match_id,
            string_agg(hero_id::character varying, ',') as heroes_id,
            case when player_slot between 0 and 4 then '0'
               else '1'
               end                                     as team
    from cte_1
    group by match_id, team ) t
group by heroes_id;

--видно, что у нас нет даже пары матчей в которых выбранный сет героев совпадал (в точности до позиции). Я много раз перепроверил,
--действительно так. Ну что же, зато мы получили вот такую информацию

--2.    Небольшой запрос, интересно посмотреть какой герой самый фармящий (то есть у кого больше всего золота).
select
        hn.localized_name,
        gold_spent,
        row_number() over (order by gold desc) as gold_rate
from players
    full join hero_names hn on players.hero_id = hn.hero_id
where (gold_spent != 0);
-- (ожидаемо :))

--3. Теперь посмотрим, у какого героя больше всего число равное (kills+assists)/(deaths + 1)
select
        hn.localized_name,
        (players.kills+players.assists)/(players.deaths + 1) as KAD,
        rank() over (order by (players.kills+players.assists)/(players.deaths + 1) desc) as rating_kda
from players
    inner join hero_names hn on players.hero_id = hn.hero_id
where  players.gold_spent != 0;

--4. У какого самый большой винрейт?
with cte as
         (
             select hero_id,
                    count(hero_id) as total_mathes_hero
             from players
             group by hero_id
         ),
    cte_2 as
         (
             select hero_id,
                case when ((match.radiant_win = 'True') and (p.player_slot between 0 and 4)) or ((match.radiant_win = 'False') and (p.player_slot between 128 and 132)) then 1
                else 0
                end as win_match
             from match
             inner join players p on match.match_id = p.match_id
         ),
    cte_3 as
        (
            select hero_id,
                   sum(cte_2.win_match) as total_win
            from cte_2
            group by hero_id
        )
select cte.hero_id,
       hero_names.localized_name,
       round((cast(cte_3.total_win as float) / cast(cte.total_mathes_hero as float)) :: numeric, 3)  as win_rat,
        rank() over (order by round((cast(cte_3.total_win as float) / cast(cte.total_mathes_hero as float)) :: numeric, 3) desc ) as rank_rate
from cte
inner join cte_3 on cte.hero_id = cte_3.hero_id
inner join hero_names on hero_names.hero_id = cte.hero_id

--Что в итоге? Как видно по последним 3-м запросам видно, спектра занимает топы. Не случайно её или банят или пикают почти в каждой
--рейтинговой игре.