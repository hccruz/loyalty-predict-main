WITH tb_daily AS (

    SELECT DISTINCT
        date(substr(DtCriacao,0,11)) AS DtDia, 
        IdCliente
    
    FROM transacoes
    ORDER BY DtDia
),

tb_distinct_days AS (

SELECT 
    DISTINCT DtDia AS DtRef
FROM tb_daily
)

SELECT t1.DtRef,
       count(DISTINCT IdCliente) AS MAU,
       count(DISTINCT t2.DtDia) AS qtdeDias

FROM tb_distinct_days t1
LEFT JOIN tb_daily t2
ON t2.DtDia <= t1.DtRef
AND julianday(t1.DtRef) - julianday(t2.DtDia) < 28

GROUP BY t1.DtRef

ORDER BY t1.DtRef ASC

LIMIT 1000;