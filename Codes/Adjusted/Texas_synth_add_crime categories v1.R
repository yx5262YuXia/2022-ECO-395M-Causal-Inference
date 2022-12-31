# ------------------------------------------------------------------------------
# name: Texas_synth_add_crime categories v1.R
# author: Yu Xia (UT Austin) revised on scott cunningham (baylor) work on Github
# description: By using synth code revised in class, look at the effect (of Texas incarceration) in another aspect: crime
# last updated: May 9, 2022
# ------------------------------------------------------------------------------

texas <- read_dta(here("Data/Clean/Texas_add_categories of crime.dta"))%>%
  as.data.frame(.) 

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

dataprep_out <- dataprep(
  foo = texas,
  predictors = c("rvio", "rmurder"),
  predictors.op = "mean", #full average#
  time.predictors.prior = 1985:1993, #Here we start matching.The periods we choose below is decide by prof's investigation. It is out of the scope of this class#
  special.predictors = list(
    list("rcrime", c(1988, 1990:1993), "mean"), #it's better to add lag (1988) to make the (original) model more fit#
    list("alcohol", 1990, "mean"),
    list("aidscapita", 1990:1991, "mean"),
    list("black", 1990:1992, "mean"),
    list("perc1519", 1990, "mean")),
  dependent = "rcrime",
  unit.variable = "statefip",
  unit.names.variable = "state",
  time.variable = "year",
  treatment.identifier = 48,
  controls.identifier = c(1,2,4:6,8:13,15:42,44:47,49:51,53:56),
  time.optimize.ssr = 1985:1993,
  time.plot = 1985:2000
)

synth_out <- synth(data.prep.obj = dataprep_out)

path.plot(synth_out, dataprep_out)

gaps.plot(synth_out, dataprep_out)

placebos <- generate.placebos(dataprep_out, synth_out, Sigf.ipop = 3)

plot_placebos(placebos)

mspe.plot(placebos, discard.extreme = TRUE, mspe.limit = 1, plot.hist = TRUE)
