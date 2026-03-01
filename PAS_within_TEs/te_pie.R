library(ggplot2)
# setwd("path/to/your/output/directory")

# Values below are outputs from te_pas_analysis.sbatch
# Update these if running on a different dataset
total <- 5017430; has_pas <- 3219305; expressed_pas <- 9673
no_pas <- total - has_pas          # 1,798,125
unexpressed <- has_pas - expressed_pas  # 3,209,632

# Inflate red slice to 1% for visibility
disp_exp <- total * 0.01
rem <- total - disp_exp
disp_no  <- rem * (no_pas / (no_pas + unexpressed))
disp_unx <- rem * (unexpressed / (no_pas + unexpressed))

labs <- c("No PAS (n = 1,798,125)", "PAS, unexpressed (n = 3,209,632)", "PAS + expressed (n = 9,673)")
df <- data.frame(
  category = factor(labs, levels = labs),
  display  = c(disp_no, disp_unx, disp_exp),
  pct      = c("35.8%", "64.0%", "0.2%")
)

ggplot(df, aes("", display, fill = category)) +
  geom_col(width = 1, color = "white", linewidth = 0.25) +
  coord_polar(theta = "y") +
  geom_text(aes(label = pct), position = position_stack(vjust = 0.5),
            color = "white", fontface = "bold", size = 3.5) +
  scale_fill_manual(values = c("grey", "#636363", "#e53935"), labels = labs) +
  labs(title   = "TEs with Polyadenylation Sites",
       caption = "Red slice not to scale (increased for visibility)",
       fill    = "Human genome (hg38): 5,017,430 TE loci") +
  theme_void(base_size = 13) +
  theme(plot.title      = element_text(hjust = 0.5, face = "bold", size = 11),
        plot.caption    = element_text(hjust = 0.5, color = "#e53935", size = 9,
                                       face = "italic", margin = margin(t = 10)),
        legend.position = "right",
        legend.title    = element_text(size = 8, color = "grey50"),
        legend.text     = element_text(size = 8),
        plot.margin     = margin(10, 10, 10, 10))

ggsave("te_pie.pdf", width = 5.5, height = 4.5)
