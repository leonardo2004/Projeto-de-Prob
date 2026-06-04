import pandas as pd
import numpy as np
import os

cache = os.path.join(os.getcwd(), "cache")
output = os.path.join(os.getcwd(), "Dados Filtrados")
os.makedirs(output, exist_ok=True)

df = {}

for year in range(2019, 2025):
    if (os.path.isfile(os.path.join(cache, f"pnad_anual_trimestre_02{year}.parquet"))):
        df[year] = pd.read_parquet(os.path.join(
            cache, f"pnad_anual_trimestre_02{year}.parquet"))
        mask = (df[year]['V2009'] > 13) & (
            df[year]['V2009'] < 19) & (df[year]['VDI5009'] != 9)
        df[year] = df[year][mask]
        df[year]['VDI5009'].dropna(inplace=True)
        df[year]['V3002'].dropna(inplace=True)
        df[year].reset_index(inplace=True)
        df[year].drop(columns=['index', 'UPA', 'V1008',
                      'V2003', 'V1014', 'COD_FAM', 'COD_PESSOA'], inplace=True)
        df[year]['V3002'] = np.where(df[year]['V3002'] == 1, 1, 0)
        df[year].to_parquet(os.path.join(output, f"Dados de {year}"))

print(df[2019])
