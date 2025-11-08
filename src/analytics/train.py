# %%

import pandas as pd

from sklearn.model_selection import train_test_split

from feature_engine.selection import DropFeatures
from feature_engine.imputation import ArbitraryNumberImputer, CategoricalImputer
from feature_engine.encoding import OneHotEncoder

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

import sqlalchemy

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%

# SAMPLE - IMPORTAS OS DADOS DE TREINAMENTO

df = pd.read_sql('abt_fiel', con)
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

X_train, X_test, y_train, y_test = train_test_split(X, y,
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

# MODIFY - APLICANDO TRANSFORMAÇÕES NO CONJUNTO DE DADOS

X_train_transform = drop_features.fit_transform(X_train)
X_train_transform = input_0.fit_transform(X_train_transform)
X_train_transform = input_new.fit_transform(X_train_transform)
X_train_transform = input_1000.fit_transform(X_train_transform)
X_train_transform = onehot.fit_transform(X_train_transform)

# %%
X_train_transform.head()
