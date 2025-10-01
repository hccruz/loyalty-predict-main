-- curiosa -> idade < 7
-- fiel -> recência < 7 e recência anterior < 15
-- turista -> 7 <= recência <= 14
-- desencantado -> 14 < recência <= 28
-- zumbi -> recência > 28
-- reconquistado -> recência < 7 e 14 <= recência anterior <= 28
-- reborn -> recência < 7 e recência anterior > 28

WITH tb_daily AS (
    SELECT 
        Distinct
        IdCliente,
        substr(DtCriacao,0,11) AS DtDia
    FROM transacoes
    WHERE DtCriacao < '{date}' -- Data de corte da análise
),

tb_idade AS(
    SELECT IdCliente,
        cast(max(julianday('{date}') - julianday(DtDia))as int) AS Idade, -- Quantidade de dias desde a primeira transação
        cast(min(julianday('{date}') - julianday(DtDia))as int) AS Recencia -- Quantidade de dias desde a última transação
    FROM tb_daily
    GROUP BY IdCliente
),

tb_recencia_anterior AS (
    SELECT *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY DtDia DESC) AS QtdeDiasRecenciaAnterior
    FROM tb_daily
),

tb_penultima_ativacao AS(
    SELECT *,
           cast(julianday('{date}') - julianday(DtDia) AS int) AS RecenciaAnterior -- Quantidade de dias desde a penúltima transação
    FROM tb_recencia_anterior
    WHERE QtdeDiasRecenciaAnterior = 2
),

tb_life_cycle AS (
    SELECT t1.*,
        t2.RecenciaAnterior,
        CASE
            WHEN t1.Idade <= 7 THEN '01-CURIOSA'
            WHEN t1.Recencia <= 7 AND t2.RecenciaAnterior - t1.Recencia <= 14 THEN '02-FIEL'
            WHEN t1.Recencia BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN t1.Recencia BETWEEN 15 AND 27 THEN '04-DESENCANTADO'
            WHEN t1.Recencia >= 28 THEN '05-ZUMBI'
            WHEN t1.Recencia <= 7 AND t2.RecenciaAnterior - t1.Recencia <= 27 THEN '02-RECONQUISTADO'
            ELSE '02-REBORN'
        END AS LifeCycle
    FROM tb_idade AS t1
    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.IdCliente = t2.IdCliente
)

SELECT 
    date('{date}', '-1 day') As DtRef,
    *
FROM tb_life_cycle
