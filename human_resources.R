
# import human resources dataset from hdfs
hr_h2o <- h2o.importFile(path = "hdfs:/data/HR/HR_comma_sep.csv", 
                         destination_frame = "hr_h2o")

# split dataset giving the training dataset 75% of the data
hr_h2o_split <- h2o.splitFrame(hr_h2o, ratios = 0.75)

# create a training set from the 1st dataset in the hr_h2o_split
hr_h2o_train <- hr_h2o_split[[1]]
# create a testing set from the 2nd dataset in the hr_h2o_split
hr_h2o_test <- hr_h2o_split[[2]]

# build models including lasso, ridge regression and elastic net
hr_glm <- h2o.glm(x = colnames(hr_h2o_train)[-7], y = "left", training_frame = hr_h2o_train, 
                  family = "binomial", model_id = "glm_hr")

hr_glm_lasso <- h2o.glm(x = colnames(hr_h2o_train)[-7], y = "left", training_frame = hr_h2o_train, 
                        family = "binomial", alpha = 1, lambda_search = TRUE, model_id = "glm_hr_lasso")

hr_glm_ridge <- h2o.glm(x = colnames(hr_h2o_train)[-7], y = "left", training_frame = hr_h2o_train, 
                        family = "binomial", alpha = 0, lambda_search = TRUE, model_id = "glm_hr_ridge")

hr_glm_elastic_net <- h2o.glm(x = colnames(hr_h2o_train)[-7], y = "left", training_frame = hr_h2o_train, 
                              family = "binomial", alpha = 0.5, lambda_search = TRUE, model_id = "glm_hr_elastic_net")


### GLM ###
# predict
h2o.predict(hr_glm, hr_h2o_test)
# performance 
h2o.performance(model = hr_glm, newdata = hr_h2o_test)

### GLM with LASSO ###
# predict
h2o.predict(hr_glm_lasso, hr_h2o_test)
# performance 
h2o.performance(model = hr_glm_lasso, newdata = hr_h2o_test)

### GLM with RIDGE ###
# predict
h2o.predict(hr_glm_ridge, hr_h2o_test)
# performance 
h2o.performance(model = hr_glm_ridge, newdata = hr_h2o_test)

### GLM with ELASTIC NET ###
# predict
h2o.predict(hr_glm_elastic_net, hr_h2o_test)
# performance
h2o.performance(model = hr_glm_elastic_net, newdata = hr_h2o_test)



