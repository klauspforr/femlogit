# femlogit
This repository contains an implementation of a multinomial logistic regression with fixed effects as described by Chamberlain (1980, p. 231) for Stata. The implementation and the files here are described in Pforr (2013, 2014, 2017).

# IMPORTANT NOTE
Stata Corp introduced a streamlined version of the femlogit in Stata 16 (?). Therefore, I strongly recommend to use their implementation, as they worked out most of my known bugs.

# FAQ / known bugs
* The factor variable notation is not implemented, i.e. indicator variables and interaction termns have to be constructed manually. 
* It is by design impossible to estimate effects on the outcome probabilities. Therefore, it is impossible to estimate ordinary marginal effects. You can only estimate odds ratio effects and elasticities. I recommend to use the `lincom` command.
* The ado throws an error if the robust option is specified and the model contains collinear variables which are omitted.
* All technical problems might have been solved with the proper implementation of this model in Stata 17 https://www.stata.com/manuals/xtxtmlogit.pdf.

# References
Chamberlain, G. (1980). Analysis of covariance with qualitative data. The review of economic studies, 47(1), 225-238. https://doi.org/10.2307/2297110

Pforr, K. (2013). femlogit: Implementation und Anwendung der multinominalen logistischen Regression mit" fixed effects". https://doi.org/10.21241/ssoar.37199

Pforr, K. (2014). Femlogit—implementation of the multinomial logit model with fixed effects. The Stata Journal, 14(4), 847-862. https://doi.org/10.1177/1536867X1401400409

Pforr, K. (2017). Detailed description of the implementation the multinomial logit model with fixed effects (femlogit). https://doi.org/10.21241/ssoar.52315
