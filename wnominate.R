####### W Nominate in R for Data Science Final #######
# Data gathered and code is in Python #
# A. David Jackson $
# Created November 28, 2024 #

setwd('/Users/davidjackson/Desktop/DataScience/Final')
library(extrafont)
library(wnominate)
library(ggplot2)
library(patchwork)
font_import()  # This imports all system fonts, but it may take some time
loadfonts(device = "win")  # For Windows; use "pdf" for PDF outputs, "win" for windows

#rc_votes <- H051_votes

# read in data 
rc_votes <- read.csv("/Users/davidjackson/Desktop/DataScience/Final/delegate_voting_data.csv")

# replace -99 with missing data
rc_votes[rc_votes == -99] <- NA

# change dataframe into a matrix
vote_matrix <- as.matrix(rc_votes)

# transpose matrix to use in w_nominate
transposed_matrix <- t(vote_matrix)

# create the roll call vote matrix
rc_vote_matrix <- rollcall(transposed_matrix,
                           yea=1, 
                           nay=-1, 
                           missing=NA, 
                           notInLegis=0,
                           #legis.names=antonyMatrixNames, 
                           vote.names=NULL,
                           #legis.data=antonyMatrixDelData, 
                           vote.data=NULL,
                           desc=NULL, 
                           source=NULL)

# this runs the nominate using the matrix and has two dimensions
la_wnominate <- wnominate(rc_vote_matrix, polarity=c(21,21))
summary(la_wnominate)

coord_1 <- la_wnominate$legislators$coord1D # pulls the 1st dimension coordinates into an object
coord_2 <- la_wnominate$legislators$coord2D # pulls the 2nd dimension coordiantes into an object
coords_df <- data.frame(Dimension1 = coord_1, Dimension2 = coord_2)

# create a map of the delegate coordinates
ggplot(coords_df, aes(x = Dimension1, y = Dimension2)) +
  geom_point() +  # Plot points
  labs(title = "W-NOMINATE Scores", 
       x = "Dimension 1", 
       y = "Dimension 2") +
  theme_minimal() +  # You can change the theme to suit your preferences
  theme(
    text = element_text(family = "Times New Roman"),  # Set font to Times New Roman
    plot.title = element_text(hjust = 0.5),  # Center title
    axis.title = element_text(size = 12),  # Change axis title font size
    axis.text = element_text(size = 10),  # Change axis tick label font size
    axis.line = element_line(size = .75)  # Make axis lines bold
  )

# export to latex
ggsave("wnominate_plot.png", 
       plot = last_plot(),   # This saves the last plot created
       width = 6,            # Width of the figure in inches
       height = 5,           # Height of the figure in inches
       dpi = 300)            # Resolution (for PNG files)


# these create histograms for the distribution of delegates for dimension one and then two
# then i combine it into a single figure
plot_dim1 <- ggplot(coords_df, aes(x = Dimension1)) + 
  geom_histogram(binwidth = 0.1, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Histogram of Dimension 1",
       x = "Dimension 1",
       y = "Frequency") +
  theme_minimal() +
  theme(
    axis.title = element_text(face = "bold", family = "Times New Roman"),  # Bold axis titles with Times New Roman
    axis.line = element_line(size = 1.2),
    plot.title = element_text(family = "Times New Roman", face = "bold", size = 14),  # Title font
    axis.text = element_text(family = "Times New Roman"),  # Axis labels font
    plot.subtitle = element_text(family = "Times New Roman")  # Subtitle font if used
  )

# histogram for dimension 1
plot_dim2 <- ggplot(coords_df, aes(x = Dimension2)) + 
  geom_histogram(binwidth = 0.1, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Histogram of Dimension 2",  # Fixed title to reflect correct dimension
       x = "Dimension 2", 
       y = "Frequency") +
  theme_minimal() +
  theme(
    axis.title = element_text(face = "bold", family = "Times New Roman"),
    axis.line = element_line(size = 1.2),
    plot.title = element_text(family = "Times New Roman", face = "bold", size = 14),
    axis.text = element_text(family = "Times New Roman"),
    plot.subtitle = element_text(family = "Times New Roman")
  )

# histogram for dimension 2
combined_plot <- plot_dim1 + plot_dim2 + 
  plot_layout(
    widths = c(2, 2)  # Adjust relative widths (default is 1:1 for equal size)
  ) + 
  plot_annotation(
    title = "Histograms of Dimensions 1 and 2",
    theme = theme(
      plot.title = element_text(
        hjust = 0.5,          # Center the title
        size = 16,            # Increase the font size (adjust as needed)
        face = "bold",        # Make the title bold
        family = "Times New Roman"  # Set title font to Times New Roman
      )
    )
  )

# Save the plot with the updated font
ggsave("combined_histograms.png", 
       plot = combined_plot, 
       width = 12,    # Adjust width to fit both plots
       height = 6,    # Adjust height as needed
       dpi = 300)     # High resolution
