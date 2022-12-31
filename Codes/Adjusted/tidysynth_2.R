# ------------------------------------------------------------------------------
# name: tidysynth_2.R
# author: drop some variable used by Cunningham, 2nd attempt of synth
# description: synth 2nd attempt
# last updated: May 11, 2022
# ------------------------------------------------------------------------------

texas <- read_dta(here("Data/Clean/Texas_add_categories of crime.dta"))%>%
  as.data.frame(.) 

texas$crime <- texas$murder + texas$rape + texas$assault + texas$rob + texas$auto + texas$burg +texas$larc

texas <- texas %>%
  mutate(crime_rate=crime/pop,
         rmurder=murder/pop,
         rrape=rape/pop,
         rass=assault/pop,
         rrob=rob/pop,
         rauto=auto/pop,
         rburg=burg/pop,
         rlarc=larc/pop,
         rvio=vio/pop,
         lrcrime=log(crime_rate),
         lmur=log(rmurder),
         lrob=log(rrob),
         lrvio=log(rvio))

texas_out <-
  
  texas %>%
  
  # initial the synthetic control object
  synthetic_control(outcome = crime_rate, # outcome
                    unit = state, # unit index in the panel data
                    time = year, # time index in the panel data
                    i_unit = "Texas", # unit where the intervention occurred
                    i_time = 1993, # time period when the intervention occurred
                    generate_placebos=T # generate placebo synthetic controls (for inference)
  ) %>%
  
  # Generate the aggregate predictors used to fit the weights
  
  # average log income, retail price of cigarettes, and proportion of the
  # population between 15 and 24 years of age from 1980 - 1988
  generate_predictor(time_window = 1985:1993,
                     av_rvio = mean(rvio, na.rm = T),
                     av_murder = mean(rmurder, na.rm = T)) %>%
  
  # average beer consumption in the donor pool from 1984 - 1988
  generate_predictor(time_window = 1990:1992,
                     av_rcrime = mean(crime_rate, na.rm = T)) %>%
  
  generate_predictor(time_window = 1990,
                     av_alcohol = mean(alcohol, na.rm = T)) %>%
  generate_predictor(time_window = 1990:1991,
                     av_aidscapita = mean(aidscapita, na.rm = T)) %>% 
  
  # Lagged cigarette sales 
  generate_predictor(time_window = 1988,
                     rcrime_1988 = crime_rate) %>%
  
  
  
  # Generate the fitted weights for the synthetic control
  generate_weights(optimization_window = 1985:1993, # time to use in the optimization task
                   margin_ipop = .02,sigf_ipop = 7,bound_ipop = 6 # optimizer options
  ) %>%
  
  # Generate the synthetic control
  generate_control()

texas_out %>% plot_trends()

texas_out %>% plot_differences()

texas_out %>% plot_weights()

texas_out %>% grab_balance_table()

texas_out %>% plot_placebos()

texas_out %>% plot_placebos(prune = FALSE)

