# Socioeconomic Vulnerability-Drought Severity (SV-DS) Index for Angola's Drought Decision Support System
This repo stores my work for the Space Enabled Research Group in the MIT Media Lab. Here, I am using the lab's EVDT framework [^1] to improve Angola's Drought Decision Support System.
[^1]: Borne from a systems architecture concept, the Environment, Vulnerability, Decision-making, Technology (EVDT) Framework, incorporates various dimensions to model a complex sustainability issue. This concept is created by the [lab](https://www.media.mit.edu/projects/integrated-complex-systems-modeling/overview/) itself.

## Abstract
Due to the worsened cycles of flooding and dry spells in Angola and its heavy reliance on rainfed agriculture, the country faces serious issues such as food insecurity and livelihood decline. With limited resources, stakeholders and policymakers must identify the most vulnerable areas that require immediate action. However, it is still unclear what areas are experiencing the brunt of agricultural drought and possess the least amount of adaptive capacity. Hence, this study proposes an index that captures both the severity of agricultural drought and the socioeconomic vulnerability of 161 municipalities in Angola. We compute the drought severity (DS) index using root-zone soil moisture (RZSM) data obtained from the Soil Moisture Active Passive (SMAP) satellite (2015-2023) and the U.S. Drought Monitor (USDM) classification system. From 20 socioeconomic vulnerability indicators, we also compute the socioeconomic vulnerability index (SVI) using weights derived from local expert surveys. We then multiply both indices to generate the Socioeconomic Vulnerability-Drought Severity (SV-DS) index. This index will be used to create maps that will show high-risk areas needing immediate action and low-risk areas that can afford to wait. Moreover, we expect further statistical tests to provide insights into significant associations between socioeconomic vulnerability indicators and soil moisture content.

## Overview
```
/results/figures  (most figures used in the presentation and poster are found here)

/scripts
┗ 📜 generate_drought_severity_index.py   (script that automates the computation of the drought severity index for all municipalities given the time range input)
┗ 📜 rzsm_angola.m                       (adapted from Catherine Lu's codebase; processed raw soil moisture data to monthly pixeled drought labels)

/notebooks
┗ 📜 01_data_exploration.ipynb                    (initial exploration of raw data: porosity, root zone soil moisture, and generating data visualizations from them)
┗ 📜 02_drought_severity_index.ipynb              (computing the final drought severity index, and generating relevant maps)
┗ 📜 03_socioeconomic_vulnerability_index.ipynb   (visualizing the socioeconomic vulnerability index including the 6 sub-components)
┗ 📜 04_sv-ds_index.ipynb                         (computing the SV-DS index including further analyses)
┗ 📜 05_data_analysis.ipynb                       (statistical analysis of the socioeconomic indicators and the drought severity index; correlation plots)
```

## Tools Used
The Python GIS packages below are required to run the scripts and the cells in the notebooks.
- rasterio
- geopandas
- cartopy.crs
- shapely
- rasterstats
- jenkspy (used in implementing the Fisher-Jenks Algorithm)

## Notes
`rzsm_angola.m` uses functions found in Catherine's codebase: https://github.com/cat-lu/sm-drought. In order to run this script on MATLAB, you will need to clone their repository.

Feel free to reach out if you have questions or notes on my codebase. Email: edrianpaul.liao@duke.edu
