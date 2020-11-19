# load packages
library("tidyverse")
library("caret")
library("rpart")
library("rpart.plot")

# read in the data
hd = read_csv("data/hd.csv")
hd$res = ifelse(hd$num != "v0", TRUE, FALSE)

# test-train split data
trn_idx = createDataPartition(hd$num, p = 0.80, list = TRUE)
trn = hd[trn_idx$Resample1,]
tst = hd[-trn_idx$Resample1,]


# feature engineering
trn$num = factor(trn$num)
trn$res = factor(trn$res)
trn$location = factor(trn$location)
trn$cp = factor(trn$cp)
trn$sex = factor(trn$sex)
trn$fbs = factor(trn$fbs)
trn$restecg = factor(trn$restecg)
trn$exang = factor(trn$exang)
trn[which(trn$chol == 0),]$chol = NA

tst$num = factor(tst$num)
tst$res = factor(tst$res)
tst$location = factor(tst$location)
tst$cp = factor(tst$cp)
tst$sex = factor(tst$sex)
tst$fbs = factor(tst$fbs)
tst$restecg = factor(tst$restecg)
tst$exang = factor(tst$exang)
tst[which(tst$chol == 0),]$chol = NA


# function to determine proportion of NAs in a vector
na_prop = function(x) {
  mean(is.na(x))
}


# check proportion of NAs in each column
sapply(trn, na_prop)

# look at data
skimr::skim(trn)


# starting exploratory analysis
plot(trestbps ~ age, trn, pch = 20, col = trn$num)
grid()


# can we fit a model? yes!
rpart(num ~ ., data = trn)


#######################################################################################################
# remove any observation with NA
trn_full = na.omit(trn)


# estimation-validation split of data
set.seed(42)
est_idx = createDataPartition(trn_full$num, p = 0.80, list = TRUE)
est = trn_full[est_idx$Resample1, ]
val = trn_full[-est_idx$Resample1, ]


# looking at response in estimation data
table(est$num)


# what happens if we always say no?
table(
  actual = val$num,
  predicted = factor(rep("v0", length(val$num), levels=levels(val$num)))
)


# fit first model
mod = rpart(num ~ ., data = est)
rpart.plot(mod)


# model baseline
table(
  actual = val$num,
  predicted = predict(mod, val, type = "class")
)


# calculate baseline accuracy
mean(predict(mod, val, type = "class") == val$num)


#######################################################################################################
# remove any observation with NA
trn_full = na.omit(trn)


# classification
cv_5 = trainControl(method = "cv", number = 5)
tree_mod = train(form = num ~ ., data = trn_full, method = "rpart", trControl = cv_5) # good
knn_mod = train(form = num ~ ., data = trn_full, method = "knn", trControl = cv_5)
gbm_mod = train(form = num ~ ., data = trn_full, method = "gbm", trControl = cv_5) # good


#######################################################################################################
# remove any observation with NA
trn_full = na.omit(trn)
trn_full = subset(trn_full, select = -c(num))


# binary response
cv_5 = trainControl(method = "cv", number = 5)
tree_mod = train(form = res ~ ., data = trn_full, method = "rpart", trControl = cv_5) # good
gbm_mod = train(form = res ~ ., data = trn_full, method = "gbm", trControl = cv_5) # good


#######################################################################################################
# modify dataset without columns containing more than 33% NAs
# Note: trn$fbs has a significant number of NAs -- keep in mind that most data points are no
trn_omit = na.omit(trn[, !sapply(trn, na_prop) > 0.33])
trn_omit = subset(trn_omit, select = -c(num))


# binary response
cv_5 = trainControl(method = "cv", number = 5)
tree_mod = train(form = res ~ ., data = trn_omit, method = "rpart", trControl = cv_5) # good
gbm_mod = train(form = res ~ ., data = trn_omit, method = "gbm", trControl = cv_5) # good


#######################################################################################################
# modify dataset without columns containing more than 33% NAs
# Note: trn$fbs has a significant number of NAs -- keep in mind that most data points are no
trn_omit = na.omit(trn[, !sapply(trn, na_prop) > 0.33])
trn_omit = subset(trn_omit, select = -c(num))


# estimation-validation split of data
set.seed(42)
est_idx = createDataPartition(trn_omit$res, p = 0.80, list = TRUE)
est = trn_omit[est_idx$Resample1, ]
val = trn_omit[-est_idx$Resample1, ]

# binary response
cv_5 = trainControl(method = "cv", number = 5)
gbm_mod = train(form = res ~ ., data = est, method = "gbm", trControl = cv_5) # good


# calculate validation accuracy
print(mean(predict(gbm_mod, val, type = "raw") == val$res))


# train on full train set
gbm_mod_official = train(form = res ~ ., data = trn_omit, method = "gbm", trControl = cv_5) # good


# omit in tst data as well
tst_omit = na.omit(tst[, !sapply(tst, na_prop) > 0.33])
tst_omit = subset(tst_omit, select = -c(num))


# calculate test accuracy
preds = predict(gbm_mod_official, newdata = tst_omit, type = "raw")
print(mean(preds == tst_omit$res))


# confusion matrix
confusionMatrix(preds, tst_omit$res)
