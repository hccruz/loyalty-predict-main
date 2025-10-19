WITH tb_life_cycle_atual AS(
    SELECT IdCliente,
           DiasComFrequencia,
           LifeCycle AS descLifeCycleAtual

    FROM life_cycle

    WHERE DtRef = date('2025-10-01', '-1 day')
),

tb_life_cycle_D28 AS(
    SELECT IdCliente,
           LifeCycle AS descLifeCycleD28

    FROM life_cycle

    WHERE DtRef = date('2025-09-01', '-29 day')
),

tb_share_ciclos AS(
    SELECT idCliente,
           1. * SUM(CASE WHEN LifeCycle = '01-CURIOSA' THEN 1 ELSE 0 END) / COUNT(*) AS pctCurioso,
           1. * SUM(CASE WHEN LifeCycle = '02-FIEL' THEN 1 ELSE 0 END) / COUNT(*) AS pctFiel,
           1. * SUM(CASE WHEN LifeCycle = '03-TURISTA' THEN 1 ELSE 0 END) / COUNT(*) AS pctTurista,
           1. * SUM(CASE WHEN LifeCycle = '04-DESENCANTADO' THEN 1 ELSE 0 END) / COUNT(*) AS pctDesencantada,
           1. * SUM(CASE WHEN LifeCycle = '05-ZUMBI' THEN 1 ELSE 0 END) / COUNT(*) AS pctZumbi,
           1. * SUM(CASE WHEN LifeCycle = '02-RECONQUISTADO' THEN 1 ELSE 0 END) / COUNT(*) AS pctReconquistado,
           1. * SUM(CASE WHEN LifeCycle = '02-REBORN' THEN 1 ELSE 0 END) / COUNT(*) AS pctReborn

    FROM life_cycle

    WHERE DtRef < '2025-10-01'

    GROUP BY idCliente
),

tb_avg_ciclo AS (
    SELECT descLifeCycleAtual,
           AVG(DiasComFrequencia) AS avgFreqGrupo

    FROM tb_life_cycle_atual

    GROUP BY descLifeCycleAtual
),

tb_join AS(
    SELECT t1.*,
           t2.descLifeCycleD28,
           t3.pctCurioso,
           t3.pctFiel,
           t3.pctTurista,
           t3.pctDesencantada,
           t3.pctZumbi,
           t3.pctReconquistado,
           t3.pctReborn,
           t4.avgFreqGrupo,
           1. * t1.DiasComFrequencia / t4.avgFreqGrupo AS ratioFreqGrupo

    FROM tb_life_cycle_atual AS t1
    LEFT JOIN tb_life_cycle_D28 AS t2
    ON t1.IdCliente = t2.IdCliente

    LEFT JOIN tb_share_ciclos AS t3
    ON t1.IdCliente = t3.IdCliente

    LEFT JOIN tb_avg_ciclo AS t4
    ON t1.descLifeCycleAtual = t4.descLifeCycleAtual
)


SELECT * FROM tb_join
