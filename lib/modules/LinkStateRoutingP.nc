// Project 2
// CSE 160
// Sep/28/2024
// Zaid Laffta

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
    //uses interface CommandHandler;
    
}

implementation {
    uint16_t allNodes[50];
    //node routing table
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
        uint16_t nodeId;  // Node that the route belongs to
    } globalRouteEntry;

    // Global Routing Table
    globalRouteEntry globalRouteTable[50];
    uint8_t globalRouteTableSize = 0;

    ////end of global rout entry
    // Structure for storing routing table entries
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
    } routeTableEntry;

    // Routing table
    routeTableEntry routeTable[10];  // Can hold up to 10 entries
    uint8_t routeTableSize = 0;

 //////// Function to add a route to the global routing table////////
    void addGlobalRoute(uint16_t nodeId, uint16_t dest, uint16_t nextHop, uint16_t cost) {
        // Check if the global routing table is full
        if (globalRouteTableSize >= 50) {
            dbg(GENERAL_CHANNEL, "Global routing table is full, cannot add more routes.\n");
            return;
        }

        dbg(GENERAL_CHANNEL, "Adding to global route: NodeID = %d, Destination = %d, NextHop = %d, Cost = %d\n",
            nodeId, dest, nextHop, cost);

        globalRouteTable[globalRouteTableSize].nodeId = nodeId;
        globalRouteTable[globalRouteTableSize].dest = dest;
        globalRouteTable[globalRouteTableSize].nextHop = nextHop;
        globalRouteTable[globalRouteTableSize].cost = cost;
        globalRouteTableSize++;
    }

//////////// function to add routes//////////////
void addRoute(uint16_t dest, uint16_t nextHop, uint16_t cost) {
    if (routeTableSize >= 10) {
        dbg(GENERAL_CHANNEL, "Routing table full, cannot add more routes.\n");
        return;
    }

    dbg(GENERAL_CHANNEL, "Adding route: Destination = %d, NextHop = %d, Cost = %d\n", dest, nextHop, cost);
    
    routeTable[routeTableSize].dest = dest;
    routeTable[routeTableSize].nextHop = nextHop;
    routeTable[routeTableSize].cost = cost;
    routeTableSize++;
    // Add to global routing table as well
    addGlobalRoute(TOS_NODE_ID, dest, nextHop, cost);
}

/////////////Global routing table//////////////////
command void LinkStateRouting.printGlobalRouteTable() {
        uint8_t i;

        // Print header information
        dbg(GENERAL_CHANNEL, "==============================\n");
        dbg(GENERAL_CHANNEL, "Global Routing Table\n");
        dbg(GENERAL_CHANNEL, "==============================\n");

        // If global routing table is empty
        if (globalRouteTableSize == 0) {
            dbg(GENERAL_CHANNEL, "Global routing table is empty.\n");
            return;
        }

        // Print the global routing table
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


command void LinkStateRouting.printRouteTable() {
    uint8_t i;

    // Print the node ID
    dbg(GENERAL_CHANNEL, "==============================\n");
    dbg(GENERAL_CHANNEL, "Routing Table for Node %d\n", TOS_NODE_ID);
    dbg(GENERAL_CHANNEL, "------------------------------\n");

    // If there are no routes in the table
    if (routeTableSize == 0) {
        dbg(GENERAL_CHANNEL, "NO UPDDATE FOR THE ROUTING TABLE, KEEPING DISCOVERY ON.\n");
        dbg(GENERAL_CHANNEL, "==============================\n");
        return;
    }

    // Print a header for the routing table
    dbg(GENERAL_CHANNEL, "| Destination | Next Hop | Cost |\n");
    dbg(GENERAL_CHANNEL, "------------------------------\n");

    // Iterate over each entry in the routing table and print it
    for (i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest != 0 && routeTable[i].cost > 0) {
            dbg(GENERAL_CHANNEL, "|      %d      |    %d    |  %d  |\n", 
                routeTable[i].dest, 
                routeTable[i].nextHop, 
                routeTable[i].cost);
        } else {
            dbg(GENERAL_CHANNEL, "Invalid route at index %d.\n", i);
        }
    }

    // End of routing table display
    dbg(GENERAL_CHANNEL, "==============================\n");
}

command void LinkStateRouting.start() {
    dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");

    dbg(GENERAL_CHANNEL, "Initializing NeighborDiscovery\n");
    call NeighborDiscovery.initialize();

    dbg(GENERAL_CHANNEL, "NeighborDiscovery initialized successfully\n");

    routeTableSize = 0;  // Reset the size of the routing table
    dbg(GENERAL_CHANNEL, "Routing table has been reset\n");

    // Proceed with any additional setup as needed
    dbg(GENERAL_CHANNEL, "Link State Routing setup complete\n");
}

   command void LinkStateRouting.handleLS(pack* myMsg) {
    // Declare all variables at the beginning of the function
    uint16_t src;
    uint16_t cost;

    dbg(GENERAL_CHANNEL, "Handling Link State Packet\n");

    src = myMsg->src;
    cost = myMsg->TTL;  // Assuming TTL represents the cost

    addRoute(src, myMsg->src, cost);
}

command void LinkStateRouting.handleNeighborLost(uint16_t lostNeighbor) {
    uint8_t i;  // Loop variable
    uint8_t j;

    // Log the lost neighbor event
    dbg(GENERAL_CHANNEL, "Lost neighbor: %d\n", lostNeighbor);

    // Iterate through the routing table to find routes that depend on the lost neighbor
    for (i = 0; i < routeTableSize; i++) {
        // Check if the next hop for the route is the lost neighbor
        if (routeTable[i].nextHop == lostNeighbor) {
            dbg(GENERAL_CHANNEL, "Removing route to destination %d via lost neighbor %d\n", 
                routeTable[i].dest, lostNeighbor);

           
            for (j = i; j < routeTableSize - 1; j++) {
                routeTable[j] = routeTable[j + 1];
            }

            // Reduce the size of the routing table
            routeTableSize--;

            // Adjust the loop to check the new entry at index i
            i--;
        }
    }

    // Log the updated routing table
    call LinkStateRouting.printRouteTable();
}



command void LinkStateRouting.handleNeighborFound(uint16_t neighbor) {
    uint8_t i;  // Move variable declaration to the top
    for (i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest == neighbor) {
            return;  // Neighbor already exists, exit function
        }
    }

    addRoute(neighbor, neighbor, 1); 

    call LinkStateRouting.printRouteTable();
}


    command void LinkStateRouting.ping(uint16_t destination, uint8_t *payload) {
    // Declare the pack structure at the beginning of the function
    pack myMsg;

    dbg(GENERAL_CHANNEL, "Pinging destination: %d\n", destination);

    // Set the fields of the packet (myMsg)
    myMsg.src = TOS_NODE_ID;
    myMsg.dest = destination;
    myMsg.TTL = 1;
    myMsg.protocol = PROTOCOL_PING;

    memcpy(myMsg.payload, payload, PACKET_MAX_PAYLOAD_SIZE);

    call Broadcast.send(myMsg, AM_BROADCAST_ADDR);
}

    command void LinkStateRouting.routePacket(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Routing packet to destination: %d\n", myMsg->dest);
    }



command void LinkStateRouting.printAllRoutingTables() {
    uint8_t i;  // Loop variable for iterating over nodes
    uint8_t j;
    uint16_t nodeId;

    // Print header information
    dbg(GENERAL_CHANNEL, "==============================\n");
    dbg(GENERAL_CHANNEL, "Printing Full Routing Tables for All Nodes\n");
    dbg(GENERAL_CHANNEL, "==============================\n");

    // Iterate over each node in the network
    for (i = 0; i < sizeof(allNodes) / sizeof(allNodes[0]); i++) { // Use sizeof(allNodes[0]) for clarity
        nodeId = allNodes[i];

        dbg(GENERAL_CHANNEL, "==============================\n");
        dbg(GENERAL_CHANNEL, "Routing Table for Node %d\n", TOS_NODE_ID);
        dbg(GENERAL_CHANNEL, "------------------------------\n");

        // Check if the route table is empty
        if (routeTableSize == 0) {
            dbg(GENERAL_CHANNEL, "No routes in the table for Node %d\n", TOS_NODE_ID);
        } else {
            dbg(GENERAL_CHANNEL, "| Destination | Next Hop | Cost |\n");
            dbg(GENERAL_CHANNEL, "------------------------------\n");

            // Iterate over each route in the table
            for ( j = 0; j < routeTableSize; j++) {
                if (routeTable[j].dest != 0 && routeTable[j].cost > 0) {
                    dbg(GENERAL_CHANNEL, "|      %d      |    %d    |  %d  |\n",
                        routeTable[j].dest,
                        routeTable[j].nextHop,
                        routeTable[j].cost);
                } else {
                    dbg(GENERAL_CHANNEL, "Invalid route at index %d for Node %d\n", j, TOS_NODE_ID);
                }
            }
        }
    }

    dbg(GENERAL_CHANNEL, "==============================\n"); 
}


////////////// Dijkstra's algorithm to find the shortest paths////////////
    command void LinkStateRouting.runDijkstra() {
        uint16_t MAX_NODES;
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

   
}
