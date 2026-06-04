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
complete_df['Grupo_Amostra'] = complete_df.groupby(['Ano', 'Faixa_Renda'], observed=False).cumcount() // 30

graph1df = complete_df.groupby(['Ano', 'Faixa_Renda', 'Grupo_Amostra'], observed=False)['V3002'].mean().reset_index()
graph1df['Percentual'] = graph1df['V3002'] * 100

print(complete_df)
print(graph1df)

# 4. PLOTANDO O GRÁFICO FINAL
plt.figure(figsize=(15, 7))
sns.set_theme(style="whitegrid")

# Define a ordem exata das categorias no eixo X para o gráfico fazer sentido lógico
ordem_eixo_x = list(income_mapping.values())

sns.boxplot(
    data=graph1df,
    x='Faixa_Renda',
    y='Percentual',
    hue='Ano',
    order=ordem_eixo_x,
    palette='Blues'
)

# Customizações estéticas
plt.title('Percentual de Crianças na Escola por Faixa de Renda Domiciliar Per Capita e Ano', fontsize=14, fontweight='bold', pad=15)
plt.xlabel('Faixa de Renda Domiciliar Per Capita (em Salários Mínimos)', fontsize=12)
plt.ylabel('Frequência Escolar (%)', fontsize=12)
plt.ylim(-5, 105)

# Rotaciona os nomes do eixo X um pouco para não cortar se o espaço for pequeno
plt.xticks(rotation=15, ha='right')
plt.legend(title='Ano de Referência', loc='lower left')

plt.tight_layout()
plt.show()
