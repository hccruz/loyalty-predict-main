CREATE TABLE IF NOT EXISTS abt_fiel AS

WITH tb_join AS (

    SELECT t1.DtRef,
           t1.IdCliente,
           t1.LifeCycle,
           t2.LifeCycle,
           CASE WHEN t2.LifeCycle = '02-FIEL' THEN 1 ELSE 0 END AS flFIEL,
           ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY random()) AS RandomCol

    FROM life_cycle AS t1

    LEFT JOIN life_cycle AS t2
    ON t1.IdCliente = t2.IdCliente
    AND date (t1.DtRef, '+28 day') = date (t2.DtRef)

    WHERE ((t1.DtRef >= '2024-03-01' AND t1.DtRef <= '2025-08-01') OR t1.DtRef = '2025-09-01')
    AND t1.LifeCycle <> '05-ZUMBI'
),

tb_cohort AS (

    SELECT t1.DtRef,
        t1.IdCliente,
        t1.flFIEL

    FROM tb_join AS t1
    WHERE RandomCol <= 2
    ORDER BY IdCliente, DtRef
)

SELECT t1.*,
       t2.idadeDias, 
       t2.qtdeAtivacaoVida,
       t2.qtdeAtivacaoD7,
       t2.qtdeAtivacaoD14,
       t2.qtdeAtivacaoD28,
       t2.qtdeAtivacaoD56,
       t2.qtdeTransacaoVida,
       t2.qtdeTransacaoD7,
       t2.qtdeTransacaoD14,
       t2.qtdeTransacaoD28,
       t2.qtdeTransacaoD56,
       t2.saldoVida,
       t2.saldoVidaD7,
       t2.saldoVidaD14,
       t2.saldoVidaD28,
       t2.saldoVidaD56,
       t2.qtdePontosPosVida,
       t2.qtdePontosPosVidaD7,
       t2.qtdePontosPosVidaD14,
       t2.qtdePontosPosVidaD28,
       t2.qtdePontosPosVidaD56,
       t2.qtdePontosNegVida,
       t2.qtdePontosNegVidaD7,
       t2.qtdePontosNegVidaD14,
       t2.qtdePontosNegVidaD28,
       t2.qtdePontosNegVidaD56,
       t2.qtdeTransacaoManha,
       t2.qtdeTransacaoTarde,
       t2.qtdeTransacaoNoite,
       t2.pctTransacaoManha, 
       t2.pctTransacaoTarde, 
	   t2.pctTransacaoNoite, 
	   t2.QtdeTransacaoDiaVida, 
	   t2.QtdeTransacaoDiaD7, 
	   t2.QtdeTransacaoDiaD14, 
	   t2.QtdeTransacaoDiaD28, 
	   t2.QtdeTransacaoDiaD56, 
	   t2.pctAtivacaoMAU, 
	   t2.qtdehorasVida, 
	   t2.qtdehorasD7, 
	   t2.qtdehorasD14, 
	   t2.qtdehorasD28, 
	   t2.qtdehorasD56, 
	   t2.avgIntervaloDiasVida, 
	   t2.avgIntervaloDiasD28, 
	   t2.qtdeChatMessage, 
	   t2.qtdeAirflowLover, 
	   t2.qtdeRLover, 
	   t2.qtdeResgatarPonei, 
	   t2.qtdeListaPresenca, 
	   t2.qtdePresencaStreak, 
	   t2.qtdeTrocaPontosStreamElements, 
	   t2.qtdeReembolsoStreamElements, 
	   t2.qtdeRPG, 
	   t2.qtdeChurnModel,
       t3.DiasComFrequencia, 
	   t3.descLifeCycleAtual, 
	   t3.descLifeCycleD28, 
	   t3.pctCurioso, 
	   t3.pctFiel, 
	   t3.pctTurista, 
	   t3.pctDesencantada, 
	   t3.pctZumbi, 
	   t3.pctReconquistado, 
	   t3.pctReborn, 
	   t3.avgFreqGrupo, 
	   t3.ratioFreqGrupo,
       t4.qtdeCursosCompletos, 
	   t4.qtdeCursosIncompletos, 
	   t4.carreira, 
	   t4.coletaDados2024, 
	   t4.dsDatabricks2024, 
	   t4.dsPontos2024, 
	   t4.estatistica2024, 
	   t4.estatistica2025, 
	   t4.github2024, 
	   t4.github2025, 
	   t4.iaCanal2025, 
	   t4.lagoMago2024, 
	   t4.loyaltyPredict2025, 
	   t4.machineLearning2025, 
	   t4.matchmakingTramparDeCasa2024, 
	   t4.ml2024, 
	   t4.mlflow2025, 
	   t4.pandas2024, 
	   t4.pandas2025, 
	   t4.python2024, 
	   t4.python2025, 
	   t4.sql2020, 
	   t4.sql2025, 
	   t4.streamlit2025, 
	   t4.tramparLakehouse2024, 
	   t4.tseAnalytics2024, 
	   t4.qtdeDiasUltimaAtividade


FROM tb_cohort AS t1

LEFT JOIN fs_transacional AS t2
ON t1.IdCliente = t2.IdCliente
AND t1.DtRef = t2.DtRef

LEFT JOIN fs_life_cycle AS t3
ON t1.IdCliente = t3.IdCliente
AND t1.DtRef = t3.DtRef

LEFT JOIN fs_education AS t4
ON t1.IdCliente = t4.IdCliente
AND t1.DtRef = t4.DtRef