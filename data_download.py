from pnadium import anual
import pandas as pd
import numpy as np
import os

cache = os.getcwd()
os.makedirs("cache", exist_ok=True)

cache = os.path.join(cache, "cache")

cols = [
    "UF",  # Unidade Federativa
    "V2009",  # Idade
    # Se vai a escola ou não (1 = Sim, 2 = Não, vazio = Não aplicável)
    "V3002",
    "V3034B",
    # Na época, qual foi o principal motivo de ter deixado de frequentar a escola/ o curso superior?
    # Qual foi o principal motivo de nunca ter frequentado escola?
    "V3034A",  # Com que idade ... deixou de frequentar escola /o curso superior pela última vez?
    # Rendimento domiciliar per capita em salários mínimos (Toda a renda, salário, investimentos, blablabla)
    'VDI5009',
    'V3009A'  # Qual foi o curso mais elevado que ... frequentou?
]

# Download dos arquivos de 2019 a 2024
for year in range(2019, 2025):
    teste = anual.download(
        ano=year, tipo='t', t=2, caminho=cache, save_file=True, colunas=cols)
