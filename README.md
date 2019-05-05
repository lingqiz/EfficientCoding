# 2AFC Bayesian Observer with Efficient Coding Constraint 
Fit bayesian efficient coding model (Wei & Stocker 2015) with the method in (Stocker & Simoncelli 2006) to the speed 2AFC dataset in Stocker & Simoncelli 2006.

## Dependencies
You will need Bayesian Adaptive Direct Search [`bads`](https://github.com/lacerbi/bads) OR [`fminsearchbnd`](https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon) to run the fitting procedure efficiently.

## Scripts
`mainOpt.m` Run fits for individual subjects. You will need our dataset to run the fit.  
`fitWeibull.m` Run Weibull fit to individual psychometric curve for each subject.  
`bootstrapAnalysis.m` Run bootstrap Weibull fit.  
`plotFitResults.m` and `plotPsycurves.m` visualize the data and model predictions.  

## Functions
`costfuncWrapperPwr.m` Data likelihood (for 2AFC data) and power law like prior. This function itself acts as a wrapper to `afcCostfunc.m`.
- `afcCostfuncFixedRef.m` Calculate the choice probability based on the distribution of estimates (double integral).
- `efficientEstimator.m` Calculate the distribution of estimates based on efficient coding model.

## Approximation
The implementation here employes various approximation based on Gaussian assumptions to speed things up and increase numerical stability, but might not be suitable for your particular problem. For the vanilla bayesian observer with efficient coding implementation, please refer to: https://github.com/zlqzcc/EfficientCoding/tree/MappingNew.
