//
// Created by Kamoliddin Soliev on 15/10/24.
//

// ANNDatabase.cpp
// ANNDatabase.cpp
#include "ANNDatabase.h"
#include "VectorOperations.h"
#include <algorithm>

ANNDatabase::ANNDatabase(size_t dim, size_t numHashTables, size_t numHashFunctions, float w)
        : dim(dim), numHashTables(numHashTables), numHashFunctions(numHashFunctions), w(w), nextID(0) {
    std::random_device rd;
    gen.seed(rd());
    for (size_t i = 0; i < numHashTables; ++i) {
        tables.emplace_back(numHashFunctions, dim, w, gen);
    }
}

VectorID ANNDatabase::insert(const Vector& v) {
    if (v.size() != dim) {
        throw std::invalid_argument("Vector dimensionality mismatch.");
    }
    VectorID id = nextID++;
    data[id] = {v};
    for (auto& table : tables) {
        table.insert(id, v);
    }
    return id;
}

Vector ANNDatabase::get(VectorID id) const {
    auto it = data.find(id);
    if (it != data.end()) {
        return it->second.vector;
    }
    throw std::runtime_error("Vector ID not found.");
}

void ANNDatabase::update(VectorID id, const Vector& v) {
    if (v.size() != dim) {
        throw std::invalid_argument("Vector dimensionality mismatch.");
    }
    auto it = data.find(id);
    if (it != data.end()) {
        // Remove old vector from hash tables
        for (auto& table : tables) {
            table.remove(id, it->second.vector);
        }
        // Update the vector
        data[id] = {v};
        // Insert new vector into hash tables
        for (auto& table : tables) {
            table.insert(id, v);
        }
    } else {
        throw std::runtime_error("Vector ID not found.");
    }
}

void ANNDatabase::remove(VectorID id) {
    auto it = data.find(id);
    if (it != data.end()) {
        // Remove vector from hash tables
        for (auto& table : tables) {
            table.remove(id, it->second.vector);
        }
        // Remove from data storage
        data.erase(it);
    } else {
        throw std::runtime_error("Vector ID not found.");
    }
}

std::vector<std::pair<VectorID, float>> ANNDatabase::query(const Vector& v, int numResults) {
    if (v.size() != dim) {
        throw std::invalid_argument("Vector dimensionality mismatch.");
    }
    std::unordered_set<VectorID> candidates;
    // Retrieve candidates from all tables
    for (auto& table : tables) {
        const auto& ids = table.getCandidates(v);
        candidates.insert(ids.begin(), ids.end());
    }
    // Compute Euclidean distances
    std::vector<std::pair<float, VectorID>> distances;
    for (VectorID id : candidates) {
        const Vector& dataVec = data[id].vector;
        float dist = VectorOperations::euclideanDistance(v, dataVec);
        distances.push_back({dist, id});
    }
    // Sort by distance (ascending order)
    std::sort(distances.begin(), distances.end());
    // Collect top results
    std::vector<std::pair<VectorID, float>> results;
    for (int i = 0; i < std::min(numResults, static_cast<int>(distances.size())); ++i) {
        results.push_back({distances[i].second, distances[i].first});
    }
    return results;
}

