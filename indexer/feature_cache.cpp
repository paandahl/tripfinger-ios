#include "indexer/feature_cache.hpp"
#include "base/logging.hpp"

void FeatureCache::SetFeatures(vector<SelfBakedFeatureType> && features) {
  this->features = features;
}

vector<SelfBakedFeatureType> FeatureCache::GetFeatures(TripfingerMarkParams const & params) const {
  vector<SelfBakedFeatureType> results;
  for (SelfBakedFeatureType const & feature : features) {
    if (feature.GetCenter().x > params.topLeft.x && feature.GetCenter().x < params.botRight.x
        && feature.GetCenter().y > params.botRight.y && feature.GetCenter().y < params.topLeft.y) {
      results.push_back(feature);
    }
  }
  return results;
}

SelfBakedFeatureType FeatureCache::GetFeatureById(string const & id) const {
  string idCopy = id;
  return featureMap.at(idCopy);
}
