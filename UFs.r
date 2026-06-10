# --- 1. Carregar as Bibliotecas Necessárias ---
library(nanoparquet)
library(dplyr)
library(ggplot2)

# --- 2. Configurar Diretório e Carregar Dados ---
rm(list = ls(all.names = TRUE))
gc(reset=TRUE)

setwd("/home/leotl/Documentos/Projeto de prob/")

Dados_2019 <- read_parquet("Dados Filtrados/Dados de 2019")
Dados_2022 <- read_parquet("Dados Filtrados/Dados de 2022")
Dados_2023 <- read_parquet("Dados Filtrados/Dados de 2023")
Dados_2024 <- read_parquet("Dados Filtrados/Dados de 2024")

# --- 3. Preparar e Combinar as Bases de Dados ---
Dados_2019$Ano <- "2019"
Dados_2022$Ano <- "2022"
Dados_2023$Ano <- "2023"
Dados_2024$Ano <- "2024"

dados_completos <- bind_rows(Dados_2019, Dados_2022, Dados_2023, Dados_2024)

# Garante que a coluna UF seja tratada como numérica para o mapeamento
dados_completos$UF <- as.numeric(dados_completos$UF)

# --- 4. Criar o DataFrame de Mapeamento (UFs e Regiões) ---
uf_regiao_mapping <- data.frame(
  UF = c(11, 12, 13, 14, 15, 16, 17,
         21, 22, 23, 24, 25, 26, 27, 28, 29,
         31, 32, 33, 35,
         41, 42, 43,
         50, 51, 52, 53),
  UF_Sigla = c('RO', 'AC', 'AM', 'RR', 'PA', 'AP', 'TO',
               'MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA',
               'MG', 'ES', 'RJ', 'SP',
               'PR', 'SC', 'RS',
               'MS', 'MT', 'GO', 'DF'),
  Regiao = c(rep('Norte', 7),
             rep('Nordeste', 9),
             rep('Sudeste', 4),
             rep('Sul', 3),
             rep('Centro-Oeste', 4))
)

# --- 5. Cruzar os Dados e Calcular as Métricas por Ano e UF ---
dados_uf <- dados_completos %>%
  left_join(uf_regiao_mapping, by = "UF") %>%
  filter(!is.na(Regiao) & !is.na(V3002)) %>%
  group_by(Ano, Regiao, UF_Sigla) %>%
  summarise(
    Percentual_Evasao = mean(V3002 == 0, na.rm = TRUE) * 100,
    Total_N = n(),
    .groups = "drop"
  ) %>%
  mutate(
    Ano = factor(Ano, levels = c("2019", "2022", "2023", "2024")),
    UF_Sigla = as.factor(UF_Sigla)
  )

# --- 6. LAÇO DE REPETIÇÃO PARA GERAR OS GRÁFICOS POR REGIÃO ---
regioes_disponiveis <- unique(dados_uf$Regiao)

for (regiao_atual in regioes_disponiveis) {
  
  # Filtrar dados apenas para a região da iteração atual
  df_regiao <- dados_uf %>% filter(Regiao == regiao_atual)
  
  # Cálculo dinâmico do limite do topo com base na maior barra da região
  maior_valor     <- max(df_regiao$Percentual_Evasao, na.rm = TRUE)
  limite_superior <- maior_valor * 1.15  # Folga para o texto no topo
  posicao_texto   <- maior_valor * 1.02  # Posição horizontal fixa para o 'n' no topo
  
  # Construção do gráfico de barras agrupadas
  p <- ggplot(df_regiao, aes(x = UF_Sigla, y = Percentual_Evasao, fill = Ano)) +
    
    # Barras principais agrupadas lado a lado
    geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.8) +
    
    # ALTERAÇÃO 1: Número de observações fixado no TOPO do gráfico e inclinado em 45°
    geom_text(
      aes(y = posicao_texto, label = paste0("n=", format(Total_N, big.mark = "."))),
      position = position_dodge(width = 0.8),
      size = 2.4, 
      fontface = "bold", 
      color = "gray40",    
      angle = 45,          
      hjust = 0,           
      vjust = 0
    ) +
    
    # Ajuste Dinâmico do Eixo Y para a região atual
    scale_y_continuous(limits = c(0, limite_superior), breaks = seq(0, round(limite_superior), 5)) +
    
    # Títulos corrigidos (sem menção à média)
    labs(
      title = paste("Evasão Escolar na Região", regiao_atual, "(Jovens de 14 a 18 anos)"),
      subtitle = "Altura da Barra = Taxa de Evasão da UF | n = Total de Jovens Entrevistados no Ano",
      x = "Unidade Federativa (UF)",
      y = "Percentual de Jovens Fora da Escola (%)",
      fill = "Ano de Referência"
    ) +
    
    # Estética visual limpa e controle de poluição
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
      plot.subtitle = element_text(hjust = 0.5, size = 10.5, color = "gray30"),
      legend.position = "top",
      
      # Grade de fundo ultra sutil mantida
      panel.grid.major = element_line(color = "gray96", linewidth = 0.25), 
      panel.grid.minor = element_blank(),
      
      axis.text.x = element_text(face = "bold", size = 11)
    ) +
    
    # Paleta de cores original
    scale_fill_brewer(palette = "Set2", drop = FALSE)
  
  # 1. Envia para a aba "Plots" do RStudio
  print(p)
  
  # 2. Salva o arquivo PNG no diretório
  nome_arquivo <- paste0("Grafico_Evasao_Barras_", regiao_atual, ".png")
  ggsave(filename = nome_arquivo, plot = p, width = 9, height = 6, dpi = 300)
  
  cat("Gráfico da Região", regiao_atual, "atualizado com sucesso!\n")
}