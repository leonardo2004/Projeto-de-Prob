import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os
import seaborn as sns

input = os.path.join(os.getcwd(), "Dados Filtrados")

dfs = {}

for year in range(2019, 2025):
    if (os.path.isfile(os.path.join(input, f"Dados de {year}"))):
        dfs[year] = pd.read_parquet(os.path.join(input, f'Dados de {year}'))

income_mapping = {
    1: 'Até ¼ SM',
    2: 'Mais de ¼ até ½ SM',
    3: 'Mais de ½ até 1 SM',
    4: 'Mais de 1 até 2 SM',
    5: 'Mais de 2 até 3 SM',
    6: 'Mais de 3 até 5 SM',
    7: 'Mais de 5 SM'
}

for year, df in dfs.items():
    df['Ano'] = year
    df['Faixa_Renda'] = df['VDI5009'].map(income_mapping)

complete_df = pd.concat(list(dfs.values()), ignore_index=True)
complete_df['Grupo_Amostra'] = complete_df.groupby(
    ['Ano', 'Faixa_Renda'], observed=False).cumcount() // 30


graph_01 = complete_df.groupby(['Ano', 'Faixa_Renda', 'Grupo_Amostra'], observed=False)[
    'V3002'].mean().reset_index().copy()
graph_01['Percentual_Nao_Frequenta'] = (1 - graph_01['V3002']) * 100

plt.figure(figsize=(15, 7))
sns.set_theme(style="whitegrid")

ordem_eixo_x = list(income_mapping.values())

sns.boxplot(
    data=graph_01,
    x='Faixa_Renda',
    y='Percentual_Nao_Frequenta',
    hue='Ano',
    order=ordem_eixo_x,
    palette='Greens'
)

plt.title('Percentual de crianças e adolescentes na Escola por Faixa de Renda Domiciliar Per Capita e Ano',
          fontsize=14, fontweight='bold', pad=15)
plt.xlabel(
    'Faixa de Renda Domiciliar Per Capita (em Salários Mínimos)', fontsize=12)
plt.ylabel('Não Frequência Escolar (%)', fontsize=12)
plt.ylim(-5, 105)

plt.xticks(rotation=15, ha='right')
plt.legend(title='Ano de Referência', loc='upper left')

plt.tight_layout()
plt.show()

graph_02 = complete_df.copy()
graph_02['Grupo_Amostra_Idade'] = graph_02.groupby(
    ['Ano', 'V2009'], observed=False).cumcount() // 30

graph_02 = graph_02.groupby(['Ano', 'V2009', 'Grupo_Amostra_Idade'], observed=False)[
    'V3002'].mean().reset_index()

graph_02['Percentual_Nao_Frequenta'] = (1 - graph_02['V3002']) * 100
years = sorted(graph_02['Ano'].unique())

for year in years:
    yeardata = graph_02[graph_02['Ano'] == year]

    plt.figure(figsize=(10, 6))

    sns.boxplot(
        data=yeardata,
        x='V2009',
        y='Percentual_Nao_Frequenta',
        hue='V2009',
        palette='Greens' 
    )

    plt.title(f'Percentual de Jovens que NÃO frequentam a Escola por Idade - Ano {year}',
              fontsize=14, fontweight='bold', pad=15)
    plt.xlabel('Idade', fontsize=12)
    plt.ylabel('Não Frequência Escolar (%)', fontsize=12)
    plt.ylim(-5, 105)

    plt.tight_layout()
    plt.show()
