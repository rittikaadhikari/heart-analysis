# Notes

## Data
- `age` - age in years
- `sex` - 1 = male; 0 = female
- `cp` - chest pain type

- `trestbps` - resting blood pressure (mm Hg)
- `chol` - serum cholesterol (mg/dl)
- `fbs` - fasting blood sugar > 120 mg/dl (1 = true; 0 = false)

- `restecg` - resting electrocardiographic results

- `thalach` - max heart rate achieved
- `exang` - exercise induced angina (1 = yes; 0 = no)
- `oldpeak` - ST depression induced by exercise relative to rest
- `slope` - slope of peak exercise ST segment

- `ca` - # of major vessels colored by flouroscopy

- `thal` - 3 = normal; 6 = fixed defect; 7 = reversable defect

- `num` - presence of heart disease


## Process
1. Read in the data
2. Train-Test split the data
3. Look at the data
4. Feature engineering
5. Fit a model

## TODO
- Change levels of factor variables for better understanding
- Look for "hidden" missing values (i.e. cholesterols of 0)
- Look into negative values of `oldpeak`
- Deal with missing data
- Fit and evaluate models
  - Establish baselines
  - Consider moving to binary response variable
  - Consider re-introducing missing data
  - Consider new modeling techniques
    - Some sort of linear model
    - Random Forest
    - Boosting
  - Start using cross validation
  - Do one SE rule in caret
  - Use different metric in caret
  
## ML Pipeline
- Read in the data
- Train-test split data
- Cross-validate within training data to evaluate many models
  - TODO
  
## ML Systems in R
- `caret`, `tidyverse`, `mlr3`, `h2o`
  
## Comments
- False Negatives (don't diagnose heart disease when you do have heart disease) are likely worse than False Positives (diagnose heart disease when you don't have heart disease)
  - False Negative: can go completely undetected
  - False Positive: unnecessary tests

