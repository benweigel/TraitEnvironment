#' ---
#' title: "Introduction to Double Constrained Correspondance Analysis"
#' author: "Frelat, R."
#' date: "7th June 2021"
#' output:
#'   html_document: default
#'   word_document: default
#'   pdf_document: default
#' ---
#' 
## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
#' This document provides an introduction to double constrained correspondence analysis (DC-CA). The tutorial targets students and scientists in ecology with previous knowledge of the [R software](https://cran.r-project.org/). 
#' 
#' This tutorial is greatly inspired from the [tutorial by ter Braak C.J.F. et al. 2016](https://ars.els-cdn.com/content/image/1-s2.0-S0048969720357004-mmc4.pdf). Please read the original publication for more details about the double constrained correspondence analysis analysis [DOI 10.1016/j.scitotenv.2020.142171](https://doi.org/10.1016/j.scitotenv.2020.142171)
#' 
#' The example dataset is available for download [here ( NEAtl_FishTraitEnv.Rdata)](https://github.com/rfrelat/TraitEnvironment/raw/main/NEAtl_FishTraitEnv.Rdata) and the script [here (DCCA_FishTraitEnv.R)](https://github.com/rfrelat/TraitEnvironment/raw/main/DCCA_FishTraitEnv.R)
#' 
#' 
#' 
#' # 0. Preliminaries
#' 
#' ### Load packages and dataset
#' 
#' The DC-CA analyses require the R packages [ade4 (v ≥ 1.7.16)](https://pbil.univ-lyon1.fr/ade4/home.php?lang=eng).
#' 
## ---- message=FALSE--------------------------------------------------------------------------------------------------------------------
library(ade4)

#' 
#' To plot maps with country border, you also need the packages `ggplot2 (v ≥ 3.3)`.
#' 
## ---- message=FALSE--------------------------------------------------------------------------------------------------------------------
library(ggplot2)

#' 
#' If you get an error message, check that the R packages are installed correctly. If not, use the command: `install.packages(c("ade4", "ggplot2"))`.
#' 
#' The example dataset is available as the Rdata file `NorthSea_FishTraitEnv.Rdata`, available for download [here](https://github.com/rfrelat/TraitEnvironment/raw/main/NorthSea_FishTraitEnv.Rdata).  
#' 
#' ### Load the example dataset
#' 
#' Make sure the file `NorthSea_FishTraitEnv.Rdata` is in your working directory, then load it in R.
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
load("NEAtl_FishTraitEnv.Rdata")

#' 
#' The Rdata file contains four objects: 
#' 
#' - `abu` containing the abundance of taxa in grid cells
#' - `env` containing the environmental condition per grid cell
#' - `trait` containing the trait information per taxa 
#' - `coo`: the coordinates of each grid cell
#' 
#' Importantly, the rows in `abu` correspond to the same grid cell than the rows in `env`, and the column in `abu` correspond to the same taxa than the rows in `trait`.  
## --------------------------------------------------------------------------------------------------------------------------------------
all(row.names(abu)==row.names(env))
all(colnames(abu)==row.names(trait))

#' 
#' If you want to learn how to create such dataset, see the short [tutorial on setting trait-environement dataset](https://rfrelat.github.io/CleanDataTER.html).  
#' 
#' Using the fish community of the Northeast Atlantic as an example, we will **explore the trait-environment relationship using the DC-CA analysis**.
#' 
#' ### Quick summary of the variables
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
dim(trait)
names(trait)

#' 
#' The `trait` table contains `r ncol(trait)`  traits (i.e variable, in column) characterizing `r nrow(trait)` taxa (in rows). The `r ncol(trait)` traits broadly represent the life history and ecology of fish in terms of their feeding, growth, survival and reproduction. These are:  
#' 
#' - Trophic level
#' - K: the growth rate, calculated as Von Bertalanffy growth coefficient in year$^{-1}$
#' - Lmax: maximum body length in cm
#' - Lifespan
#' - Offspring.size_log: egg diameter, length of egg case or length of pup in mm
#' - Fecundity_log: number of offspring produced by a female per year
#' - Age.maturity: in years
#' 
#' Trait values for fecundity and offspring size were log-transformed to reduce the influence of outliers. 
#' 
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
dim(env)
names(env)

#' 
#' The `env` table contains `r ncol(env)`  environmental variables (in column) characterizing `r nrow(env)` grid cells (in rows). The environmental variables measure hydrography, habitat, food availability and anthropogenic pressures, which are known to affect the distribution of fish species. These are:  
#' 
#' - Depth: depth in meter, directly measured during the survey.
#' - SBT: monthly sea bottom temperature in °C from the Global Ocean Physics Reanalysis (GLORYSs2v4) 
#' - SBS: monthly sea bottom salinity from the Global Ocean Physics Reanalysis (GLORYSs2v4) 
#' - Chl: Chlorophyll a concentration (in $mg.m^{-3}$) as a proxy for primary production and food availability from the GlobColour database
#' - SBT_sea: seasonality of sea bottom temperature, calculated as the difference between the warmest and the coldest month of the year.
#' - Chl_sea: seasonality of chlorophyll a concentration, calculated as the difference between the highest and the lowest primary production in the year
#' - Fishing: the cumulative demersal fishing pressure in 2013, estimated globally by Halpern et al. 2015, [DOI 10.1038/ncomms8615](https://doi.org/10.1038/ncomms8615). 
#' 
#' 
#' # 1. Fast DC-CA based on single SVD algorithm
#' 
#' 
#' ## 1.2 Run DC-CA
#' 
#' In this first step, we use DC-CA based on single SVD algorithm. We need to set the scaling factor `alpha`, which can vary between 0 if focusing on species, or 1 if focusing on sites. We chose a balanced scaling of `alpha=0.5`.
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
#alpha <- 0 # focus on species
#alpha <- 1 # focus on samples
alpha <- 0.5 # compromise scaling

dccaF<- dcCA(abu, env, trait, alpha=alpha)

#' 
#' As with RLQ analysis, the DCCA provide scores for species, sites, traits and environmental variables.
#' 
#' The eigen values are stored as `lambda` and the fourth corner correlation in `rho`.
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# dc-CA eigen values
dccaF$lambda

# fourth corner correlation
dccaF$rho

# Explained variance (cum)
round(cumsum(dccaF$lambda)*100,1)

# Explained fitted variation (cum.)
round(cumsum(dccaF$lambda)/sum(dccaF$lambda)*100, 1)

#' The first axis explains `r round(dccaF$lambda[1]/sum(dccaF$lambda)*100)`% of covariance. In the next step, we will  interpret the scores of the two first axis (but similar visualization could be carried out for subsequent axis).
#' 
#' ## 1.2 Trait scores
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
#Plot traits score
t1 <- order(dccaF$C1[,1])
dotchart(dccaF$C1[t1,1], pch=16, 
         labels = names(trait)[t1],
         main="PC1")
abline(v=0, lty=2)

#' 
#' 
#' ## 1.3 Species scores
#' Due to the high number of species (```nrow(trait)```), it is hard to visualize the score of each individual species. But we can see the species with highest and lowest score on PC1.
## --------------------------------------------------------------------------------------------------------------------------------------
# top 10 species with positive score
top10 <- order(dccaF$U[,1], decreasing = TRUE)[1:10]
cbind(colnames(abu), dccaF$U[,1])[top10,]

# top 10 species with negative score
top10 <- order(dccaF$U[,1])[1:10]
cbind(colnames(abu), dccaF$U[,1])[top10,]

#' 
#' ## 1.4 Environmental scores
## --------------------------------------------------------------------------------------------------------------------------------------
#Plot environment score
e1 <- order(dccaF$B1[,1])
dotchart(dccaF$B1[e1,1], pch=16,
         labels = names(env)[e1])
abline(v=0, lty=2)

#' 
#' ## 1.5 Sites scores
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# Choice of diverging color scale
colpal <- terrain.colors(7)[-7]
# or from RColorBrewer package
# colpal <- rev(RColorBrewer::brewer.pal(6,"RdYlBu")) 

mapggplot(coo[,1], coo[,2], dccaF$X[,1], 
          colpal, main="PC1")

#' 
#' ## 1.6 Second axis
#' 
#' In fact PC2 also explain a large proportion of the variance too (`r round(dccaF$lambda[1]/sum(dccaF$lambda)*100)`%). So let's have a quick look at its interpretation.
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
par(mfrow=c(1,2))
t2 <- order(dccaF$C1[,2])
dotchart(dccaF$C1[t2,2], pch=16, 
         labels = names(trait)[t2])
abline(v=0, lty=2)

e2 <- order(dccaF$B1[,2])
dotchart(dccaF$B1[e2,2], pch=16,
         labels = names(env)[e2])
abline(v=0, lty=2)

mapggplot(coo[,1], coo[,2], dccaF$X[,2], 
          colpal, main="PC2")

#' 
#' # 2. Stepwize analysis 
#' 
#' DC-CA is computed in 4 steps:
#' 
#' 1. CCA(Y ~ Env)
#' 2. Weighted RDA(S*~Traits)
#' 3. CCA(t(Y) ~Traits)
#' 4. Weighted RDA(R*~Env)
#' 
#' 
#' ### 2.1. CCA of the community table on to the environmental variables
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
#step 1. CCA(Y ~ Env)
CA_on_Abun <- dudi.coa(abu, scannf = F)
Step1_CCA_on_env <- pcaiv(CA_on_Abun, env, scannf = F, nf = ncol(env)) # CCA1

S_star <- Step1_CCA_on_env$co

dim(S_star)
q_star <- ncol(S_star)
p_star <- qr(model.matrix(~ as.matrix(trait)))$rank-1

#' 
#' From this analysis, we obtain an m × q* table of scores (called S* ) with q* the rank of the environmental data(=number of environmental variables if they are of full rank). By definition, S* contains species-niche centroids (SNC) with respect to orthonormalized environmental variables.
#' 
#' #### Summary of Step 1: CCA(Y ~ Env)  
#' 
#' Eigenvalues of CCA of abundance table on Env (canonical eigenvalues)
## --------------------------------------------------------------------------------------------------------------------------------------
# the eigenvalues of CCA of Y on Env (canonical eigenvalues)
Exp_var_by_Env <- sum(Step1_CCA_on_env$eig)/sum(CA_on_Abun$eig)
# % variation in the abundance values
#   explained by the environmental variables
Exp_var_by_Env

#' 
#' Percent variation in abundances explained by the Environmental variables
## --------------------------------------------------------------------------------------------------------------------------------------
#R2 =
round(100*Exp_var_by_Env,2)

# adjusted R2
Step1_adjR2 <- adj_R2(cumsum(Step1_CCA_on_env$eig)/sum(CA_on_Abun$eig), 
                      n = nrow(env), df = Step1_CCA_on_env$rank)
names(Step1_adjR2)<- paste("Axis", seq_len(Step1_CCA_on_env$rank))

#adj R2 =
round(100* adj_R2(Exp_var_by_Env, n = nrow(env), df = Step1_CCA_on_env$rank),2)

#' 
#' Cumulatively across axes
## --------------------------------------------------------------------------------------------------------------------------------------
round(100* Step1_adjR2,2)

#' 
#' 
#' ### 2.2. an RDA of S* on the trait variables using species weights 
#' 
#' step 2. Weighted RDA(S* ~Traits): an RDA of S* on the trait variables, using species weights K = colSums(Y) or K/sum(K), given by Step1_CCA_on_env$cw
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# weighted RDA(S*~Traits):
pca_S_star <- dudi.pca(S_star, row.w = Step1_CCA_on_env$cw, 
                       scale = FALSE, scannf = FALSE, nf = ncol(S_star))
Step2_wrRDA_SNC_on_Traits <- pcaiv(pca_S_star, trait, scannf = FALSE, 
                                   nf = ncol(trait)) 

#' 
#' It is of interest to express these eigenvalues as fraction of the environmentally structured variation which was obtained in step 1. 
#' The fraction of environmentally structured variation explained by the traits is 
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
R2_Env_variation_explained_by_Traits <- sum(Step2_wrRDA_SNC_on_Traits$eig)/sum(Step1_CCA_on_env$eig)
R2_Env_variation_explained_by_Traits

# per axis
Fraction_env_structured_variation_explained_by_traits <- cumsum(Step2_wrRDA_SNC_on_Traits$eig)/sum(Step1_CCA_on_env$eig) # 
names_axes <- paste("Axis",seq_along(Step2_wrRDA_SNC_on_Traits$eig))
names(Fraction_env_structured_variation_explained_by_traits)<- names_axes
Fraction_env_structured_variation_explained_by_traits

#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# Species-level significance test
nrepet <- 999  # number of permutations in tests
Species_level_test <- randtest(Step2_wrRDA_SNC_on_Traits, nrepet = nrepet)
Species_level_test
p_value_species_level_test <- Species_level_test$pvalue

#' 
#' Traits and species plots
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
plot(Step2_wrRDA_SNC_on_Traits)

# Step1_CCA_on_env$li
# Step2_wrRDA_SNC_on_Traits

#' 
#' #### Summary of Step 2: weighted RDA(SNC~Traits
#' Environmentally structured variation explained by traits
## --------------------------------------------------------------------------------------------------------------------------------------
#R2 =
round(100*R2_Env_variation_explained_by_Traits,1)
#adj R2 =
round(100* adj_R2(R2_Env_variation_explained_by_Traits, n = nrow(S_star), df = p_star),2)

#' 
#' Cumulatively across axes
## --------------------------------------------------------------------------------------------------------------------------------------
adpa1 <- adj_R2(Fraction_env_structured_variation_explained_by_traits, n = nrow(S_star), df = p_star)
names(adpa1)<- names_axes
round(100* adpa1,2)

#' 
#' Ratio of double (T,E) vs single (E) constrained eigenvalues (efficiency of the traits to explain  the environmentally structured variation) 
## --------------------------------------------------------------------------------------------------------------------------------------
# Trait efficiencies of environmentally structured variation: 
# expressing how well do the traits explain the environmentally structured variation
eff1 <- Step2_wrRDA_SNC_on_Traits$eig/Step1_CCA_on_env$eig[seq_along(Step2_wrRDA_SNC_on_Traits$eig)]
names(eff1)<- names_axes
print(round(eff1,2))

#' P-value of the species-level test in dc-CA
## --------------------------------------------------------------------------------------------------------------------------------------
p_value_species_level_test

#' 
#' 
#' ### 2.3 CCA of the transposed community table on to the traits
#' 
#' Step 3. CCA(t(Y) ~Traits): a CCA of the transposed community table on to the traits
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# the standard way of doing a CCA in ade4: 
CA_on_Abun.t <- dudi.coa(t(abu), scannf = F)
Step3_CCA_on_traits <- pcaiv(CA_on_Abun.t, trait, scannf = F, nf = ncol(trait))

# the CCA eigenvalues (canonical eigenvalues)
Step3_CCA_on_traits$eig

R_star <- Step3_CCA_on_traits$co
dim(R_star) 

# p_star <- qr(model.matrix(~ as.matrix(trait)))$rank-1

#' 
#' We obtain from this analysis an n × p* table of scores (called R* ) with p* the rank of the trait data (=number of traits if traits are of full rank). By definition, R* contains community-weighted means (CWM) with respect to orthonormalized trait variables. 
#' 
#' #### Summary of Step 3: CCA(t(Y) ~ Traits)
#' 
#' Eigenvalues of CCA of the transposed abundance table on to the traits (canonical eigenvalues)
## --------------------------------------------------------------------------------------------------------------------------------------
round(Step3_CCA_on_traits$eig,3)

#' 
#' Percent variation in abundances explained by the traits
## --------------------------------------------------------------------------------------------------------------------------------------
Exp_var_by_Traits <- sum(Step3_CCA_on_traits$eig)/sum(CA_on_Abun.t$eig)
# % variation in the abundance values
#   explained by the traits
round(100*Exp_var_by_Traits,2)

#' 
## --------------------------------------------------------------------------------------------------------------------------------------
Step3_adjR2 <- adj_R2(cumsum(Step3_CCA_on_traits$eig)/sum(CA_on_Abun$eig), 
                      n = nrow(trait), df = Step3_CCA_on_traits$rank)
names(Step3_adjR2)<- paste("Axis", seq_len(Step3_CCA_on_traits$rank))
    
# adjR2 =
round(100* adj_R2(Exp_var_by_Traits, n = nrow(trait), df = Step3_CCA_on_traits$rank),2)
# Cumulatively across axes:
print(round(100* Step3_adjR2,2))

#' 
#' ### 2.4. RDA of R* on the environmental variables
#' 
#' Step 4. Weighted RDA(R* ~Env): an RDA of R* on the environmental variables, using sample weights R = rowSums(Y) or R/sum(R), given by Step1_CCA_on_env$lw.
## --------------------------------------------------------------------------------------------------------------------------------------
# weighted RDA(R*~Env)
pca_R_star <- dudi.pca(R_star, row.w = Step1_CCA_on_env$lw, scale = FALSE, 
                       scannf = FALSE, nf = ncol(R_star))
Step4_wRDA_CWM_on_Env <- pcaiv(pca_R_star, env, scannf = FALSE, 
                               nf = ncol(env)) 


#' 
#' Note that the eigenvalues of this weighted RDA are equal to the dc-CA eigenvalues
## --------------------------------------------------------------------------------------------------------------------------------------
abs(Step4_wRDA_CWM_on_Env$eig - Step2_wrRDA_SNC_on_Traits$eig)<1.e-12

eig24 <- rbind(Step2_wrRDA_SNC_on_Traits$eig, Step4_wRDA_CWM_on_Env$eig)
rownames(eig24) <- paste("eigenvalues step ", c(2,4))
colnames(eig24) <- names_axes


#' 
#' It is of interest to express these eigenvalues as fraction of the trait structured variation which was obtained in step 3. The fraction of trait-structured variation explained by the environmental variables is thus
#' 
## --------------------------------------------------------------------------------------------------------------------------------------
Step4_wRDA_CWM_on_Env$eig/sum(Step3_CCA_on_traits$eig) # 

R2_Trait_variation_explained_by_Env <- sum(Step4_wRDA_CWM_on_Env$eig)/sum(Step3_CCA_on_traits$eig)
# expressed as percentage
round(100*R2_Trait_variation_explained_by_Env,1)

Fraction_trait_structured_variation_explained_by_env <- cumsum(Step4_wRDA_CWM_on_Env$eig)/sum(Step3_CCA_on_traits$eig) # 
names(Fraction_trait_structured_variation_explained_by_env)<- names_axes
Fraction_trait_structured_variation_explained_by_env

#' 
## --------------------------------------------------------------------------------------------------------------------------------------
# sample-level test
Sample_level_test <- randtest(Step4_wRDA_CWM_on_Env, nrepet = nrepet)
Sample_level_test
p_value_sample_level_test <- Sample_level_test$pvalue

#' 
#' Environmental variables and sample plots:
## --------------------------------------------------------------------------------------------------------------------------------------
plot(Step4_wRDA_CWM_on_Env)

#' 
#' 
#' #### Summary of Step 4: weighted RDA(CWM~Env) 
#' 
#' dc-CA eigenvalues obtained in step 2 and 4 are equal\n (and equal to those of the single SVD)
## --------------------------------------------------------------------------------------------------------------------------------------
eig24

#' 
#' Fourth-corner correlations between the dc-CA sample and species axes
## --------------------------------------------------------------------------------------------------------------------------------------
sqrt(eig24[1,])

#' 
#' Trait-structured variation explained by the environmental variables
## --------------------------------------------------------------------------------------------------------------------------------------
# R2=
round(100*R2_Trait_variation_explained_by_Env,1)
# adj R2 =
round(100* adj_R2(R2_Trait_variation_explained_by_Env, n = nrow(R_star), df = q_star),2)

# Cumulatively across axes:
adpa2 <- adj_R2(Fraction_trait_structured_variation_explained_by_env, n = nrow(R_star), df = q_star)
names(adpa2)<- names_axes
round(100* adpa2,2)

#' 
#' Environmental efficiencies of trait-structured variation: expressing how well do the environmental variable explain the trait structured variation.
#' 
#' Ratio of double (T,E) vs single (T) constrained eigenvalues (efficiency of the environmental variables to explain  the trait-structured variation)
## --------------------------------------------------------------------------------------------------------------------------------------
eff2 <- Step4_wRDA_CWM_on_Env$eig/Step3_CCA_on_traits$eig[seq_along(Step4_wRDA_CWM_on_Env$eig)]
names(eff2)<-names_axes
round(eff2,2)

#' 
#' P-value of the sample-level test in dc-CA
## --------------------------------------------------------------------------------------------------------------------------------------
p_value_sample_level_test

#' 
#' 
#' 
#' ### 2.5 Summary of the DC-CA
## --------------------------------------------------------------------------------------------------------------------------------------

eig <- Step2_wrRDA_SNC_on_Traits$eig
rFC <- sqrt(eig)
Chessels_correlation_ratio <- sqrt(Step2_wrRDA_SNC_on_Traits$eig/CA_on_Abun$eig[seq_along(Step2_wrRDA_SNC_on_Traits$eig)])
Explained_variance =  cumsum(Step2_wrRDA_SNC_on_Traits$eig)/sum(CA_on_Abun$eig)
Explained_fitted_variation_cumulative <- cumsum(Step2_wrRDA_SNC_on_Traits$eig)/sum(Step2_wrRDA_SNC_on_Traits$eig)
# final p-value
# p_max : maximum of p-values of the sample-level test and species-level test
p_max_dcCA <- max(c(p_value_sample_level_test, p_value_species_level_test))


summary_dcCA <- rbind(eig, rFC, Chessels_correlation_ratio,100*Explained_variance,100*Explained_fitted_variation_cumulative,
                      100*adpa2,100*adpa1,eff2,eff1,Chessels_correlation_ratio^2)
rownames(summary_dcCA) <- c(" 1 dc-CA eigenvalues"," 2 fourth-corner correlations (rFC)", " 3 Chessel's correlation ratio",
                            " 4 % Explained variance (cum.)", " 5 % Explained fitted variation (cum.)",
                            " 6 % CWM variation expl. by E (adj R2)",
                            " 7 % SNC variation expl. by T (adj R2)",
                            " 8 Efficiency of extra E constraint",
                            " 9 Efficiency of extra T constraint",
                            "10 Efficiency of (T,E) vs no constraint")

summary_dcCA[,1:3]



#' 
#' P-value of dc-CA test: `r p_max_dcCA` (max test:maximum of p-values of the sample-level test and species-level test). Notes:  
#' 
#' 1: dc-CA eigenvalues are between 0 and 1
#' 2: rFC between constrained sample and species scores
#' 3: Chessel's fourth-corner correlation or 2 expressed as ratio of maximum (sqrt of CA-eigenvalues)
#' 4: 1 expressed as percentage of the total inertia (weighted variance)
#' 5: 1 expressed as percentage of the total explained inertia
#' 6: Trait-structured variation (CWMs wrt orthonormal traits) explained by the environmental variables
#' 7: Environmentally structured variation (SNCs wrt orthonormal env vars) explained by traits
#' 8: Ratio of double (T,E) vs single (T) constrained eigenvalues (efficiency of the environmental variables to explain the trait-structured variation)
#' 9: Ratio of double (T,E) vs single (E) constrained eigenvalues (efficiency of the traits to explain the environmentally structured variation)
#' 10: Ratio of double (T,E) vs unconstrained (CA) eigenvalues (efficiency of the trait and environmental variables to explain the abundance table; it is the squared Chessels's correlation ratio
#'   
#' From the single constrained (CCA) analyses:
#' Variation in abundance table (adjusted R2) explained by :
#' 
#' - the environmental variables : `r round(100* adj_R2(Exp_var_by_Env, n = nrow(env), df =Step1_CCA_on_env$rank),2)`
#' - traits: `r round(100* adj_R2(Exp_var_by_Traits, n = nrow(trait), df = Step3_CCA_on_traits$rank),2)`
#'   
#' 
#' Note 1: In the above ade4-plots 
#' *Loadings* are canonical weights or coefficients that define the species and sample axes of dc-CA.  
#' *Correlations* are biplot coefficients of the fourth-corner correlations (in compromise scaling)
#' Note 2: Because d=0.5 in the traits and environment *Correlations* plots they form a biplot of the fourth-corner correlations between the traits and the environmental variables.
#' Note 3: In wRDA(CWM~Env), CWM is with respect to orthonormalized traits  
#' Note 4: In wRDA(SNC~Traits), SNC is with respect to orthonormalized environmental variables.
#' 
#' # References
#' 
#' Peng, F. J., Ter Braak, C. J., Rico, A., & Van den Brink, P. J. (2021). Double constrained ordination for assessing biological trait responses to multiple stressors: A case study with benthic macroinvertebrate communities. Science of the Total Environment, 754, 142171.
#' 
#' 
