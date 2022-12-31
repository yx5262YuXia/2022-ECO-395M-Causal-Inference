library(haven)
library(fixest)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(kableExtra)
library(here)
library(stats)
library(rlang)
library(ggthemes)
library(janitor)
library(magrittr)
library(glue)
library(lubridate)
library(haven)
library(snakecase)
library(sandwich)
library(lmtest)
library(gganimate)
library(gapminder)
library(stargazer)
library(snakecase)

texas <- read_dta(here("Data/Clean/Texas_add_categories of crime.dta"))

texas$crime <- texas$murder + texas$rape + texas$assault + texas$rob + texas$auto + texas$burg +texas$larc

texas <- texas %>%
  mutate(rcrime=crime/pop,
         rmurder=murder/pop,
         rrape=rape/pop,
         rass=assault/pop,
         rrob=rob/pop,
         rauto=auto/pop,
         rburg=burg/pop,
         rlarc=larc/pop,
         rvio=vio/pop,
         lrcrime=log(rcrime),
         lmur=log(rmurder),
         lrob=log(rrob),
         lrvio=log(rvio))

options(scipen = 999)
options(digits=3)

texas_sumstats <- texas %>%
  summarize(across(
    c(rcrime, income, poverty, ur, pop),
    list(
      "N. Obs" = length,
      "Mean" = mean,
      "Std. Dev" = sd
    )
  )) %>%
  pivot_longer(
    cols = everything(),
    names_sep = "_",
    names_to = c("Variable", ".value")
  )

translation_table <- tribble(
  ~short_name, ~long_name,
  "rcrime", "Crime Rate",
  "income", "Income", 
  "poverty", "Poverty Rate",
  "ur", "Unemployment Rate",
  "pop","Population",
)

renamed_table <-
  texas_sumstats %>%
  left_join(translation_table, c("Variable" = "short_name")) %>%
  mutate(Variable = coalesce(long_name, Variable)) %>%
  select(-long_name)

renamed_table %>%
  kbl(caption = "Statistics Summary",
      format = "latex") %>%
  kable_styling(latex_options = c("striped", "hold_position"))%>%
  
  write_lines(here("Tables/Table_1.tex"))
