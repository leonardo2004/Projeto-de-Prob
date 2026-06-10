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

uf_mapping = {
    11: 'RO', 12: 'AC', 13: 'AM', 14: 'RR', 15: 'PA', 16: 'AP', 17: 'TO',
    21: 'MA', 22: 'PI', 23: 'CE', 24: 'RN', 25: 'PB', 26: 'PE', 27: 'AL', 28: 'SE', 29: 'BA',
    31: 'MG', 32: 'ES', 33: 'RJ', 35: 'SP',
    41: 'PR', 42: 'SC', 43: 'RS',
    50: 'MS', 51: 'MT', 52: 'GO', 53: 'DF'
}

regiao_mapping = {
    'RO': 'Norte', 'AC': 'Norte', 'AM': 'Norte', 'RR': 'Norte', 'PA': 'Norte', 'AP': 'Norte', 'TO': 'Norte',
    'MA': 'Nordeste', 'PI': 'Nordeste', 'CE': 'Nordeste', 'RN': 'Nordeste', 'PB': 'Nordeste', 'PE': 'Nordeste', 'AL': 'Nordeste', 'SE': 'Nordeste', 'BA': 'Nordeste',
    'MG': 'Sudeste', 'ES': 'Sudeste', 'RJ': 'Sudeste', 'SP': 'Sudeste',
    'PR': 'Sul', 'SC': 'Sul', 'RS': 'Sul',
    'MS': 'Centro-Oeste', 'MT': 'Centro-Oeste', 'GO': 'Centro-Oeste', 'DF': 'Centro-Oeste'
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

graph_03 = complete_df.copy()
graph_03['Sigla_UF'] = graph_03['UF'].map(uf_mapping)
graph_03 = graph_03.dropna(subset=['Sigla_UF'])
graph_03['Regiao'] = graph_03['Sigla_UF'].map(regiao_mapping)

graph_03['Grupo_Amostra_UF'] = graph_03.groupby(
    ['Sigla_UF'], observed=False).cumcount() // 30

graph_03 = graph_03.groupby(['Regiao', 'Sigla_UF', 'Grupo_Amostra_UF'], observed=False)[
    'V3002'].mean().reset_index()
graph_03['Percentual_Nao_Frequenta'] = (1 - graph_03['V3002']) * 100

ranking_global_uf = graph_03.groupby(
    'Sigla_UF')['Percentual_Nao_Frequenta'].median().sort_values().index.tolist()

graph_03['Rank_Global'] = graph_03['Sigla_UF'].apply(
    lambda x: ranking_global_uf.index(x))

graph_03 = graph_03.sort_values(by=['Regiao', 'Rank_Global'])
ordem_eixo_x = graph_03['Sigla_UF'].unique().tolist()

plt.figure(figsize=(16, 7))
sns.set_theme(style="whitegrid")

sns.boxplot(
    data=graph_03,
    x='Sigla_UF',
    y='Percentual_Nao_Frequenta',
    hue='Sigla_UF',
    order=ordem_eixo_x,
    hue_order=ordem_eixo_x,
    palette='Greens',
    legend=False
)

posicoes_regioes = {}
for i, uf in enumerate(ordem_eixo_x):
    reg = regiao_mapping[uf]
    if reg not in posicoes_regioes:
        posicoes_regioes[reg] = []
    posicoes_regioes[reg].append(i)

for reg, indices in posicoes_regioes.items():
    inicio, fim = indices[0], indices[-1]
    meio = (inicio + fim) / 2
    if fim < len(ordem_eixo_x) - 1:
        plt.axvline(x=fim + 0.5, color='gray', linestyle=':', alpha=0.5)
    plt.text(meio, 55, reg, ha='center', va='bottom',
             fontsize=11, fontweight='bold', color='#264653')

plt.title('Disparidade e Desigualdade na Não Frequência Escolar (14 a 18 anos) por UF agrupadas por Região',
          fontsize=14, fontweight='bold', pad=25)
plt.xlabel('Unidade Federativa (UF) agrupadas por Região Geográfica', fontsize=12)
plt.ylabel('Não Frequência Escolar (%)', fontsize=12)
plt.ylim(-5, 60)

plt.tight_layout()
plt.show()
