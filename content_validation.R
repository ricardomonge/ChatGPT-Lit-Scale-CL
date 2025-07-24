# -------------------------------------------------------------------------
# Content Validity Analysis of Expert Judgments Using Aiken's V 
# -------------------------------------------------------------------------

# Load required packages
library(tidyverse)   # Collection of packages for data manipulation
library(readr)       # To read CSV (.csv) files
library(gtsummary)   # To create clean summary tables for reporting
library(flextable)   # To format tables for Word and PowerPoint documents
library(ftExtra)     # Extensions for customizing flextable outputs
library(labelled)    # To manage and apply variable labels in datasets


# Load datasets
file_path1 <- "data/sociodemographic_judges.csv"
df <- read_csv(file_path1)

file_path2 <- "data/data_Aiken_ChatGPT.csv" 
df2 <- read_csv(file_path2)


# -------------------------------------------------------------------------
# Characterization of expert judges
# -------------------------------------------------------------------------

# Recode values before building the table
df <- df %>%
  mutate(
    sexo = recode(sexo,
                  "Femenino" = "Female",
                  "Masculino" = "Male"),
    grado_academico = recode(grado_academico,
                             "Doctorado" = "Doctorate",
                             "Magister" = "Master"),
    especializacion = recode(especializacion,
                             "Educación superior" = "Higher Education",
                             "Psicología" = "Psychology"),
    experiencia_profesional = recode(experiencia_profesional,
                                     "Docencia" = "Teaching",
                                     "Investigación" = "Research"),
    exp_valid_inst = recode(exp_valid_inst,
                            "SI" = "yes",
                            "NO" = "No")  # in case "NO" exists
  )


# Assign variable labels for a clearer summary table
df <- df |> 
  labelled::set_variable_labels(
    sexo = "Sex",
    grado_academico = "Highest level of educational attainment",
    especializacion = "Specialization",
    experiencia_profesional ="Professional background in higher education",
    anios_experiencia = "Years of experience in higher education",
    exp_valid_inst = "Has had experience in the design and evaluation of 
                      assessment instruments"
  )


# Create the summary table
table1 <- tbl_summary(
  df,
  type = list(anios_experiencia ~ "continuous2"),  
  statistic = list(
    all_continuous() ~ c(
      "{median} ({p25}, {p75})",
      "{mean} ({sd})",
      "{min}, {max}"
    ),
    all_categorical() ~ "{n} ({p}%)"
  ),
  digits = list(
    all_continuous() ~ 1,
    all_categorical() ~ c(0, 1)
  )
) |>
  modify_header(label = "Variable") |>  # Rename first column
  modify_caption("Table X. Sociodemographic and Professional Profile of Expert
                 Judges") |>  # Add title
  as_flex_table() |>  # Convert to Word-compatible table
  autofit()

# Display the table
table1


# -------------------------------------------------------------------------
# Results of content validity analysis based on Aiken’s V
# -------------------------------------------------------------------------

# Define function to compute Aiken's V coefficient
compute_aiken_v <- function(valores, k) {
  N <- length(valores)  # Number of expert raters
  V <- sum(valores - 1) / (N * (k - 1))
  return(V)
}

# Define function to compute the confidence interval for Aiken’s V
compute_aiken_ci <- function(V, n, k, confianza = 0.95) {
  z <- qnorm(1 - (1 - confianza) / 2)  # Z-score for the desired confidence level
  
  # Calculate the square root component of the interval
  sqrt_term <- sqrt(4 * n * k * V * (1 - V) + z^2)
  
  # Compute lower and upper bounds of the CI
  L <- (2 * n * k * V + z^2 - z * sqrt_term) / (2 * (n * k + z^2))
  U <- (2 * n * k * V + z^2 + z * sqrt_term) / (2 * (n * k + z^2))
  
  return(c(L, U))
}

# Reshape data to long format for item-level analysis
lf2 <- df2 %>%
  pivot_longer(cols = -dimension, names_to = "item", values_to = "valor")

# Define number of response categories on the scale (e.g., 4-point Likert scale)
k <- 4

# Set desired confidence level (default = 95%)
confianza <- 0.95

# Calculate Aiken's V, mean scores, and CI for each item and dimension
resultados <- lf2 %>%
  group_by(dimension, item) %>%
  summarise(
    promedio = mean(valor),               # Mean rating per item
    V = compute_aiken_v(valor, k),        # Aiken’s V coefficient
    n = length(valor),                    # Number of raters per item
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    lim_inf = compute_aiken_ci(V, n, k, confianza)[1],  # Lower bound of CI
    lim_sup = compute_aiken_ci(V, n, k, confianza)[2]   # Upper bound of CI
  ) %>%
  ungroup()

# Calculate frequency counts for each score (1 to 4) per item
frecuencias <- lf2 %>%
  group_by(dimension, item, valor) %>%
  summarise(frecuencia = n(), .groups = "drop") %>%
  pivot_wider(names_from = valor, values_from = frecuencia,
              values_fill = list(frecuencia = 0))

# Merge frequencies with results to build a complete output table
resultados_final <- resultados %>%
  left_join(frecuencias, by = c("dimension", "item")) %>%
  mutate(across(`1`:`4`, ~replace_na(.x, 0)))  

# Reorder columns for clarity: frequencies, mean, V, CI
resultados_final <- resultados_final %>%
  dplyr::select(dimension, item, `1`, `2`, `3`, `4`, promedio, V,
                lim_inf, lim_sup)

# Round selected numeric columns to 3 decimal places
resultados_final <- resultados_final %>%
  mutate(across(c(promedio, V, lim_inf, lim_sup), ~ round(.x, 3)))



# -------------------------------------------------------------------------
# Separate and format tables by dimension
# -------------------------------------------------------------------------

# Extract items related to the "relevance" dimension
tabla_pertinencia <- resultados_final %>%
  filter(dimension == "relevance") %>%
  dplyr::select(-dimension)

# Extract items related to the "wording" dimension
tabla_redaccion <- resultados_final %>%
  filter(dimension == "wording") %>%
  dplyr::select(-dimension)

# Create a formatted flextable for the relevance dimension
tabla_pertinencia_ft <- tabla_pertinencia %>%
  flextable() %>%
  flextable::set_caption(caption = "Table X.1. Results of the content validity analysis of relevance using Aiken’s V") %>%
  add_header_row(
    values = c("", "Score frequency", "", "", "Confidence interval (95%)"),
    colwidths = c(1, 4, 1, 1, 2)
  ) %>%
  flextable::bold(j = 1, part = "body") %>%
  autofit()



# Create a formatted flextable for the wording dimension
tabla_redaccion_ft <- tabla_redaccion %>%
  flextable() %>%
  flextable::set_caption(caption = "Table X.2 Results of the content validity analysis of wording using Aiken’s V") %>%
  add_header_row(
    values = c("", "Score frequency", "", "", "Confidence interval (95%)"), 
    colwidths = c(1, 4, 1, 1, 2)
  ) %>%
  flextable::bold(j = 1, part = "body") %>%
  autofit()

# Print final formatted tables
tabla_pertinencia_ft
tabla_redaccion_ft



# ============================================================================
# Aiken’s V Visualization for Content Validity (Relevance and Wording)
# This script generates two side-by-side plots displaying Aiken's V values 
# with 95% confidence intervals for two dimensions of content validation.
# Reference lines (at 0.5 and 0.8) and point estimates are included.
# ============================================================================

# ----------------------------------------------------------------------------
# Filter data by dimension: Relevance and Wording
# ----------------------------------------------------------------------------
pertinencia_data <- resultados %>% filter(dimension == "relevance")
redaccion_data   <- resultados %>% filter(dimension == "wording")

# ----------------------------------------------------------------------------
# Plot for Relevance
# ----------------------------------------------------------------------------
p1 <- ggplot(pertinencia_data, aes(x = V, y = item)) +
  geom_point(color = "blue") +  # Point estimates of Aiken's V
  geom_errorbarh(aes(xmin = lim_inf, xmax = lim_sup), height = 0.2, 
                 color = "blue") +  # Confidence intervals
  geom_vline(xintercept = 0.8, color = "gray",
             linetype = "dashed") +  # Threshold reference at 0.8
  geom_vline(xintercept = 0.5, color = "red", 
             linetype = "dashed") +   # Threshold reference at 0.5
  annotate("text", x = 0.5, y = 1.0, label = "0.5", color = "red", size = 4, 
           angle = 90, vjust = -0.5) +  # Label for red line
  geom_text(aes(label = sprintf("%.2f", V)), vjust = -0.5, 
            size = 3.5) +  # Numeric labels on points
  labs(x = "Aiken's V (Relevance)", y = "Item") +
  xlim(0.4, 1) +
  theme_minimal()

p1

# ----------------------------------------------------------------------------
# Plot for Wording
# ----------------------------------------------------------------------------
p2 <- ggplot(redaccion_data, aes(x = V, y = item)) +
  geom_point(color = "blue") +
  geom_errorbarh(aes(xmin = lim_inf, xmax = lim_sup), height = 0.2, 
                 color = "blue") +
  geom_vline(xintercept = 0.8, color = "gray", linetype = "dashed") +
  geom_vline(xintercept = 0.5, color = "red", linetype = "dashed") +
  annotate("text", x = 0.5, y = 1.0, label = "0.5", color = "red", size = 4, 
           angle = 90, vjust = -0.5) +
  geom_text(aes(label = sprintf("%.2f", V)), vjust = -0.5, size = 3.5) +
  labs(x = "Aiken's V (Wording)", y = "Item") +
  xlim(0.4, 1) +
  theme_minimal()

p2

# ----------------------------------------------------------------------------
# Combine both plots into a single window (side by side)
# ----------------------------------------------------------------------------
combined_plot <- grid.arrange(p1, p2, ncol = 2)
