import pandas as pd
from sqlalchemy import create_engine

connection_string = 'mysql+mysqlconnector://root:root@127.0.0.1:3307/case_study_features'
db_connection = create_engine(connection_string)

# 2. Ler a tabela diretamente para um DataFrame
print("A carregar dados do SQL...")
df_train = pd.read_sql("SELECT * FROM final_train", db_connection)
df_test = pd.read_sql("SELECT * FROM final_test", db_connection)
print("Dados carregados com sucesso!")
print("Convertendo em parquet...")
# 3. Salvar os DataFrames como arquivos Parquet
df_train.to_parquet("train.parquet", index=False)
df_test.to_parquet("test.parquet", index=False)
print("Arquivos Parquet criados com sucesso!")
