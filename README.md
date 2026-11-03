# Data and R Scripts for Cultural Adaptation and Validation of the ChatGPT Literacy Scale for University Students in Chile

This repository contains R scripts and anonymized datasets used in the cultural adaptation and validation of a scale designed to assess **ChatGPT literacy** among university students in Chile.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16416533.svg)](https://doi.org/10.5281/zenodo.16416533)
[![Article DOI](https://img.shields.io/badge/Article-10.1007%2Fs12144--026--09314--z-blue.svg)](https://doi.org/10.1007/s12144-026-09314-z)
[![License: MIT](https://img.shields.io/badge/Code_License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Data License: CC BY 4.0](https://img.shields.io/badge/Data_License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![R Version](https://img.shields.io/badge/R-%3E%3D%204.3.0-276DC3.svg?logo=r&logoColor=white)](https://www.r-project.org/)
[![Open Science](https://img.shields.io/badge/Open_Science-Open_Data_%26_Code-2ea44f.svg)](https://github.com/ricardomonge/ChatGPT-Lit-Scale-CL)
[![Reproducible](https://img.shields.io/badge/Reproducible-renv-blue.svg)](https://rstudio.github.io/renv/)

---
## Associated Publication

This repository is associated with the following peer-reviewed article:

> Del Río, C. S., Monge-Rogel, R., Fuentes-Lama, R., Fernández-Ochoa, H. (2026).  
> *Cultural adaptation and validation of a ChatGPT literacy scale for university students in Chile*.  
> Current Psychology, 45, Article 778.  
> https://doi.org/10.1007/s12144-026-09314-z

The study presents the cultural adaptation and psychometric validation of the ChatGPT Literacy Scale (CLS) for university students in Chile. The validation process included expert judgment, data from 620 students across three Chilean universities, and exploratory and confirmatory factor analyses. The results support the reliability and validity of the adapted instrument for assessing competencies related to the critical, ethical, communicative, technical, and creative use of ChatGPT in higher education.

---

## Repository Structure

```
├── data/                              # Contains anonymized datasets and documentation
│   ├── sociodemographic_judges.csv    # Expert demographics for content validation
│   ├── data_Aiken_ChatGPT.csv         # Expert item ratings for Aiken's V calculation
│   ├── data_universities.csv          # Full sample for psychometric and factor analysis
│   └── VARIABLES_ALL.md               # Data dictionary describing all variables
├── content_validation.R               # Content validity analysis using Aiken's V
├── psychometric_properties.R          # Exploratory and confirmatory factor analysis (EFA & CFA)
├── renv.lock                          # Snapshot of R package versions for reproducibility
├── README.md                          # Project overview and documentation
└── CITATION.cff                       # Citation metadata for software citation
```

---

## Description of Scripts

- `content_validation.R`: Computes Aiken’s V and confidence intervals for expert judgments of item relevance and wording.
- `psychometric_properties.R`: Runs exploratory factor analysis (EFA), confirmatory factor analysis (CFA), and reliability/validity metrics.

---

## Data Overview

| File                         | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `sociodemographic_judges.csv`| Demographic data of expert judges involved in the content validation process.|
| `data_Aiken_ChatGPT.csv`     | Structured expert ratings for estimating Aiken’s V coefficient.             |
| `data_universities.csv`      | Full anonymized dataset for dimensionality and reliability analysis.        |

All datasets are fully anonymized and comply with institutional and ethical research standards.

---

## Requirements

To reproduce the analyses, please ensure you have the following R packages installed:

```r
install.packages(c(
  "tidyverse", "readxl", "gtsummary", "flextable", "ftExtra", "labelled",
  "huxtable", "psych", "lavaan", "nFactors", "semTools", "corrplot",
  "EGAnet", "performance", "see", "QuantPsyc", "nortest"
))
```

---

## How to Reproduce the Analyses

1. Clone or download this repository.
2. Open each R script in your preferred R environment.
3. Run the scripts in the following order for full analysis pipeline:
   1. `content_validation.R`
   2. `psychometric_properties.R`
4. Ensure the `/data` folder is in your working directory.

---

## Authors and Affiliations

- **Carlos Soto Del Río**¹  
- **Ricardo Monge-Rogel**²³   
- **Ricardo Fuentes-Lama**⁴  
- **Héctor Fernández-Ochoa**⁵  


¹ Facultad de Educación, Universidad de Las Américas, Av. República 71, Santiago, Chile

² Instituto de Matemática, Física y Estadística, Universidad de Las Américas, Av. Manuel Montt 948, Providencia, Chile

³ Grupo de Investigación en Educación STEM (GIE-STEM), Universidad de Las Américas, Chile

⁴ Facultad de Economía y Negocios, Universidad Andrés Bello, Talcahuano, Región del Biobío, Chile

⁵ Vicerrectoría Académica, Universidad Bernardo O’Higgins, Av. Viel 1497, Santiago, Chile


---

## Data Provenance and Ethical Compliance

The datasets in this repository were collected as part of a research project aimed at adapting and validating the ChatGPT Literacy Scale for university students in Chile.

All participants were university students who voluntarily completed the instrument and provided informed consent for the use of their data for academic research purposes. Data collection adhered to institutional ethical guidelines for research involving human subjects.

All data are fully anonymized and provided solely for academic transparency and replication.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Citation

If you use this repository or its materials in your work, please cite the associated article:

**APA:**

> Soto Del Río, C., Monge-Rogel, R., Fuentes-Lama, R., & Fernández-Ochoa, H. (2025). Data and R Scripts for Cultural Adaptation and Validation of the ChatGPT Literacy Scale for University Students in Chile (v1.0.1) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.16416533

**BibTeX:**

```bibtex
@dataset{soto_del_rio_2025_16416533,
  author       = {Soto Del Río, Carlos and
                  Monge-Rogel, Ricardo and
                  Fuentes-Lama, Ricardo and
                  Fernández-Ochoa, Héctor},
  title        = {Data and R Scripts for Cultural Adaptation and
                   Validation of the ChatGPT Literacy Scale for
                   University Students in Chile
                  },
  month        = jul,
  year         = 2025,
  publisher    = {Zenodo},
  version      = {v1.0.1},
  doi          = {10.5281/zenodo.16416533},
  url          = {https://doi.org/10.5281/zenodo.16416533},
}
```
