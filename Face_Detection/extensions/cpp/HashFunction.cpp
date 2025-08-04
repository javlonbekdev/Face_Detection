//
// Created by Kamoliddin Soliev on 15/10/24.
//

// HashFunction.cpp
#include "HashFunction.h"

HashFunction::HashFunction(size_t dim, float w, std::mt19937& gen) : w(w) {
    std::normal_distribution<float> dist(0.0f, 1.0f); // Gaussian distribution
    a.resize(dim);
    for (size_t i = 0; i < dim; ++i) {
        a[i] = dist(gen);
    }
    std::uniform_real_distribution<float> uniDist(0.0f, w);
    b = uniDist(gen);
}

int HashFunction::hash(const Vector& v) const {
    float dot = VectorOperations::dotProduct(a, v);
    return static_cast<int>(std::floor((dot + b) / w));
}
