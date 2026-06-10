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

# --- 4. Calcular a Contagem Real de Observações (Indivíduos) ---
dados_contagem <- dados_completos %>%
  filter(!is.na(VDI5009) & !is.na(V3002)) %>%
  group_by(Ano, VDI5009) %>%
  summarise(Total_N = n(), .groups = "drop") %>%
  mutate(
    VDI5009 = factor(VDI5009, 
                     levels = c(1, 2, 3, 4, 5, 6, 7),
                     labels = c('Até ¼ SM', 
                                'Mais de ¼ até ½ SM', 
                                'Mais de ½ até 1 SM', 
                                'Mais de 1 até 2 SM', 
                                'Mais de 2 até 3 SM', 
                                'Mais de 3 até 5 SM', 
                                'Mais de 5 SM')),
    Ano = as.factor(Ano)
  )

# --- 5. Calcular o Percentual de Evasão por Ano, Renda e UF (para os Box Plots) ---
dados_agrupados <- dados_completos %>%
  group_by(Ano, VDI5009, UF) %>%
  summarise(
    Percentual_Evasao = mean(V3002 == 0, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  filter(!is.na(VDI5009) & !is.na(Percentual_Evasao)) %>%
  mutate(
    VDI5009 = factor(VDI5009, 
                     levels = c(1, 2, 3, 4, 5, 6, 7),
                     labels = c('Até ¼ SM', 
                                'Mais de ¼ até ½ SM', 
                                'Mais de ½ até 1 SM', 
                                'Mais de 1 até 2 SM', 
                                'Mais de 2 até 3 SM', 
                                'Mais de 3 até 5 SM', 
                                'Mais de 5 SM')),
    Ano = as.factor(Ano)
  )

# --- 6. CÁLCULO DINÂMICO DOS LIMITES DO EIXO Y ---
maior_outlier   <- max(dados_agrupados$Percentual_Evasao, na.rm = TRUE)
# Margem expandida para 15% para que o texto inclinado em 45° caiba perfeitamente no topo
limite_superior <- maior_outlier * 1.15  
posicao_texto   <- maior_outlier * 1.02  

# --- 7. Construção do Gráfico Refinado ---
ggplot(dados_agrupados, aes(x = VDI5009, y = Percentual_Evasao, fill = Ano)) +
  
  # Box plots principais
  geom_boxplot(width = 0.7, position = position_dodge(width = 0.8), outlier.size = 1.5, alpha = 0.7) +
  
  # Adiciona a MÉDIA (ponto circular branco)
  stat_summary(
    fun = mean, 
    geom = "point", 
    aes(group = Ano),
    shape = 21, 
    size = 2, 
    fill = "white", 
    color = "black",
    position = position_dodge(width = 0.8),
    show.legend = FALSE
  ) +
  
  # ALTERAÇÃO 1: Número de observações inclinado em 45 graus
  geom_text(
    data = dados_contagem,
    aes(x = VDI5009, y = posicao_texto, label = paste0("n=", format(Total_N, big.mark = ".")), group = Ano),
    position = position_dodge(width = 0.8),
    size = 2.4,
    fontface = "bold",
    color = "gray40",    # Um tom de cinza ligeiramente mais suave para suavizar o visual
    angle = 45,          # Inclina o texto em 45 graus
    hjust = 0,           # Garante que o início do texto fique alinhado ao ponto de origem
    vjust = 0,
    inherit.aes = FALSE 
  ) +
  
  # Ajuste Dinâmico do Eixo Y
  scale_y_continuous(limits = c(0, limite_superior), breaks = seq(0, round(limite_superior), 5)) +
  
  # Customização de títulos e rótulos
  labs(
    title = "Evasão Escolar por Faixa de Renda e Ano (Jovens de 14 a 18 anos)",
    subtitle = "Linha interna = Mediana das UFs | Ponto Branco = Média das UFs | n = Número Total de Jovens Entrevistados",
    x = "Faixa de Rendimento Domiciliar per Capita",
    y = "Percentual de Jovens Fora da Escola (%)",
    fill = "Ano de Referência"
  ) +
  
  # Estética visual do gráfico
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray30"),
    legend.position = "top",
    
    # ALTERAÇÃO 2: Configuração da grade ultra sutil para evitar poluição visual
    panel.grid.major = element_line(color = "gray96", linewidth = 0.25), 
    panel.grid.minor = element_blank(), 
    
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1) 
  ) +
  
  # Paleta de cores
  scale_fill_brewer(palette = "Set2")