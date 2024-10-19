#include <Timer.h>
#include "message.h"
#include "../../includes/channels.h"
#include "../../includes/packet.h"
#include "../../includes/protocol.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"

module LinkStateRoutingP {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    #define MAX_NODES 50
    #define INFINITY 65535  // Represents an unreachable cost

    uint16_t allNodes[MAX_NODES];  // Array to store all known nodes

    // Structure for global routing table entries
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
        uint16_t nodeId;  // Node ID to which this route belongs
    } globalRouteEntry;

    // Global Routing Table to store all routes across the network
    globalRouteEntry globalRouteTable[MAX_NODES];
    uint8_t globalRouteTableSize = 0;

    // Structure for local routing table entries
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
    } routeTableEntry;

    // Local Routing Table for the current node
    routeTableEntry routeTable[10];  // Can hold up to 10 entries
    uint8_t routeTableSize = 0;

    // Function to add a route to the global routing table
    void addGlobalRoute(uint16_t nodeId, uint16_t dest, uint16_t nextHop, uint16_t cost) {
        if (globalRouteTableSize >= MAX_NODES) {
            dbg(GENERAL_CHANNEL, "Global routing table is full, cannot add more routes.\n");
            return;
        }

        globalRouteTable[globalRouteTableSize].nodeId = nodeId;
        globalRouteTable[globalRouteTableSize].dest = dest;
        globalRouteTable[globalRouteTableSize].nextHop = nextHop;
        globalRouteTable[globalRouteTableSize].cost = cost;
        globalRouteTableSize++;

        dbg(GENERAL_CHANNEL, "Global Route Added: NodeID = %d, Dest = %d, NextHop = %d, Cost = %d\n", 
            nodeId, dest, nextHop, cost);
    }

    // Function to add a route to the local routing table
    void addRoute(uint16_t dest, uint16_t nextHop, uint16_t cost) {
        if (routeTableSize >= 10) {
            dbg(GENERAL_CHANNEL, "Local routing table full, cannot add more routes.\n");
            return;
        }

        routeTable[routeTableSize].dest = dest;
        routeTable[routeTableSize].nextHop = nextHop;
        routeTable[routeTableSize].cost = cost;
        routeTableSize++;

        addGlobalRoute(TOS_NODE_ID, dest, nextHop, cost);

        dbg(GENERAL_CHANNEL, "Route Added: Dest = %d, NextHop = %d, Cost = %d\n", dest, nextHop, cost);
    }

    // Dijkstra's algorithm to find the shortest paths
    command void LinkStateRouting.runDijkstra() {
        uint16_t dist[MAX_NODES];   // Distance array
        uint16_t prev[MAX_NODES];   // Previous node array
        uint8_t visited[MAX_NODES]; // Visited node array
        uint8_t i, j, u, minDist;

        // Initialize arrays
        for (i = 0; i < MAX_NODES; i++) {
            dist[i] = INFINITY;
            prev[i] = INFINITY;
            visited[i] = 0;
        }

        // Start from the current node
        dist[TOS_NODE_ID] = 0;

        // Main loop of Dijkstra's algorithm
        for (i = 0; i < MAX_NODES; i++) {
            // Find the unvisited node with the smallest distance
            minDist = INFINITY;
            u = INFINITY;

            for (j = 0; j < MAX_NODES; j++) {
                if (!visited[j] && dist[j] < minDist) {
                    minDist = dist[j];
                    u = j;
                }
            }

            // If no reachable node is found, break
            if (u == INFINITY) break;

            // Mark node as visited
            visited[u] = 1;

            // Update distances for neighbors of the node
            for (j = 0; j < routeTableSize; j++) {
                if (routeTable[j].dest == u) {
                    uint16_t alt = dist[u] + routeTable[j].cost;
                    if (alt < dist[routeTable[j].dest]) {
                        dist[routeTable[j].dest] = alt;
                        prev[routeTable[j].dest] = u;
                    }
                }
            }
        }

        // Print the shortest paths from the current node
        dbg(GENERAL_CHANNEL, "Dijkstra's Algorithm Results for Node %d\n", TOS_NODE_ID);
        dbg(GENERAL_CHANNEL, "| Destination | Next Hop | Cost |\n");
        dbg(GENERAL_CHANNEL, "--------------------------------\n");

        for (i = 0; i < MAX_NODES; i++) {
            if (dist[i] < INFINITY) {
                dbg(GENERAL_CHANNEL, "|      %d      |    %d    |  %d  |\n", i, prev[i], dist[i]);
            }
        }

        dbg(GENERAL_CHANNEL, "==============================\n");
    }

    // Other existing functions...

    command void LinkStateRouting.start() {
        dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");
        call NeighborDiscovery.initialize();
        routeTableSize = 0;  // Reset the size of the routing table
        dbg(GENERAL_CHANNEL, "Link State Routing initialized\n");
    }
}
