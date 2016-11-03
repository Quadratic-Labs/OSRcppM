#include <Rcpp.h>

#include "osrm/match_parameters.hpp"
#include "osrm/nearest_parameters.hpp"
#include "osrm/route_parameters.hpp"
#include "osrm/table_parameters.hpp"
#include "osrm/trip_parameters.hpp"

#include "osrm/coordinate.hpp"
#include "osrm/engine_config.hpp"
#include "osrm/json_container.hpp"

#include "osrm/osrm.hpp"
#include "osrm/status.hpp"

#include <exception>
#include <iostream>
#include <string>
#include <utility>

#include <cstdlib>

// [[Rcpp::export]]
Rcpp::List OSRMroute(Rcpp::DataFrame FromDF,
		     Rcpp::DataFrame ToDF,
		     std::string OSRMdata
		     ) {

  using namespace osrm;

  // set up configuration based on pre-compilied OSRM data
  EngineConfig config;
  config.storage_config = {OSRMdata};
  config.use_shared_memory = false;
  OSRM osrm{config};

  // init vectors for coordinates
  Rcpp::NumericVector xlat = FromDF["lat"];
  Rcpp::NumericVector xlon = FromDF["lon"];
  Rcpp::NumericVector ylat = ToDF["lat"];
  Rcpp::NumericVector ylon = ToDF["lon"];

  int n = xlat.size();
  int k = ylat.size();
  Rcpp::NumericMatrix dist(n,k);
  Rcpp::NumericMatrix time(n,k);

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < k; j++) {

      // init route parameters
      RouteParameters params;

      params.coordinates.push_back({util::FloatLongitude{xlon[i]},
	    util::FloatLatitude{xlat[i]}});
      params.coordinates.push_back({util::FloatLongitude{ylon[j]},
	    util::FloatLatitude{ylat[j]}});

      // init JSON response object
      json::Object result;

      // compute route
      const auto status = osrm.Route(params, result);
      auto &routes = result.values["routes"].get<json::Array>();

      // take first response which is shortest (?) trip
      auto &route = routes.values.at(0).get<json::Object>();
      const auto distance = route.values["distance"].get<json::Number>().value;
      const auto duration = route.values["duration"].get<json::Number>().value;

      // store in matrices
      dist(i,j) = distance;
      time(i,j) = duration;
    }
  }

  // add row and column names
  Rcpp::CharacterVector rnms = FromDF["id"];
  Rcpp::CharacterVector cnms = ToDF["id"];
  Rcpp::List dimnms = Rcpp::List::create(rnms, cnms);
  dist.attr("dimnames") = dimnms;
  time.attr("dimnames") = dimnms;

  return Rcpp::List::create(Rcpp::Named("meters") = dist,
			    Rcpp::Named("seconds") = time);
}
