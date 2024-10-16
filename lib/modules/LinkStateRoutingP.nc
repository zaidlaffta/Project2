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
    // Structure for storing routing table entries
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
    } routeTableEntry;

    // Routing table
    routeTableEntry routeTable[10];  // Can hold up to 10 entries
    uint8_t routeTableSize = 0;

///FUnctions implementation
void addRoute(uint16_t dest, uint16_t nextHop, uint16_t cost) {
    // Check if the routing table is full
    if (routeTableSize >= 10) {
        dbg(GENERAL_CHANNEL, "Routing table full, cannot add more routes.\n");
        return;
    }

    dbg(GENERAL_CHANNEL, "Adding route: Destination = %d, NextHop = %d, Cost = %d\n", dest, nextHop, cost);
    
    routeTable[routeTableSize].dest = dest;
    routeTable[routeTableSize].nextHop = nextHop;
    routeTable[routeTableSize].cost = cost;
    routeTableSize++;
}
/*
///////////////////// new print table fucntion//////////////////
// Helper function to print the node and its routing table
command void LinkStateRouting.printRouteTable() {
    uint8_t i;

    // Print the node ID
    dbg(GENERAL_CHANNEL, "==============================\n");
    dbg(GENERAL_CHANNEL, "Node %d Routing Table \n", TOS_NODE_ID);
    //dbg(GENERAL_CHANNEL, "==============================\n");

    // If there are no routes in the table
    if (routeTableSize == 0) {
        dbg(GENERAL_CHANNEL, "Routing table is empty.\n");
        return;
    }

    // Iterate over each entry in the routing table and print it
    for (i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest != 0 && routeTable[i].cost > 0) {
            dbg(GENERAL_CHANNEL, "TESTING rout for noe Route to Destination: %d via Next Hop: %d with Cost: %d\n", 
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

*/
////////TEST print function //////////
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
////////////// test print function ////////

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
        dbg(GENERAL_CHANNEL, "Lost neighbor: %d\n", lostNeighbor);
        // Update routing table or remove affected routes
    }
/////////////Handle the neighbor when found ///////////////
command void LinkStateRouting.handleNeighborFound(uint16_t neighbor) {
    uint8_t i;  // Move variable declaration to the top

    dbg(GENERAL_CHANNEL, "New neighbor found: %d\n", neighbor);

    for (i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest == neighbor) {
            dbg(GENERAL_CHANNEL, "Neighbor %d already exists in the routing table, skipping addition.\n", neighbor);
            return;  // Neighbor already exists, exit function
        }
    }

    addRoute(neighbor, neighbor, 1);  // Add route to the neighbor

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

// Command to route a packet
    command void LinkStateRouting.routePacket(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Routing packet to destination: %d\n", myMsg->dest);
    }


// Function to print the full routing table for all nodes 

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
        dbg(GENERAL_CHANNEL, "Routing Table for Node %d\n", nodeId);
        dbg(GENERAL_CHANNEL, "------------------------------\n");

        // Check if the route table is empty
        if (routeTableSize == 0) {
            dbg(GENERAL_CHANNEL, "No routes in the table for Node %d\n", nodeId);
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
                    dbg(GENERAL_CHANNEL, "Invalid route at index %d for Node %d\n", j, nodeId);
                }
            }
        }
    }

    dbg(GENERAL_CHANNEL, "==============================\n"); 
}


   
}/////
