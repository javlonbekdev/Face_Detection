//
// Created by Kamoliddin Soliev on 15/10/24.
//

#include "LSHTable.h"
LSHTable::LSHTable(size_t numHashFunctions, size_t dim, float w, std::mt19937& gen) {
    for (size_t i = 0; i < numHashFunctions; ++i) {
        hashFunctions.emplace_back(dim, w, gen);
    }
}

Hash LSHTable::compositeHash(const Vector& v) const {
    Hash h;
    for (const auto& func : hashFunctions) {
        h.push_back(func.hash(v));
    }
    return h;
}

void LSHTable::insert(VectorID id, const Vector& v) {
    Hash h = compositeHash(v);
    table[h].insert(id);
}

void LSHTable::remove(VectorID id, const Vector& v) {
    Hash h = compositeHash(v);
    auto it = table.find(h);
    if (it != table.end()) {
        it->second.erase(id);
        if (it->second.empty()) {
            table.erase(it);
        }
    }
}

const std::unordered_set<VectorID>& LSHTable::getCandidates(const Vector& v) {
    Hash h = compositeHash(v);
    auto it = table.find(h);
    if (it != table.end()) {
        return it->second;
    } else {
        return emptySet;
    }
}

