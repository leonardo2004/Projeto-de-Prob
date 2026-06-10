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

# --- 4. Calcular a Contagem Real de Observações por Ano e Idade ---
dados_contagem <- dados_completos %>%
  filter(!is.na(V2009) & !is.na(V3002)) %>%
  group_by(Ano, V2009) %>%
  summarise(Total_N = n(), .groups = "drop") %>%
  mutate(
    Idade = factor(V2009),
    Ano = factor(Ano, levels = c("2019", "2022", "2023", "2024"))
  )

# --- 5. Calcular o Percentual de Evasão por Ano, Idade e UF ---
dados_agrupados <- dados_completos %>%
  group_by(Ano, V2009, UF) %>%
  summarise(
    Percentual_Evasao = mean(V3002 == 0, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  filter(!is.na(V2009) & !is.na(Percentual_Evasao)) %>%
  mutate(
    Idade = factor(V2009),
    Ano = factor(Ano, levels = c("2019", "2022", "2023", "2024"))
  )

# --- 6. LAÇO DE REPETIÇÃO COM EXIBIÇÃO NO RSTUDIO ---
anos_disponiveis <- c("2019", "2022", "2023", "2024")

for (ano_atual in anos_disponiveis) {
  
  # Filtrar os dados apenas para o ano da iteração atual
  df_plot  <- dados_agrupados %>% filter(Ano == ano_atual)
  df_count <- dados_contagem %>% filter(Ano == ano_atual)
  
  # Cálculo dinâmico do eixo Y específico para este ano
  maior_outlier   <- max(df_plot$Percentual_Evasao, na.rm = TRUE)
  limite_superior <- maior_outlier * 1.15  
  posicao_texto   <- maior_outlier * 1.02  
  
  # Construção do gráfico individual
  p <- ggplot(df_plot, aes(x = Idade, y = Percentual_Evasao, fill = Ano)) +
    geom_boxplot(width = 0.5, outlier.size = 1.5, alpha = 0.7, show.legend = FALSE) +
    
    stat_summary(
      fun = mean, geom = "point", shape = 21, size = 2, 
      fill = "white", color = "black", show.legend = FALSE
    ) +
    
    geom_text(
      data = df_count,
      aes(x = Idade, y = posicao_texto, label = paste0("n=", format(Total_N, big.mark = "."))),
      size = 2.8, fontface = "bold", color = "gray40",    
      angle = 45, hjust = 0, vjust = 0, inherit.aes = FALSE 
    ) +
    
    scale_y_continuous(limits = c(0, limite_superior), breaks = seq(0, round(limite_superior), 5)) +
    
    labs(
      title = paste("Evasão Escolar por Idade (Jovens de 14 a 18 anos) - Ano", ano_atual),
      subtitle = "Linha interna = Mediana das UFs | Ponto Branco = Média das UFs | n = Número Total de Jovens Entrevistados",
      x = "Idade dos Indivíduos (Anos)",
      y = "Percentual de Jovens Fora da Escola (%)"
    ) +
    
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
      plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray30"),
      panel.grid.major = element_line(color = "gray96", linewidth = 0.25), 
      panel.grid.minor = element_blank()
    ) +
    scale_fill_brewer(palette = "Set2", drop = FALSE)
  
  # =========================================================================
  # ALTERAÇÃO AQUI: Força o gráfico a aparecer no painel "Plots" do RStudio
  # =========================================================================
  print(p)
  
  # (Opcional) Mantive o ggsave caso queira que ele continue salvando direto na pasta.
  # Se NÃO quiser que ele salve sozinho na pasta, basta apagar ou comentar as linhas abaixo:
  nome_arquivo <- paste0("Grafico_Evasao_Idade_", ano_atual, ".png")
  ggsave(filename = nome_arquivo, plot = p, width = 8, height = 6, dpi = 300)
}