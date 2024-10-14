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

    
}

implementation {
    // Structure for storing routing table entries
    typedef struct {
        uint16_t dest;
        uint16_t nextHop;
        uint16_t cost;
    } routeTableEntry;

    // Routing table
    routeTableEntry routeTable[10];  // Can hold up to 10 entries
    uint8_t routeTableSize = 0;
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

///////////////////// new print table fucntion//////////////////
// Helper function to print the node and its routing table
command void LinkStateRouting.printRouteTable() {
    uint8_t i;

    // Print the node ID
    dbg(GENERAL_CHANNEL, "==============================\n");
    dbg(GENERAL_CHANNEL, "Node %d Routing Table \n", TOS_NODE_ID);
    dbg(GENERAL_CHANNEL, "==============================\n");

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



command void LinkStateRouting.start() {
    dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");

    // Step 1: Initialize NeighborDiscovery
    dbg(GENERAL_CHANNEL, "Initializing NeighborDiscovery\n");
    call NeighborDiscovery.initialize();

    // Optional: Add a check for result if needed, but no error handling
    dbg(GENERAL_CHANNEL, "NeighborDiscovery initialized successfully\n");

    // Step 2: Initialize or reset the routing table
    routeTableSize = 0;  // Reset the size of the routing table
    dbg(GENERAL_CHANNEL, "Routing table has been reset\n");

    // Proceed with any additional setup as needed
    dbg(GENERAL_CHANNEL, "Link State Routing setup complete\n");
}



   command void LinkStateRouting.handleLS(pack* myMsg) {
    // Declare all variables at the beginning of the function
    uint16_t src;
    uint16_t cost;

    // Debug message to indicate the function is handling a Link State packet
    dbg(GENERAL_CHANNEL, "Handling Link State Packet\n");

    // Assign the source node from the message and the cost (using TTL as cost)
    src = myMsg->src;
    cost = myMsg->TTL;  // Assuming TTL represents the cost

    // Add the route to the routing table using the addRoute function
    addRoute(src, myMsg->src, cost);
}


    // Command to handle a lost neighbor
    command void LinkStateRouting.handleNeighborLost(uint16_t lostNeighbor) {
        dbg(GENERAL_CHANNEL, "Lost neighbor: %d\n", lostNeighbor);
        // Update routing table or remove affected routes
    }
/////////////Handle the neighbor when found ///////////////
command void LinkStateRouting.handleNeighborFound(uint16_t neighbor) {
    uint8_t i;  // Move variable declaration to the top

    // Step 1: Debug message to indicate a new neighbor has been found
    dbg(GENERAL_CHANNEL, "New neighbor found: %d\n", neighbor);

    // Step 2: Check if the neighbor already exists in the routing table
    for (i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest == neighbor) {
            dbg(GENERAL_CHANNEL, "Neighbor %d already exists in the routing table, skipping addition.\n", neighbor);
            return;  // Neighbor already exists, exit function
        }
    }

    // Step 3: Add the neighbor as both destination and next hop with cost 1 (direct neighbor)
    addRoute(neighbor, neighbor, 1);  // Add route to the neighbor

    // Step 4: Print the updated routing table to confirm the route was added
    call LinkStateRouting.printRouteTable();
}



    command void LinkStateRouting.ping(uint16_t destination, uint8_t *payload) {
    // Declare the pack structure at the beginning of the function
    pack myMsg;

    // Debug message to indicate the destination of the ping
    dbg(GENERAL_CHANNEL, "Pinging destination: %d\n", destination);

    // Set the fields of the packet (myMsg)
    myMsg.src = TOS_NODE_ID;
    myMsg.dest = destination;
    myMsg.TTL = 1;
    myMsg.protocol = PROTOCOL_PING;

    // Copy the payload into the packet's payload field
    memcpy(myMsg.payload, payload, PACKET_MAX_PAYLOAD_SIZE);

    // Call the Broadcast.send function to send the message (use &myMsg to pass a pointer)
    call Broadcast.send(myMsg, AM_BROADCAST_ADDR);
}

// Command to route a packet
    command void LinkStateRouting.routePacket(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Routing packet to destination: %d\n", myMsg->dest);
        // Perform routing logic, possibly using the routing table
    }
/*
/////////////////////////// extra function ////////////////////////////

command void LinkStateRouting.routePacket(pack* myMsg) {
    dbg(GENERAL_CHANNEL, "Routing packet to destination: %d from source: %d\n", myMsg->dest, myMsg->src);

    // Check the packet's TTL (Time to Live)
    if (myMsg->TTL == 0) {
        dbg(GENERAL_CHANNEL, "Packet TTL expired. Dropping packet to destination: %d\n", myMsg->dest);
        return;  // Drop the packet if TTL is 0
    }

    // Decrement the TTL
    myMsg->TTL--;

   // uint8_t i;
    bool routeFound = FALSE;

    // Search the routing table for a matching destination
    for (uint16_t i = 0; i < routeTableSize; i++) {
        if (routeTable[i].dest == myMsg->dest) {
            // Route found: use the next hop from the routing table
            uint16_t nextHop = routeTable[i].nextHop;
            dbg(GENERAL_CHANNEL, "Route found! Next Hop: %d for Destination: %d with Cost: %d\n", 
                nextHop, myMsg->dest, routeTable[i].cost);

            // Step 1: Create a message_t object
            message_t msg;

            // Step 2: Get the payload section of the message_t (where we will copy myMsg)
            pack *packetToSend = (pack *) call Packet.getPayload(&msg, sizeof(pack));

            // Step 3: Copy the pack (myMsg) into the payload of message_t
            memcpy(packetToSend, myMsg, sizeof(pack));

            // Step 4: Send the message_t to the next hop using Broadcast.send()
            error_t result = call Broadcast.send(&msg, nextHop);
            if (result != SUCCESS) {
                dbg(GENERAL_CHANNEL, "Failed to send packet to next hop: %d\n", nextHop);
            } else {
                dbg(GENERAL_CHANNEL, "Packet sent to next hop: %d\n", nextHop);
            }

            routeFound = TRUE;
            break;
        }
    }

    // If no route is found, drop the packet
    if (!routeFound) {
        dbg(GENERAL_CHANNEL, "No route found for destination: %d. Dropping packet.\n", myMsg->dest);
    }
} */



   
}
