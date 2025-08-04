//
// Created by Kamoliddin Soliev on 15/10/24.
//

#include "VectorOperations.h"

float VectorOperations::dotProduct(const Vector& a, const Vector& b) {
    float result = 0.0f;
    size_t size = a.size();
    for (size_t i = 0; i < size; ++i) {
        result += a[i] * b[i];
    }
    return result;
}

float VectorOperations::computeNorm(const Vector& v) {
    return std::sqrt(dotProduct(v, v));
}

float VectorOperations::cosineSimilarity(float dot, float normA, float normB) {
    return dot / (normA * normB);
}

float VectorOperations::euclideanDistance(const Vector& a, const Vector& b) {
    float sum = 0.0f;
    size_t size = a.size();
    for (size_t i = 0; i < size; ++i) {
        float diff = a[i] - b[i];
        sum += diff * diff;
    }
    return std::sqrt(sum);
}
