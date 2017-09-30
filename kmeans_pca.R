#Data Set Information:
#These data are the results of a chemical analysis of wines grown 
#in the same region in Italy but derived from three different cultivars. 
#The analysis determined the quantities of 13 constituents found in each
#of the three Cultivars of wines. 

#The attributes are:
#1) Alcohol 
#2) Malic acid / kwas jabkowy
#3) Ash / popiół
#4) Alcalinity of ash 
#5) Magnesium 
#6) Total phenols 
#7) Flavanoids 
#8) Nonflavanoid phenols 
#9) Proanthocyanins 
#10)Color intensity 
#11)Hue 
#12)OD280/OD315 of diluted wines 
#13)Proline 


library(ggplot2)
library(dplyr)

# Tworzymy połączenie z H2O
localH2O <- h2o.init(ip = "localhost", # domyślnie
                     port = 54321, # domyślnie
                     nthreads = -1, # użyj wszystkich dostepnych CPU
                     min_mem_size = "8g")

# Wczytujemy dane
wine <- h2o.importFile(path = "data/wine.csv",
                       destination_frame = "wine",
                       col.names = c('Cultivar', 'Alcohol', 'Malic', 'Ash', 
                                     'Alcalinity', 'Magnesium', 'Phenols', 
                                     'Flavanoids', 'Nonflavanoids',
                                     'Proanthocyanins', 'Color', 'Hue', 
                                     'Dilution', 'Proline'))

# k-means
wine_kmeans <- h2o.kmeans(x = 2:14, 
                          training_frame = wine,
                          model_id = "wine_kmeans",
                          k = 10,
                          estimate_k = TRUE,
                          standardize = TRUE)

wine_pred <- as.data.frame(h2o.predict(wine_kmeans, wine))

# PCA
wine_pca <- h2o.prcomp(x = 2:14, 
                       training_frame = wine,
                       model_id = "wine_pca",
                       transform = "STANDARDIZE", # Czy i jak transformować zmienne
                       k = 2) # liczba komponentów (max tyle ile zmiennych w 'x')
wine_components <- as.data.frame(h2o.predict(wine_pca, wine))

# Wizualizacja 
wine_data <- wine_components %>%
  cbind(wine_pred, Cultivar = as.vector(wine$Cultivar))

ggplot(wine_data, aes(PC1, PC2, color = as.factor(predict))) +
  geom_point() + theme_bw()
ggplot(wine_data, aes(PC1, PC2, color = as.factor(Cultivar))) +
  geom_point() + theme_bw()

table(wine_data$predict, wine_data$Cultivar)
