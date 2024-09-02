# Dimension Reduction Algorithms Comparison

### Author: Hamdy Abdel-Shafy
### Date: September 2024
### Affiliation: Department of Animal Production, Cairo University, Faculty of Agriculture

## Overview

This repository contains an R script for comparing various dimension reduction algorithms using simulated data. The script performs the following tasks:

1. **Simulates Data**: Generates random data for different algorithms, analytes, and metrics.
2. **Ranks Algorithms**: Calculates rankings based on performance metrics.
3. **Creates Tables and Plots**: Generates a table and bar plot comparing the algorithms.
4. **Exports Results**: Saves the table and plot as images and exports the data to an Excel file.

## Prerequisites

To run the provided R script, you need the following software:
- [R](https://cran.r-project.org/): A language and environment for statistical computing.
- [RStudio](https://www.rstudio.com/): An integrated development environment (IDE) for R (optional but recommended).

You also need to install the following R packages:
- `tidyverse`
- `gt`
- `ggplot2`
- `patchwork`
- `writexl`

You can install these packages using the following command in R:
```r
install.packages(c("tidyverse", "gt", "ggplot2", "patchwork", "writexl"))
```

## Getting Started

1. **Clone the Repository**

   Clone this repository to your local machine using:
   ```sh
   git clone https://github.com/hamdyabdelshafy/dimension-reduction-comparison.git
   ```

2. **Navigate to the Repository Directory**
   ```sh
   cd dimension-reduction-comparison
   ```

3. **Open the R Script**

   Open `dimension_reduction_comparison.R` in RStudio or your preferred R editor.

4. **Run the Script**

   Source the script in RStudio or run it in your R environment. The script will:
   - Generate simulated data for various dimension reduction algorithms.
   - Create a bar plot comparing the performance of these algorithms.
   - Save the results in an Excel file.
   - Export the plot and table as images.

## Script Breakdown

### 1. Define the Data Structure

The script starts by defining the algorithms, analytes, dataset types, and metrics for the simulation.

```r
algorithms <- c("PLS", "PCA", "DL", "FA", "FastICA", "KPCA", "IPCA", "SparsePCA", 
                "Truncated SVD", "MDS", "LLE", "Isomap", "SE", "UMAP", "t-SNE", 
                "MiniBatchDL", "MiniBatchSparsePCA")
analytes <- c("DOX", "TYZ")
dataset_types <- c("Calibration", "Test")
metrics <- c("MSE", "MAE", "MedAE", "R2")
```

### 2. Simulate Data

The script generates a dataframe with random values for each combination of algorithm, analyte, dataset type, and metric.

```r
set.seed(123) # For reproducibility

data <- expand.grid(Algorithm = algorithms, 
                    Analyte = analytes, 
                    DatasetType = dataset_types, 
                    Metric = metrics)

data$Value <- runif(nrow(data), min = 0, max = 1) # Random values for metrics
```

### 3. Rank Algorithms

It calculates the rank of each algorithm based on the performance metrics and adds a total rank.

```r
data <- data %>%
  group_by(Analyte, Metric, DatasetType) %>%
  mutate(Rank = rank(Value, ties.method = "first"))

total_rank <- data %>%
  group_by(Algorithm) %>%
  summarise(TotalRank = sum(Rank))

data <- data %>%
  left_join(total_rank, by = "Algorithm")
```

### 4. Create a Table and Plot

The script creates a formatted table and a bar plot to visualize the results.

#### Table

```r
table_data <- data %>%
  pivot_wider(names_from = Metric, values_from = c(Value, Rank)) %>%
  arrange(DatasetType, Analyte, Algorithm)

table_gt <- table_data %>%
  gt() %>%
  tab_header(
    title = "Comparison of Dimension Reduction Algorithms",
    subtitle = "Performance metrics and rankings"
  ) %>%
  fmt_number(
    columns = starts_with("Value_"),
    decimals = 3
  ) %>%
  cols_label(
    Value_MSE = "MSE",
    Value_MAE = "MAE",
    Value_MedAE = "MedAE",
    Value_R2 = "R2",
    Rank_MSE = "Rank MSE",
    Rank_MAE = "Rank MAE",
    Rank_MedAE = "Rank MedAE",
    Rank_R2 = "Rank R2",
    TotalRank = "Total Rank"
  ) %>%
  cols_align(
    align = "center",
    columns = everything()
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "lightblue")
    ),
    locations = cells_column_labels()
  )
```

#### Plot

```r
plot <- ggplot(data, aes(x = Algorithm, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~DatasetType + Analyte) +
  theme_minimal() +
  labs(title = "Comparison of Dimension Reduction Algorithms",
       y = "Metric Value",
       x = "Algorithm") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Make x-axis labels readable
```

### 5. Export Results

The script saves the table and plot as images and exports the simulated data to an Excel file.

```r
# Save the table as an image
gtsave(table_gt, "Dimension_Reduction_Algorithms_Comparison_Table.png")

# Save the plot as an image
ggsave("Dimension_Reduction_Algorithms_Comparison_Plot.png", plot, width = 12, height = 8)

# Export the simulated data to Excel
write_xlsx(data, "Dimension_Reduction_Algorithms_Simulated_Data.xlsx")
```

## Files in this Repository

- `dimension_reduction_comparison.R`: The R script containing the code for data simulation, ranking, plotting, and exporting.
- `Dimension_Reduction_Algorithms_Comparison_Table.png`: The saved table image.
- `Dimension_Reduction_Algorithms_Comparison_Plot.png`: The saved plot image.
- `Dimension_Reduction_Algorithms_Simulated_Data.xlsx`: The exported Excel file with simulated data.

## License

This project is licensed under the MIT License - see the [MIT License](LICENSE) file for details.


