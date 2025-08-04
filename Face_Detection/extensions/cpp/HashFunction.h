//
// Created by Kamoliddin Soliev on 15/10/24.
//

#ifndef REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_HASHFUNCTION_H
#define REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_HASHFUNCTION_H



#include "VectorOperations.h"
#include <random>
#include <string>


class HashFunction {
public:
    HashFunction(size_t dim, float w, std::mt19937& gen);
    int hash(const Vector& v) const;

private:
    Vector a;  // Random projection vector
    float b;   // Random offset
    float w;   // Bucket width
};



#endif //REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_HASHFUNCTION_H
