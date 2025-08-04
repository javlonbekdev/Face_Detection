//
// Created by Kamoliddin Soliev on 15/10/24.
//

#ifndef REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_LSHTABLE_H
#define REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_LSHTABLE_H

// LSHTable.h
#include "HashFunction.h"
#include <unordered_map>
#include <unordered_set>
#include <vector>

typedef std::string Hash;
typedef size_t VectorID;


class LSHTable {
public:
    LSHTable(size_t numHashFunctions, size_t dim, float w, std::mt19937& gen);
    Hash compositeHash(const Vector& v) const;
    void insert(VectorID id, const Vector& v);
    void remove(VectorID id, const Vector& v);
    const std::unordered_set<VectorID>& getCandidates(const Vector& v);

private:
    std::vector<HashFunction> hashFunctions;
    std::unordered_map<Hash, std::unordered_set<VectorID>> table;
    std::unordered_set<VectorID> emptySet; // For empty returns

    struct HashVectorHasher {
        size_t operator()(const Hash& hv) const {
            std::hash<int> hasher;
            size_t seed = 0;
            for (int h : hv) {
                seed ^= hasher(h) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
            }
            return seed;
        }
    };
};

#endif //REALSOFT_AI_ONESYTEM_UNIPASS_PROCTORING_LSHTABLE_H
