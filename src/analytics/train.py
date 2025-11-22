# %%

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

from sklearn import tree
from sklearn import ensemble
from sklearn import model_selection
from sklearn import pipeline

from feature_engine.selection import DropFeatures
from feature_engine.imputation import ArbitraryNumberImputer, CategoricalImputer
from feature_engine.encoding import OneHotEncoder

import mlflow

mlflow.set_tracking_uri('http://localhost:5000')
mlflow.set_experiment(experiment_id=731507108798209567)

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%

# SAMPLE - IMPORTAS OS DADOS DE TREINAMENTO

df = pd.read_sql('select * from abt_fiel', con)
df.head()
# %%

# SAMPLE - OOT

df_oot = df[df['DtRef'] == df['DtRef'].max()].reset_index(drop=True)
df_oot

# %%

# SAMPLE - TESTE E TREINO

target = 'flFIEL'

features  = df.columns.tolist()[3:]

df_train_test = df[df['DtRef'] < df['DtRef'].max()].reset_index(drop=True)

X = df_train_test[features]  # Isso é um pd.DataFrame (Matriz)
y = df_train_test[target]  # Isso é um pd.Series (Vetor)

X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y,
                                                    test_size=0.2,
                                                    random_state=42,
                                                    stratify=y)

print(f'Base Treino: {y_train.shape[0]} Unid. | Tx.Target: {100 * y_train.mean():.2f}%')
print(f'Base Teste: {y_test.shape[0]} Unid. | Tx.Target: {100 * y_test.mean():.2f}%')
# %%

# EXPLORE - MISSING VALUES

s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas > 0]
s_nas

# %%

# EXPLORE - BIVARIADA

cat_features = ['descLifeCycleAtual', 'descLifeCycleD28']
num_fetures = list(set(features) - set(cat_features))

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_fetures] = df_train[num_fetures].astype(float)

bivariada = df_train.groupby(target)[num_fetures].median().T
bivariada['ratio'] = (bivariada[1] + 0.001)/ (bivariada[0] + 0.001)
bivariada = bivariada.sort_values('ratio', ascending=False)
bivariada

# %%
df_train.groupby('descLifeCycleAtual')[target].mean()

# %%
df_train.groupby('descLifeCycleD28')[target].mean()
# %%

# MODIFY - DROP

X_train[num_fetures] = X_train[num_fetures].astype(float)

to_remove = bivariada[bivariada['ratio'] == 1].index.tolist()
drop_features = DropFeatures(features_to_drop=to_remove)

# MODIFY - MISSING VALUES

fill_0 = ['github2025', 'python2025']

input_0 = ArbitraryNumberImputer(arbitrary_number=0,
                                     variables=fill_0)

fill_new = ['descLifeCycleD28']

input_new = CategoricalImputer(variables=fill_new, 
                               fill_value='Nao-Usuario')

fill_1000 = ['avgIntervaloDiasVida', 'avgIntervaloDiasD28', 'qtdeDiasUltimaAtividade']

input_1000 = ArbitraryNumberImputer(arbitrary_number=1000,
                                     variables=fill_1000)

# MODIFY - ONEHOT

onehot = OneHotEncoder(variables=cat_features)

# MODEL - ALGORITMO DE ML

# model = tree.DecisionTreeClassifier(random_state=42, min_samples_leaf=50)  
# model = ensemble.AdaBoostClassifier(random_state=42,
#                                     n_estimators=150,
#                                     learning_rate=0.1)
model = ensemble.RandomForestClassifier(random_state=42,
                                        n_estimators=400,
                                        min_samples_leaf=50,
                                        n_jobs=2)
params = {
    "n_estimators": [100, 200, 400, 500, 1000],
    "min_samples_leaf": [10, 20, 30, 50, 75, 100]
}

grid = model_selection.GridSearchCV(model,
                                    param_grid=params,
                                    scoring='roc_auc',
                                    cv=3,
                                    refit=True,
                                    verbose=3,
                                    n_jobs=4)
# CRIANDO PIPELINE

with mlflow.start_run() as r:
    
    mlflow.sklearn.autolog()

    model_pipeline = pipeline.Pipeline(steps=[
        ('Remocao de Features', drop_features),
        ('Imputacao 0', input_0),
        ('Imputacao Nao_Usuario', input_new),
        ('Imputacao 1000', input_1000),
        ('OneHot Encoding', onehot),
        ('Algoritmo', grid),
    ])
        
    model_pipeline.fit(X_train, y_train)
    
    # ASSESS - Métricas de Desempenho

    from sklearn import metrics

    y_pred_train = model_pipeline.predict(X_train)
    y_proba_train = model_pipeline.predict_proba(X_train)

    acc_train = metrics.accuracy_score(y_train, y_pred_train)
    auc_train = metrics.roc_auc_score(y_train, y_proba_train[:, 1])

    print(f'Acurácia Treino: {100 * acc_train:.2f}%')
    print(f'AUC Treino: {100 * auc_train:.2f}%')

    y_pred_test = model_pipeline.predict(X_test)
    y_proba_test = model_pipeline.predict_proba(X_test)

    acc_test = metrics.accuracy_score(y_test, y_pred_test)
    auc_test = metrics.roc_auc_score(y_test, y_proba_test[:, 1])

    print(f'Acurácia Teste: {100 * acc_test:.2f}%')
    print(f'AUC Teste: {100 * auc_test:.2f}%')

    X_oot = df_oot[features]
    y_oot = df_oot[target]

    y_pred_oot = model_pipeline.predict(X_oot)
    y_proba_oot = model_pipeline.predict_proba(X_oot)

    acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
    auc_oot = metrics.roc_auc_score(y_oot, y_proba_oot[:, 1])

    print(f'Acurácia OOT: {100 * acc_oot:.2f}%')
    print(f'AUC OOT: {100 * auc_oot:.2f}%')
    
    mlflow.log_metrics({
        'acc_train': acc_train,
        'auc_train': auc_train,
        'acc_test': acc_test,
        'auc_test': auc_test,
        'acc_oot': acc_oot,
        'auc_oot': auc_oot
    })
    
    roc_train = metrics.roc_curve(y_train, y_proba_train[:, 1])
    roc_test = metrics.roc_curve(y_test, y_proba_test[:, 1])
    roc_oot = metrics.roc_curve(y_oot, y_proba_oot[:, 1])

    plt.figure(dpi=200)

    plt.plot(roc_train[0], roc_train[1], label='Train')
    plt.plot(roc_test[0], roc_test[1], label='Test')
    plt.plot(roc_oot[0], roc_oot[1], label='OOT')
    plt.plot([0, 1], [0, 1], 'k--')
    plt.xlabel('Taxa de Falsos Positivos')
    plt.ylabel('Taxa de Verdadeiros Positivos')
    plt.title('Curva ROC')
    plt.legend([f'Treino: {auc_train:.4f}',
                f'Teste: {auc_test:.4f}',
                f'OOT: {auc_oot:.4f}'])
    plt.grid(True)
    plt.savefig('curva_roc.png')
    
    mlflow.log_artifact('curva_roc.png')

# %%

features_names = (model_pipeline[:-1].transform(X_train.head(-1))
                                    .columns.tolist())

features_importance = pd.Series(model_pipeline[-1].feature_importances_,
                                 index=features_names)

features_importance.sort_values(ascending=False)
# %%
