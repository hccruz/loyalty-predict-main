WITH tb_feq_valor AS(

SELECT IdCliente,
       count(DISTINCT SUBSTR(DtCriacao,0,11)) AS DiasComFrequencia,
       sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS TotalPontos
       -- sum(abs(QtdePontos)) AS TotalPontosAbsoluto

from transacoes

WHERE DtCriacao < '2025-09-01'
AND DtCriacao >= date('2025-09-01', '-28 days')

GROUP BY IdCliente
ORDER BY DiasComFrequencia DESC

),

tb_cluster AS(
SELECT *,
        CASE
            WHEN DiasComFrequencia <= 10 AND TotalPontos >= 1500 THEN 'HYPERS'
            WHEN DiasComFrequencia > 10 AND TotalPontos >= 1500 THEN 'EFICIENTES'
            WHEN DiasComFrequencia <= 10 AND TotalPontos >= 1500 THEN 'INDECISOS'
            WHEN DiasComFrequencia > 10 AND TotalPontos >= 750 THEN 'ESFORÇADOS'
            WHEN DiasComFrequencia < 5 THEN 'LURKERS'
            WHEN DiasComFrequencia <= 10 THEN 'PREGUIÇOSOS'
            WHEN DiasComFrequencia > 10 THEN 'POTENCIAIS'
        END AS CLUSTER

FROM tb_feq_valor
)

SELECT *
FROM tb_cluster