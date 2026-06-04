library(writexl)
library(PNADcIBGE)
library(srvyr)
library(tidyverse)
library(janitor)
library(scales)

cache <- file.path(dirname(rstudioapi::getSourceEditorContext()$path) , "cache")
if(!dir.exists(cache)) dir.create(cache)

PNADcVars <- c("UF","V2009","V3002A","VD3004","VD4019","V1028")
# Define as colunas a serem extraídas da PNADc:
# UF = Unidade da Federação
# V2009 = Idade do morador
# V3002A = Frequência à escola (1=sim, 2=não)
# VD3004 = Nível de ensino frequentado (não usado depois)
# VD4019 = Rendimento mensal domiciliar per capita (ou similar)
# V1028 = Condição no domicílio (não usado depois)

raw_data <- get_pnadc(
  # Ano desejado
  year = 2016,
  # Trimestre desejado
  quarter = 1,
  vars = PNADcVars,
  # Força o pacote a baixar os microdados e não um plano amostral com os dados desejados
  design = FALSE,
  # Força o pacote a baixar os dados crus (Não substitur as variáveis pelas interpretações delas), isso é interessante para realizar as comparações e análises
  labels = FALSE,
  # Força o pacote a baixar os dados de novo (Utilizado durante desenvolvimento)
  reload = FALSE,
  savedir = cache
)
  

# Filtra os dados
data <- as_tibble(raw_data) |> # Transforma em tibble, um tipo de dados mais estrito para melhor tratamento de erros
  select(all_of(PNADcVars)) |>
  filter(V2009 >= 14 & V2009 <= 17)
  
rm(raw_data)

glimpse(data)

gc() # força coleta de lixo
