# Load necessary libraries
library(tidyverse)
library(gt)       # For creating tables
library(ggplot2)  # For creating plots
library(patchwork) # For combining plot and table (optional)
library(writexl)    # For exporting to Excel


# Step 1: Define the data structure
algorithms <- c("PLS", "PCA", "DL", "FA", "FastICA", "KPCA", "IPCA", "SparsePCA", 
                "Truncated SVD", "MDS", "LLE", "Isomap", "SE", "UMAP", "t-SNE", 
                "MiniBatchDL", "MiniBatchSparsePCA")
analytes <- c("DOX", "TYZ")
dataset_types <- c("Calibration", "Test")
metrics <- c("MSE", "MAE", "MedAE", "R2")

# Step 2: Simulate dataset
set.seed(123) # for reproducibility

data <- expand.grid(Algorithm = algorithms, 
                    Analyte = analytes, 
                    DatasetType = dataset_types, 
                    Metric = metrics)

# Random values for each metric, using ranges that are typical for these measures
data$Value <- runif(nrow(data), min = 0, max = 1) 

# Step 3: Perform ranking based on the Value for each combination of Analyte and Metric
data <- data %>%
  group_by(Analyte, Metric, DatasetType) %>%
  mutate(Rank = rank(Value, ties.method = "first"))

# Add a Total Rank by summing up the ranks for each algorithm
total_rank <- data %>%
  group_by(Algorithm) %>%
  summarise(TotalRank = sum(Rank))

# Step 4: Merge total ranks back to the data
data <- data %>%
  left_join(total_rank, by = "Algorithm")

# Step 5: Reshape data into a wide format for the table
table_data <- data %>%
  pivot_wider(names_from = Metric, values_from = c(Value, Rank)) %>%
  arrange(DatasetType, Analyte, Algorithm)

# Step 6: Create a table similar to the original format
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

# Step 7: Save the table as an image
gtsave(table_gt, "Dimension_Reduction_Algorithms_Comparison_Table.png")

# Step 8: Create and save the plot
plot <- ggplot(data, aes(x = Algorithm, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~DatasetType + Analyte) +
  theme_minimal() +
  labs(title = "Comparison of Dimension Reduction Algorithms",
       y = "Metric Value",
       x = "Algorithm") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Make x-axis labels readable

ggsave("Dimension_Reduction_Algorithms_Comparison_Plot.png", plot, width = 12, height = 8)

# Optional: Combine the plot and table (displaying together, but save separately)
table_plot <- table_gt + plot

# Save combined plot and table
ggsave("Dimension_Reduction_Algorithms_Combined.png", table_plot, width = 15, height = 10)

# Step 9: Export the simulated data to Excel
write_xlsx(data, "Dimension_Reduction_Algorithms_Simulated_Data.xlsx")