//
// Created by Kamoliddin Soliev on 15/10/24.
//

#ifndef REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_VECTOROPERATIONS_H
#define REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_VECTOROPERATIONS_H


#include <vector>
#include <cmath>

typedef std::vector<float> Vector;

class VectorOperations {
public:
    static float dotProduct(const Vector& a, const Vector& b);
    static float computeNorm(const Vector& v);
    static float cosineSimilarity(float dot, float normA, float normB);
    static float euclideanDistance(const Vector& a, const Vector& b);
};


#endif //REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_VECTOROPERATIONS_H
