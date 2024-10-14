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

    // Helper function to add a route to the table
    void addRoute(uint16_t dest, uint16_t nextHop, uint16_t cost) {
        dbg(GENERAL_CHANNEL, "Adding route: Destination = %d, NextHop = %d, Cost = %d\n", dest, nextHop, cost);
        routeTable[routeTableSize].dest = dest;
        routeTable[routeTableSize].nextHop = nextHop;
        routeTable[routeTableSize].cost = cost;
        routeTableSize++;
    }

  // Helper function to print the routing table
command void LinkStateRouting.printRouteTable() {
    uint8_t i;
    
    // If there are no routes in the table
    if (routeTableSize == 0) {
        dbg(GENERAL_CHANNEL, "Routing table is empty.\n");
        return;
    }

    // Printing the header for the routing table
    dbg(GENERAL_CHANNEL, "==============================\n");
    dbg(GENERAL_CHANNEL, "Routing Table:\n");
    dbg(GENERAL_CHANNEL, "==============================\n");

    // Iterate over each entry in the routing table and print it
    for (i = 0; i < routeTableSize; i++) {
        // Ensure the entry is valid (optional, depending on your implementation)
        if (routeTable[i].dest != 0 && routeTable[i].cost > 0) {
            dbg(GENERAL_CHANNEL, "Destination: %d, Next Hop: %d, Cost: %d\n", 
                routeTable[i].dest, 
                routeTable[i].nextHop, 
                routeTable[i].cost);
        } else {
            dbg(GENERAL_CHANNEL, "Invalid route at index %d.\n", i);
        }
    }

    // Ending the routing table display
    dbg(GENERAL_CHANNEL, "==============================\n");
}
////////////////
command error_t LinkStateRouting.start() {
    dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");

    // Step 1: Initialize NeighborDiscovery
    call NeighborDiscovery.initialize();  // Declare 'result' correctly
    if (result != SUCCESS) {
    dbg(GENERAL_CHANNEL, "Error initializing NeighborDiscovery: %d\n", result);
    return result;  // Return the error code if initialization fails
    

    // Step 2: Initialize or reset the routing table
   // routeTableSize = 0;  // Reset the size of the routing table
   // dbg(GENERAL_CHANNEL, "Routing table has been reset\n");

    // If everything is successful, return SUCCESS
    return SUCCESS;
}


////////////////////////////////////////////////

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

    // Command to handle a newly found neighbor
    command void LinkStateRouting.handleNeighborFound() {
        dbg(GENERAL_CHANNEL, "New neighbor found\n");
        // Handle new neighbor discovery, potentially update routing table
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

   
}
