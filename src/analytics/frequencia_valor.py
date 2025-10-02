# %%

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns


# %%
# Abre conexão com o database transacional
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

# %%

def import_query(path):
   with open(path) as open_file:
       return open_file.read()
   
query = import_query("frequencia_valor.sql")
# %%
df = pd.read_sql_query(query, engine)
df.head()

df = df[df['TotalPontos'] < 4000]

# %%
plt.plot(df['DiasComFrequencia'], df['TotalPontos'], 'o')
plt.xlabel('Dias com Frequência')
plt.ylabel('Total de Pontos')
plt.title('Relação entre Dias com Frequência e Total de Pontos')
plt.grid(True)
plt.show()

# %%
from sklearn import cluster

from sklearn import preprocessing

minmax = preprocessing.MinMaxScaler()

X = minmax.fit_transform(df[['DiasComFrequencia', 'TotalPontos']])

df_X = pd.DataFrame(X, columns=['DiasComFrequencia', 'TotalPontos'])
df_X
# %%
kmeans = cluster.KMeans(n_clusters=5,
                        random_state=42,
                        max_iter=1000)

kmeans.fit(X)

df['Cluster'] = kmeans.labels_

df_X['Cluster_X'] = kmeans.labels_

df.groupby('Cluster')['IdCliente'].count()

# %%
sns.scatterplot(data=df,
                x='DiasComFrequencia',
                y='TotalPontos',
                hue='Cluster',
                palette='deep')

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.grid()
# %%

sns.scatterplot(data=df,
                x='DiasComFrequencia',
                y='TotalPontos',
                hue='CLUSTER',
                palette='deep')
# %%
