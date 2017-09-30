pkgs <- c("h2o", "microbenchmark")
for (pkg in pkgs) {
  if (! (pkg %in% rownames(installed.packages()))) { 
    install.packages(pkg) 
  }
}

library(h2o)
library (microbenchmark)

# Tworzymy połączenie z H2O
localH2O <- h2o.init(ip = "localhost", # domyślnie
                     port = 54321, # domyślnie
                     nthreads = -1, # użyj wszystkich dostepnych CPU
                     min_mem_size = "8g")

# Przejdź do http://localhost:54321

h2o.clusterInfo() # Informacje o clustrze

#h2o.shutdown() # Zamknięcie clustra

# WYSYŁANIE DANYCH DO H2O I Z H2O
h2o.ls() # Lista obiektów w H2O wraz z kluczami 

# 1.  Dane dostępne w R
iris1_h2o <- as.h2o(iris) # Nazwa zbioru taka sama w H2O jak w R
iris2_h2o <- as.h2o(iris,
                    destination_frame = "iris2") # Nazwa zbioru zdefiniowana


# 2. Dane z pliku zewn. 
#Unlike the import function, which is a parallelized reader, h2o.uploadFile 
#is a push from the client to the server. The specified path must be a 
#client-side path. This is not scalable and is only intended for 
#smaller data sizes. The client pushes the data from a local filesystem 
#(for example, on your machine where R is running) to H2O. 
#For big-data operations, 
#you don't want the data stored on or flowing through the client.

microbenchmark(
  h2o.uploadFile(path = "data/yellow_taxi_data_sample/yellow_tripsample_2016-01.csv",
                 destination_frame = "yellow_taxi_sample"),
  h2o.importFile(path = "data/yellow_taxi_data_sample/yellow_tripsample_2016-01.csv",
                 destination_frame = "yellow_taxi_sample"),
  times = 10L
)

yellow_taxi_sample <- h2o.importFile(path = "data/yellow_taxi_data_sample/yellow_tripsample_2016-01.csv",
                                     destination_frame = "yellow_taxi_sample")
# Analogiczne funkcje h2o.importURL, h2o.importFolder

# 3. Eksport danych z H2O 
h2o.exportFile(data = yellow_taxi_sample,
               path = "yellow_taxi_sample.csv",
               parts = 4) # Można podzielić plik na kilka części

iris2 <- as.data.frame(iris2_h2o) # Wczytanie danych z H2O do R
# Analogiczne funkcje h2o.exportHDFS

h2o.getId(iris2_h2o) # nazwa z H2O

h2o.rm("iris2") # Usuwanie z H2O obiektu 'iris2'
h2o.removeAll() # Usuwanie wszystkich obiektów z H2O

# MANIPULACJA DANYMI
x <- as.h2o(data.frame(id = 1:4,a = rnorm(4)),
            destination_frame = "x")
y <- as.h2o(data.frame(id = 1:4, b = letters[1:4]),
            destination_frame = "y")  


x1 <- h2o.assign(3*x[1:2,], key = "x1") # Przypisanie

h2o.cbind(x,y)
h2o.rbind(x,x)
h2o.merge(x,y, by = "id")
# h2o:::.h2o.garbageCollect()
