//
// Created by Kamoliddin Soliev on 15/10/24.
//

#ifndef REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_ANNDATABASE_H
#define REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_ANNDATABASE_H




#include "LSHTable.h"
#include <unordered_map>

struct VectorData {
    Vector vector;
};

class ANNDatabase {
public:
    ANNDatabase(size_t dim, size_t numHashTables, size_t numHashFunctions, float w);
    VectorID insert(const Vector& v);
    Vector get(VectorID id) const;
    void update(VectorID id, const Vector& v);
    void remove(VectorID id);
    std::vector<std::pair<VectorID, float>> query(const Vector& v, int numResults = 10);

private:
    size_t dim;
    size_t numHashTables;
    size_t numHashFunctions;
    float w; // Bucket width
    std::vector<LSHTable> tables;
    std::unordered_map<VectorID, VectorData> data;
    VectorID nextID;
    std::mt19937 gen; // Random number generator
};


#endif // ANN_DATABASE_H

