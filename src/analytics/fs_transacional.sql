WITH tb_transacao AS(
    SELECT *,
           substr(DtCriacao,0,11) AS dtDia,
           cast(substr(DtCriacao,12,2) AS int) AS dtHora
    FROM transacoes
    WHERE  DtCriacao < '2025-09-30'
),

tb_agg_transacao AS (
    SELECT IdCliente,

        max(julianday(date('2025-09-30', '-1 day')) - julianday(DtCriacao)) AS idadeDias,

        COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-7 day') THEN dtDia END) AS qtdeAtivacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,

        COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-7 day') THEN IdTransacao END) AS qtdeTransacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-09-30', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,

        sum(qtdePontos) AS saldoVida,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-7 day') THEN qtdePontos ELSE 0 END) AS saldoVidaD7,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-14 day') THEN qtdePontos ELSE 0 END) AS saldoVidaD14,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-28 day') THEN qtdePontos ELSE 0 END) AS saldoVidaD28,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-56 day') THEN qtdePontos ELSE 0 END) AS saldoVidaD56,

        sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD7,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD14,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD28,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD56,

        sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-7 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD7,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD14,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD28,
        sum(CASE WHEN dtDia >= date('2025-09-30', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD56,

        count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
        count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
        count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) AS qtdeTransacaoNoite,

        1. * count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoManha,
        1. * count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoTarde,
        1. * count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoNoite

    FROM tb_transacao
    GROUP BY IdCliente
),

tb_agg_calc AS (
    SELECT *,
           COALESCE (1. * qtdeTransacaoVida / qtdeAtivacaoVida, 0) AS QtdeTransacaoDiaVida,
           COALESCE (1. * qtdeTransacaoD7 / qtdeAtivacaoD7, 0) AS QtdeTransacaoDiaD7,
           COALESCE (1. * qtdeTransacaoD14 / qtdeAtivacaoD14, 0) AS QtdeTransacaoDiaD14,
           COALESCE (1. * qtdeTransacaoD28 / qtdeAtivacaoD28, 0) AS QtdeTransacaoDiaD28,
           COALESCE (1. * qtdeTransacaoD56 / qtdeAtivacaoD56, 0) AS QtdeTransacaoDiaD56,

           COALESCE (1. * qtdeAtivacaoD28 / 28, 0) AS pctAtivacaoMAU
        
    FROM tb_agg_transacao
),

tb_horas_dia AS (
    SELECT IdCliente,
        dtDia,
        24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao
    FROM tb_transacao

    GROUP BY IdCliente, dtDia
),

tb_hora_cliente AS(
SELECT IdCliente,
       SUM(duracao) AS qtdehorasVida,
       SUM(CASE WHEN dtDia >= date('2025-09-30', '-7 day') THEN duracao ELSE 0 END) AS qtdehorasD7,
       SUM(CASE WHEN dtDia >= date('2025-09-30', '-14 day') THEN duracao ELSE 0 END) AS qtdehorasD14,
       SUM(CASE WHEN dtDia >= date('2025-09-30', '-28 day') THEN duracao ELSE 0 END) AS qtdehorasD28,
       SUM(CASE WHEN dtDia >= date('2025-09-30', '-56 day') THEN duracao ELSE 0 END) AS qtdehorasD56

FROM tb_horas_dia
GROUP BY IdCliente
),

tb_DiaAnterior AS (
SELECT IdCliente,
       dtDia,
       LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS dtDiaAnterior
FROM tb_horas_dia
),

tb_intervalo_dias AS (
    SELECT IdCliente,
           AVG(julianday(dtDia) - julianday(dtDiaAnterior)) AS avgIntervaloDiasVida,
           AVG(CASE WHEN dtDia >= date('2025-09-30', '-28 day') THEN julianday(dtDia) - julianday(dtDiaAnterior) END) AS avgIntervaloDiasD28

    FROM tb_DiaAnterior

    GROUP BY IdCliente
),

tb_share_produtos AS(
SELECT IdCliente,
       1. * count(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChatMessage,
       1. * count(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeAirflowLover,
       1. * count(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRLover,
       1. * count(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeResgatarPonei,
       1. * count(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeListaPresenca,
       1. * count(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdePresencaStreak,
       1. * count(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeTrocaPontosStreamElements,
       1. * count(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeReembolsoStreamElements,
       1. * count(CASE WHEN DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRPG,
       1. * count(CASE WHEN DescCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChurnModel

FROM tb_transacao AS t1

LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos AS t3
    ON t2.IdProduto = t3.IdProduto

GROUP BY IdCliente
),

tb_join AS (
SELECT t1.*,
       t2.qtdehorasVida,
       t2.qtdehorasD7,
       t2.qtdehorasD14,
       t2.qtdehorasD28,
       t2.qtdehorasD56,
       t3.avgIntervaloDiasVida,
       t3.avgIntervaloDiasD28,
       t4.qtdeChatMessage,
       t4.qtdeAirflowLover,
       t4.qtdeRLover,
       t4.qtdeResgatarPonei,
       t4.qtdeListaPresenca,
       t4.qtdePresencaStreak,
       t4.qtdeTrocaPontosStreamElements,
       t4.qtdeReembolsoStreamElements,
       t4.qtdeRPG,
       t4.qtdeChurnModel
       
FROM tb_agg_calc as t1
LEFT JOIN tb_hora_cliente AS t2
    ON t1.IdCliente = t2.IdCliente
LEFT JOIN tb_intervalo_dias AS t3
    ON t1.IdCliente = t3.IdCliente
LEFT JOIN tb_share_produtos AS t4
    ON t1.IdCliente = t4.IdCliente
)

SELECT date('2025-09-30', '-1 day') AS dtRef,
       *
FROM tb_join