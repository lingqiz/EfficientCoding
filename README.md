# 2AFC Bayesian Observer with Efficient Coding Constraint 
Fit bayesian efficient coding model (Wei & Stocker 2015) with the method in (Stocker & Simoncelli 2006) to the speed 2AFC dataset in Stocker & Simoncelli 2006.

## Dependencies
You will need Bayesian Adaptive Direct Search [`bads`](https://github.com/lacerbi/bads) OR [`fminsearchbnd`](https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon) to run the fitting procedure efficiently.

## Scripts
`mainOpt.m` Run fits for individual subjects. You will need our dataset to run the fit.
`mainBootstrap.m` Run bootstrap fit on combined subject.  
`mainSubjects.m` Run fit on individual subjects separately and plot the results.  
`plotSubjectFit.m` (Load in best fit parameter) Generate the result figure for each subject (with scatter plot of raw data). 

## Scripts
`main.m` Run fit on combined subject and plot the results.  
`fitWeibull.m` Run Weibull fit to individual psychometric curve for each subject.
`bootstrapAnalysis.m` Run bootstrap Weibull fit.
`plotFitResults.m` and `plotPsycurves.m` visualize the data and model predictions.

## Functions
`costfuncWrapperPwr.m` Data likelihood (for 2AFC data) and power law like prior. This function itself acts as a wrapper to `afcCostfunc`.
- `afcCostfuncFixedRef.m` Calculate the choice probability based on the distribution of estimates (double integral).
- `efficientEstimator.m` Calculate the distribution of estimates based on efficient coding model.
