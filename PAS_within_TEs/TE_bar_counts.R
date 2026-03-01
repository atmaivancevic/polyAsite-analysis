library(ggplot2)
library(tidyr)
library(dplyr)
# setwd("path/to/your/output/directory")

# Values below are outputs from te_pas_analysis.sbatch
# Update these if running on a different dataset
df_raw <- data.frame(
  class     = c("SINE", "LINE", "LTR", "DNA", "Other"),
  total     = c(1839245, 1715027, 808251, 619205, 35702),
  has_pas   = c(1348792, 1088041, 414715, 350300, 17457),
  expressed = c(3422,    3289,    1530,   1339,   93)
)

df <- df_raw %>%
  pivot_longer(cols = c(total, has_pas, expressed),
               names_to = "metric", values_to = "count") %>%
  mutate(
    metric = recode(metric,
                    total     = "All TEs",
                    has_pas   = "Has PAS",
                    expressed = "Expressed PAS"),
    metric = factor(metric, levels = c("All TEs", "Has PAS", "Expressed PAS")),
    class  = factor(class, levels = c("SINE", "LINE", "LTR", "DNA", "Other"))
  )

ggplot(df, aes(x = class, y = count, fill = metric)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_text(aes(label = scales::comma(count)),
            position = position_dodge(width = 0.7),
            vjust = -0.4, size = 2.2, angle = 45, hjust = 0) +
  scale_y_log10(labels = scales::comma) +
  scale_fill_manual(values = c(
    "All TEs"       = "#b0bec5",
    "Has PAS"       = "#78909c",
    "Expressed PAS" = "#e53935"
  )) +
  labs(title = "TE Classes with Polyadenylation Sites",
       x = "TE class", y = "Count (log scale)", fill = NULL) +
  theme_classic(base_size = 11) +
  theme(plot.title      = element_text(hjust = 0.5, face = "bold"),
        legend.position = "top",
        axis.text.x     = element_text(size = 10)) +
  expand_limits(y = max(df$count) * 5)

ggsave("te_bar_counts.pdf", width = 7, height = 5)
