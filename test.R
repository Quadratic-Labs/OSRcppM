file.remove("src/OSRcppM.so")
file.remove("src/RcppExports.o")
file.remove("src/route.o")

require(OSRcppM)

data <- data.frame(id = 1:21, lat = seq(50.4, 50.6, by = 0.01), lon = seq(3, 3.2, by= 0.01))


system.time(res1 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                             "/home/benoit/osrm-data/nord-pas-de-calais-latest.osrm", nthreads = 1))

system.time(res2 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                             "/home/benoit/osrm-data/nord-pas-de-calais-latest.osrm", nthreads = 4))

system.time(res3 <- OSRMroute(data[rep(1:20, 100), ], data[rep(1:10, 1), ], 
                             "/home/benoit/osrm-data/nord-pas-de-calais-latest.osrm", nthreads = 8))

all.equal(res1, res2)
all.equal(res2, res3)

system.time(res <- OSRMroute(data[rep(1:20, 1000), ], 
                             data[rep(1:10, 10), ], 
                             "/home/benoit/osrm-data/nord-pas-de-calais-latest.osrm", 
                             nthreads = 8))
