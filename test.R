file.remove("src/OSRcppM.so")
file.remove("src/RcppExports.o")
file.remove("src/route.o")

require(OSRcppM)

data <- data.frame(id = 1:21, lat = seq(50.4, 50.6, by = 0.01), lon = seq(3, 3.2, by= 0.01))


system.time(res1 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                             "/home/bthieurmel/osrm-data/france-latest.osrm", nthreads = 1))

system.time(res2 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                              "/home/bthieurmel/osrm-data/france-latest.osrm", nthreads = 4))

system.time(res3 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                              "/home/bthieurmel/osrm-data/france-latest.osrm", nthreads = 8))

all.equal(res1, res2)
all.equal(res2, res3)


data <- data.frame(id = 1:21, lat_from = seq(50.4, 50.6, by = 0.01), lon_from = seq(3, 3.2, by= 0.01), 
                   lat_to = rev(seq(50.4, 50.6, by = 0.01)), lon_to = rev(seq(3, 3.2, by= 0.01)))
system.time(res2 <- OSRMroute2(data[rep(1:20, 5000), ], 
                              "/home/bthieurmel/osrm-data/france-latest.osrm", nthreads = 10))

system.time(res <- OSRMroute(data[rep(1:20, 1000), ], 
                             data[rep(1:10, 10), ], 
                             "/home/benoitt/osrm/osrm-data/nord-pas-de-calais-latest.osrm", 
                             nthreads = 8))
