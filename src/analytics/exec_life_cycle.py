# %%
import pandas as pd
import sqlalchemy
# %%

def import_query(path: str) -> str:
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query('life-cycle.sql')

# print(query.format(date='2025-08-01'))

engine_app = sqlalchemy.create_engine('sqlite:///../../data/loyalty-system/database.db')

engine_analytical = sqlalchemy.create_engine('sqlite:///../../data/analytics/database.db')
# %%

dates = [
    '2024-05-01',
    '2024-06-01',
    '2024-07-01',
    '2024-08-01',
    '2024-09-01',
    '2024-10-01',
    '2024-11-01',
    '2024-12-01',
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01'
]

for i in dates:
    
    with engine_analytical.connect() as con:
        con.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE DtRef = date('{i}', '-1 day')"))
        con.commit()
    
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql('life_cycle', engine_analytical, if_exists='append', index=False)

# %%
