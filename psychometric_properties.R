# =============================================================================
# PSYCHOMETRIC ANALYSIS OF A MEASUREMENT INSTRUMENT
# =============================================================================

# =============================================================================
# Load Required Libraries -----------------------------------------------------
# =============================================================================

library(dplyr)        # Data manipulation and transformation
library(ggplot2)      # Data visualization using the grammar of graphics
library(readr)        # Reading CSV files
library(grid)         # Base graphics system for grid-based layout
library(gridExtra)    # Combining multiple plots in a grid layout
library(labelled)     # Managing labelled data (e.g., from SPSS)
library(gtsummary)    # Creating publication-ready summary tables
library(huxtable)     # Formatting HTML and LaTeX tables
library(psych)        # Psychometric tools (EFA, reliability, polychoric)
library(MVN)          # Multivariate normality tests (e.g., Mardia)
library(corrplot)     # Visualization of correlation matrices
library(parameters)   # Model parameters extraction and formatting
library(performance)  # Model diagnostics and fit indices
library(nFactors)     # Determine number of factors in EFA
library(lavaan)       # Structural Equation Modeling (SEM and CFA)
library(see)          # Enhanced visualizations for model performance
library(EGAnet)       # Exploratory Graph Analysis (EGA)
library(semTools)     # Utilities for SEM (e.g., AVE, CR, HTMT)
library(QuantPsyc)    # Mardia multivariate normality test
library(nortest)      # Univariate normality tests (e.g., Anderson-Darling)

# =============================================================================
# Load and Prepare Data -------------------------------------------------------
# =============================================================================

file_path1 <- "data/data_universities.csv"
df <- read_csv(file_path1)

# Filter participants with informed consent and who use ChatGPT
df <- df |> dplyr::filter(consentimiento == "SI" & usa_ChatGPT == "SI")

# Compute total score from selected item responses
df <- df %>% mutate(total = rowSums(dplyr::select(., 9:33)))

# =============================================================================
# Hampel Filter for Outliers --------------------------------------------------
# =============================================================================

# Define lower and upper bounds using MAD
cota_inferior <- median(df$total) - 3 * mad(df$total, constant = 1)
cota_superior <- median(df$total) + 3 * mad(df$total, constant = 1)

# Identify and remove outliers
outlier_ind <- which(df$total < cota_inferior | df$total > cota_superior)
df_so <- df[!(row.names(df) %in% outlier_ind), ]

# =============================================================================
# Label Variables -------------------------------------------------------------
# =============================================================================

df_so <- df_so |> labelled::set_variable_labels(
  sexo = "Sex",
  edad = "Age",
  universidad = "University",
  disciplina_OCDE = "OECD Discipline",
  frecuencia_uso_ChatGPT = "How frequently do you use ChatGPT?",
  aceptacion = "What was your level of understanding and acceptance of this 
                instrument?",
  comprension = "What was your level of understanding of the questions?",
  satisfaccion = "What was your level of satisfaction with this instrument?"
)

# =============================================================================
# Descriptive Statistics ------------------------------------------------------
# =============================================================================

# Sociodemographic variables summary table
df_demo <- df_so |>
  dplyr::select(sexo, edad, universidad, disciplina_OCDE, 
                frecuencia_uso_ChatGPT)

theme_gtsummary_eda(set_theme = TRUE)
tbl_summary(df_demo) %>%
  modify_header(label = "Variable") %>%
  modify_caption("Table 1. Participant characteristics") %>%
  as_hux_table()

# Satisfaction items summary table
df_sat <- df_so %>%
  dplyr::select(aceptacion, comprension, satisfaccion)

theme_gtsummary_eda(set_theme = TRUE)
tbl_summary(df_sat) %>%
  modify_header(label = "Variable") %>%
  modify_caption("Table 2. Frequency distribution of satisfaction 
                 with the instrument") %>%
    as_hux_table()

# =============================================================================
# Exploratory and Confirmatory Factor Analysis --------------------------------
# =============================================================================

set.seed(222)                      # Ensure reproducibility
df_so <- as.data.frame(df_so)     # Ensure data frame format
df_items <- dplyr::select(df_so, 9:33)   # Select Likert-type items

# Split sample: EFA and CFA
N <- nrow(df_items)
indices <- seq(1, N)
indices_AFE <- sample(indices, 220)
indices_AFC <- indices[!(indices %in% indices_AFE)]

df_EFA <- df_items[indices_AFE, ]
df_AFC <- df_items[indices_AFC, ]

# Preview EFA data
knitr::kable(head(df_EFA), booktabs = TRUE, format = "markdown")

# Descriptive statistics and frequencies
knitr::kable(describe(df_EFA, type = 3, fast = FALSE), booktabs = TRUE, 
             format = "markdown")
knitr::kable(response.frequencies(df_EFA), booktabs = TRUE, 
             format = "markdown")

# =============================================================================
# Normality Tests -------------------------------------------------------------
# =============================================================================

# Multivariate normality (Mardia)
mardia_result <- QuantPsyc::mult.norm(df_EFA)
print(mardia_result$mult.test)

# Univariate normality (Anderson-Darling)
univar_ad <- apply(df_EFA, 2, ad.test)
resultado_uni <- data.frame(
  Variable = names(univar_ad),
  AD_statistic = sapply(univar_ad, function(x) round(x$statistic, 4)),
  p_value = sapply(univar_ad, function(x) round(x$p.value, 4))
)
knitr::kable(resultado_uni, booktabs = TRUE, format = "markdown",
             caption = "Univariate normality tests using Anderson-Darling")

# =============================================================================
# Exploratory Factor Analysis (EFA) -------------------------------------------
# =============================================================================

performance::check_factorstructure(df_EFA)

# Polychoric correlation matrix
salida <- polychoric(df_EFA, smooth = TRUE)
salida_matriz <- salida$rho

# Ordinal alpha
alpha_ordinal <- psych::alpha(salida_matriz, check.keys = TRUE)

# Confidence interval for alpha
intervalo_alpha_ordinal <- psych::alpha.ci(alpha_ordinal[["total"]][["raw_alpha"]], 
                                           dim(df_EFA)[1], 25, p.val = .05, 
                                           digits = 4)
for(i in 1:length(intervalo_alpha_ordinal)) print(intervalo_alpha_ordinal[i])

# Correlation matrix visualization
corrplot(salida_matriz, type = "upper", tl.pos = "tp")
corrplot(salida_matriz, add = TRUE, type = "lower", method = "number", 
         col = "black", diag = FALSE, tl.pos = "n", cl.pos = "n", 
         number.cex = 0.9)

# Determine number of factors
resultado_nfactors <- n_factors(df_EFA, cor = salida_matriz, 
                                rotation = "oblimin",
                                algorithm = "wls", n = dim(df_EFA)[1], 
                                score = "regression")

plot(resultado_nfactors) + ggplot2::theme_bw()

# Prepare data for EFA
df_EFA <- as.data.frame(lapply(df_EFA, as.integer))

# Run EFA with 5 factors
RDAfactor <- fa(df_EFA, nfactors = 5, fm = "wls", rotate = "oblimin", 
                cor = "poly")
print(RDAfactor, digits = 3, cut = .40, sort = FALSE)

# =============================================================================
# Confirmatory Factor Analysis (CFA) ------------------------------------------
# =============================================================================

cincofactores <- '
CT =~ CT1+CT2+CT3+CT4+CT5+CT6
EC =~ EC1+EC2+EC3+EC4+EC5+EC6
CC =~ CC1+CC2+CC3+CC4+CC5
AC =~ AC1+AC2+AC3+AC4
HE =~ HE1+HE2+HE3+HE4
'

CFA_cinco <- cfa(
  model = cincofactores,
  data  = df_AFC,
  ordered = names(df_AFC),     # idealmente: vector con SOLO los ítems Likert
  estimator = "WLSMV",
  parameterization = "theta"   # recomendado con ordinales (varianzas de error)
  # representation = "LISREL"  # no es necesario; puedes omitirlo
)

fm <- fitMeasures(
  CFA_cinco,
  c("chisq.scaled","df.scaled","pvalue.scaled",
    "cfi.scaled","tli.scaled",
    "rmsea.scaled","rmsea.ci.lower.scaled","rmsea.ci.upper.scaled",
    "srmr")
)

cat(sprintf("χ²robusto(%.0f)=%.2f, p=%.3f; CFIrob=%.3f; TLIrob=%.3f; RMSEArob=%.3f (IC90%% %.3f–%.3f); SRMR=%.3f\n",
            fm["df.scaled"], fm["chisq.scaled"], fm["pvalue.scaled"],
            fm["cfi.scaled"], fm["tli.scaled"],
            fm["rmsea.scaled"], fm["rmsea.ci.lower.scaled"], fm["rmsea.ci.upper.scaled"],
            fm["srmr"]))

# Parameter extraction
parameterEstimates(CFA_cinco, standardized = TRUE) %>% 
  subset(op == "~~" & lhs != rhs)
parameterEstimates(CFA_cinco, standardized = TRUE) %>% 
  subset(op == "=~")
parameterEstimates(CFA_cinco, standardized = TRUE) %>% 
  subset(op == "~~" & lhs == rhs & grepl("^i\\d+", lhs))

# =============================================================================
# Convergent Validity (AVE and CR) -------------------------------------------
# =============================================================================

cr_results <- semTools::compRelSEM(CFA_cinco)
ave_results <- semTools::AVE(CFA_cinco)

cov_std_lv <- standardizedSolution(CFA_cinco) %>%
  dplyr::filter(op == "~~", lhs != rhs) %>%
  dplyr::select(Factor1 = lhs, Factor2 = rhs, Std_LV_Covariance = est.std)

get_std_lv <- function(f1, f2) {
  val <- cov_std_lv %>%
    dplyr::filter((Factor1 == f1 & Factor2 == f2) | (Factor1 == f2 & Factor2 == f1)) %>%
    dplyr::pull(Std_LV_Covariance)
  if (length(val) == 0) return("-") else return(val)
}

# Matrix of AVE and squared inter-factor correlations
Dimensions <- c("CT", "EC", "CC", "AC", "HE")

CT <- c(
  as.numeric(ave_results["CT"]),
  get_std_lv("CT", "EC")^2,
  get_std_lv("CT", "CC")^2,
  get_std_lv("CT", "AC")^2,
  get_std_lv("CT", "HE")^2
)

EC <- c("-", as.numeric(ave_results["EC"]),
        get_std_lv("EC", "CC")^2, get_std_lv("EC", "AC")^2, 
        get_std_lv("EC", "HE")^2)

CC <- c("-", "-", as.numeric(ave_results["CC"]),
        get_std_lv("CC", "AC")^2, get_std_lv("CC", "HE")^2)

AC <- c("-", "-", "-", as.numeric(ave_results["AC"]),
        get_std_lv("AC", "HE")^2)

HE <- c("-", "-", "-", "-", as.numeric(ave_results["HE"]))

matrix_VD <- data.frame(Dimensions, CT, EC, CC, AC, HE, 
                        stringsAsFactors = FALSE)

# Format to 4 decimal places
matrix_VD[ , 2:5] <- lapply(matrix_VD[ , 2:5], function(col) {
  if (is.numeric(col)) {
    sprintf("%.4f", col)
  } else {
    sapply(col, function(x) {
      if (suppressWarnings(!is.na(as.numeric(x)))) {
        sprintf("%.4f", as.numeric(x))
      } else {
        x
      }
    })
  }
})
print(matrix_VD, right = FALSE, row.names = FALSE)

# =============================================================================
# Composite Reliability (CR) --------------------------------------------------
# =============================================================================

sl <- standardizedSolution(CFA_cinco) %>%
  filter(op == "=~") %>%
  dplyr::select(lhs, rhs, est.std) %>%
  mutate(re = 1 - est.std^2)
names(sl) <- c("dimensions", "item", "CFE", "Error")

tl <- sl %>%
  arrange(dimensions) %>%
  group_by(dimensions) %>%
  mutate(fc = sum(CFE)^2 / (sum(CFE)^2 + sum(Error)))
tabla_fc <- aggregate(tl[, 5], list(tl$dimensions), mean)
names(tabla_fc) <- c("Factor", "CR")
tabla_fc

# =============================================================================
# Discriminant Validity: HTMT -------------------------------------------------
# =============================================================================

htmt_manual <- function(cor_matrix, grupos) {
  n <- length(grupos)
  htmt_values <- matrix(NA, n, n)
  rownames(htmt_values) <- colnames(htmt_values) <- names(grupos)
  
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      cor_cross <- cor_matrix[grupos[[i]], grupos[[j]]]
      cor_within_i <- cor_matrix[grupos[[i]], grupos[[i]]]
      cor_within_j <- cor_matrix[grupos[[j]], grupos[[j]]]
      htmt_ij <- mean(abs(cor_cross)) / sqrt(mean(abs(cor_within_i)) * mean(abs(cor_within_j)))
      htmt_values[i, j] <- htmt_ij
      htmt_values[j, i] <- htmt_ij
    }
  }
  return(htmt_values)
}

grupos <- list(
  CT = c("CT1", "CT2", "CT3", "CT4", "CT5", "CT6"),
  EC = c("EC1", "EC2", "EC3", "EC4", "EC5", "EC6"),
  CC = c("CC1", "CC2", "CC3", "CC4", "CC5"),
  AC = c("AC1", "AC2", "AC3", "AC4"),
  HE = c("HE1", "HE2", "HE3", "HE4")
)

htmt_matrix <- htmt_manual(salida_matriz, grupos)
print(htmt_matrix)

# =============================================================================
# Exploratory Graph Analysis (EGA) -------------------------------------------
# =============================================================================

ega.srce <- EGA(data = df_EFA, model = "glasso", plot.EGA = TRUE)

df2_EFA_boot <- bootEGA(
  data = df_EFA,
  seed = 3,
  iter = 500,
  ncores = 4
)
summary(df2_EFA_boot)
