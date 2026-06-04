library(PNADcIBGE)
library(data.table)

cache <- file.path(dirname(rstudioapi::getSourceEditorContext()$path) , "cache")
if(!dir.exists(cache)) dir.create(cache)

PNADcVars <- c("UF","V2009","V3002","V3034B","V3034A")
# Define as colunas a serem extraídas da PNADc:
# UF = Unidade da Federação
# V2009 = Idade do morador
# V3002 = Frequência à escola (1=sim, 2=não)
# VD3004 = Nível de ensino frequentado (não usado depois)
# VD4019 = Rendimento mensal domiciliar per capita (ou similar)
# VDI5007
#V3009A

data <- get_pnadc(
  # Ano desejado
  year = 2016,
  # Trimestre desejado
  topic = 2,
  vars = PNADcVars,
  # Força o pacote a baixar os microdados e não um plano amostral com os dados desejados
  design = FALSE,
  # Força o pacote a baixar os dados crus (Não substitur as variáveis pelas interpretações delas), isso é interessante para realizar as comparações e análises
  labels = FALSE,
  # Força o pacote a baixar os dados de novo (Utilizado durante desenvolvimento)
  reload = FALSE,
  savedir = cache
) |>
  as.data.table() |>
  _[V2009 %between% c(14, 18), ..PNADcVars] |>
  _[!is.na(V3034A) & !is.na(V3034A) & !is.na(V3002)]



gc(full=TRUE) # força coleta de lixo
