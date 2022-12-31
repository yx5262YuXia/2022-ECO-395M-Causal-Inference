# ------------------------------------------------------------------------------
# name: Table_3.R
# author: Yu Xia (UT Austin) revised on scott cunningham (baylor) work on Github
# description: 1st attempt, 1st version, Table 3 in paper
# last updated: May 13, 2022
# ------------------------------------------------------------------------------

options(scipen = 999)
options(digits=3)

texas_out[[7]][[1]] %>%
  kbl(caption = "Statistics Summary",
      format = "latex") %>%
  kable_styling(latex_options = c("striped", "hold_position"))%>%
  
  write_lines(here("Tables/Table_3.tex"))
