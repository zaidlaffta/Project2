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
    // Maximum number of nodes
    #define MAX_NODES 50
    #define INFINITY 65535  // Represents an unreachable cost

    // Array to store all known nodes
    uint16_t allNodes[MAX_NODES];

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
        // Check if the global routing table is full
        if (globalRouteTableSize >= MAX_NODES) {
            dbg(GENERAL_CHANNEL, "Global routing table is full, cannot add more routes.\n");
            return;
        }

        // Add the route to the global table
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
        // Check if the local routing table is full
        if (routeTableSize >= 10) {
            dbg(GENERAL_CHANNEL, "Local routing table full, cannot add more routes.\n");
            return;
        }

        // Add the route to the local table
        routeTable[routeTableSize].dest = dest;
        routeTable[routeTableSize].nextHop = nextHop;
        routeTable[routeTableSize].cost = cost;
        routeTableSize++;

        // Also add to the global routing table
        addGlobalRoute(TOS_NODE_ID, dest, nextHop, cost);

        dbg(GENERAL_CHANNEL, "Route Added: Dest = %d, NextHop = %d, Cost = %d\n", dest, nextHop, cost);
    }

    // Function to print the global routing table
    command void LinkStateRouting.printGlobalRouteTable() {
        uint8_t i;

        dbg(GENERAL_CHANNEL, "==============================\n");
        dbg(GENERAL_CHANNEL, "Global Routing Table\n");
        dbg(GENERAL_CHANNEL, "==============================\n");

        if (globalRouteTableSize == 0) {
            dbg(GENERAL_CHANNEL, "Global routing table is empty.\n");
            return;
        }

        dbg(GENERAL_CHANNEL, "| NodeID | Destination | Next Hop | Cost |\n");
        dbg(GENERAL_CHANNEL, "------------------------------------------\n");

        for (i = 0; i < globalRouteTableSize; i++) {
            dbg(GENERAL_CHANNEL, "|   %d   |      %d      |    %d    |  %d  |\n",
                globalRouteTable[i].nodeId,
                globalRouteTable[i].dest,
                globalRouteTable[i].nextHop,
                globalRouteTable[i].cost);
        }

        dbg(GENERAL_CHANNEL, "==============================\n");
    }

    // Function to print the local routing table
    command void LinkStateRouting.printRouteTable() {
        uint8_t i;

        dbg(GENERAL_CHANNEL, "==============================\n");
        dbg(GENERAL_CHANNEL, "Routing Table for Node %d\n", TOS_NODE_ID);
        dbg(GENERAL_CHANNEL, "==============================\n");

        if (routeTableSize == 0) {
            dbg(GENERAL_CHANNEL, "Routing table is empty.\n");
            return;
        }

        dbg(GENERAL_CHANNEL, "| Destination | Next Hop | Cost |\n");
        dbg(GENERAL_CHANNEL, "--------------------------------\n");

        for (i = 0; i < routeTableSize; i++) {
            dbg(GENERAL_CHANNEL, "|      %d      |    %d    |  %d  |\n", 
                routeTable[i].dest, 
                routeTable[i].nextHop, 
                routeTable[i].cost);
        }

        dbg(GENERAL_CHANNEL, "==============================\n");
    }
}
    // Function to implement Dijkstra's algorithm for finding shortest paths
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

    // Handle booting and start Link State Routing
    command void LinkStateRouting.start() {
        dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");
        call NeighborDiscovery.initialize();
        routeTableSize = 0;
        dbg(GENERAL_CHANNEL, "Link State Routing initialized\n");
    }
}
