SELECT DtRef,
       LifeCycle,
       count(*) AS QtdeClientes

FROM life_cycle

WHERE LifeCycle <> '05-ZUMBI'
AND DtRef = (SELECT MAX(DtRef) FROM life_cycle)

GROUP BY DtRef, LifeCycle
ORDER BY DtRef, LifeCycle;