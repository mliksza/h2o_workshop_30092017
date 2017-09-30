library(h2o)
library(dplyr)
library(ggplot2)
library(gridExtra)

# Tworzymy połączenie z H2O
h2o.init(ip = "10.0.0.2", 
         port = 54321,
         startH2O = FALSE)

# Wczytujemy dane
mnist_train <- h2o.importFile(path = "data/Digits/mnist_train.csv", 
                                      destination_frame = "mnist_train",
                                      col.names = c("label", paste0("pixel", 1:784)),
                                      col.types=c("factor", rep("int", 784)))

mnist_test <- h2o.importFile(path = "data/Digits/mnist_test.csv",
                                     destination_frame = "mnist_test",
                                     col.names = c("label", paste0("pixel", 1:784)),
                                     col.types=c("factor", rep("int", 784)))

# Wizualizacja losowych cyfr
for(i in 1:100){
  df <- data.frame(x = expand.grid(1:28,28:1)[,1],
                   y = expand.grid(1:28,28:1)[,2],
                   fill = as.data.frame(t(mnist_train[sample(1:nrow(mnist_train),1),-1]))[,1])
  pl <- ggplot(df, aes(x, y, fill = fill)) + geom_raster(hjust = 0, vjust = 0) +
    scale_fill_gradient(low = "white", high = "black", guide = FALSE) +
    theme(axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.background = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_blank())
  assign(paste0("plot", i), pl)}
eval(parse(text = paste0("grid.arrange(", paste0("plot", 1:100, collapse = ", "),
                         ",ncol=10, nrow=10)")))
rm(list = c(ls(pattern = "plot"), "pl", "df"))

# Sieć neuronowa
mnist_nn_1 <- h2o.deeplearning(x = 2:785,
                             y = "label", 
                             training_frame = mnist_train,
                             distribution = "multinomial",
                             model_id = "mnist_nn_1",
                             l2 = 0.4,
                             ignore_const_cols = FALSE, # W celu wizualizacji warstwy ukrytej
                             hidden = 10, # liczba warstw ukrytych i neuronów per warstwa
                             export_weights_and_biases=TRUE) # Zachowanie wag i obciążeń

# Wizualizacja wag z pierwszej warstwy ukrytej
weights_l1 <- as.data.frame(h2o.weights(mnist_nn_1, 1))
biases_li <- as.data.frame(h2o.biases(mnist_nn_1, 1))
for(i in 1:10){
  df <- data.frame(x = expand.grid(1:28,28:1)[,1],
                   y = expand.grid(1:28,28:1)[,2],
                   fill = as.data.frame(t(weights_l1[i,]))[,1]+biases_li[i,1])
  pl <- ggplot(df, aes(x, y, fill = fill)) + geom_raster(hjust = 0, vjust = 0) +
    scale_fill_gradient(low = "white", high = "black", guide = FALSE) +
    theme(axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.background = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_blank())
  assign(paste0("plot", i), pl)
  }
eval(parse(text = paste0("grid.arrange(", paste0("plot", 1:10, collapse = ", "),
                         ",ncol=3, nrow=4)")))
rm(list = c(ls(pattern = "plot"), "pl", "df"))

h2o.predict(mnist_nn_1, mnist_test)
h2o.performance(mnist_nn_1, mnist_test)
h2o.confusionMatrix(mnist_nn_1, mnist_test)

# Dodajmy więcej parametrów
mnist_nn_2 <- h2o.deeplearning(x = 2:785,
                             y = "label", 
                             training_frame = mnist_train,
                             distribution = "multinomial",
                             model_id = "mnist_nn_2",
                             activation = "Tanh", # Funkcja aktywacji
                             loss = "CrossEntropy", # Minimalizowana funkcja straty
                             rate=0.01,
                             rate_annealing = 0.001,
                             hidden = c(50, 50, 100), # liczba warstw ukrytych i neuronów per warstwa
                             export_weights_and_biases=TRUE) # Zachowanie wag i obciążeń

h2o.predict(mnist_nn_2, mnist_test)
h2o.performance(mnist_nn_2, mnist_test)
h2o.confusionMatrix(mnist_nn_2, mnist_test)

# Grid search
hyper_params <- list(
  hidden = list(c(32,32), c(32,16,8), c(65)),
  l1 =  c(1e-4, 1e-3)
)

mnist_nn_grid <- h2o.grid(algorithm = "deeplearning",
                          grid_id = "mnist_nn_grid",
                          hyper_params = hyper_params,
                          x = 2:875,
                          y = "label",
                          distribution = "multinomial",
                          training_frame = mnist_train,
                          stopping_tolerance = 0.05)

h2o.getGrid("mnist_nn_grid",
            sort_by = "logloss",
            decreasing = FALSE)
