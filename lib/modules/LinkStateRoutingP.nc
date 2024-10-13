// Project 2
// CSE 160
// Sep/28/2024
// Zaid Laffta

#include <Timer.h>
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


   // Command to start the link-state routing process
command error_t LinkStateRouting.start() {

    dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");
   // bool result;
    // Step 1: Initialize NeighborDiscovery
    call NeighborDiscovery.initialize();
    //if (result != SUCCESS) {
        dbg(GENERAL_CHANNEL, "Error initializing NeighborDiscovery: %d\n", result);
      //  return result;  // Return the error code if initialization fails
    }

    // Step 2: Initialize or reset the routing table
    routeTableSize = 0;  // Reset the size of the routing table
    dbg(GENERAL_CHANNEL, "Routing table has been reset\n");

    // Step 3: (Optional) Start any necessary timers or processes for link-state routing
    // Example: Start a periodic timer to broadcast link-state updates (if applicable)
    // error_t timerResult = call Timer.startPeriodic(TIMER_PERIOD);
    // if (timerResult != SUCCESS) {
    //     dbg(GENERAL_CHANNEL, "Error starting link-state timer: %d\n", timerResult);
    //     return timerResult;  // Handle timer error if needed
    // }

    // If everything is successful, return SUCCESS
    //return SUCCESS;
}

////////////////////////////////////////////////

    // Command to handle link-state packets
    command void LinkStateRouting.handleLS(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Handling Link State Packet\n");

        // Extract source and cost from the received packet
        uint16_t src = myMsg->src;
        uint16_t cost = myMsg->TTL;  // Assuming TTL is being used as a cost here
        
        // Example of adding route to routing table
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

    // Command to ping a destination
    command void LinkStateRouting.ping(uint16_t destination, uint8_t *payload) {
        dbg(GENERAL_CHANNEL, "Pinging destination: %d\n", destination);
        pack myMsg;
        myMsg.src = TOS_NODE_ID;
        myMsg.dest = destination;
        myMsg.TTL = 1;
        myMsg.protocol = PROTOCOL_PING;
        memcpy(myMsg.payload, payload, PACKET_MAX_PAYLOAD_SIZE);

        call Broadcast.send(myMsg, destination);
    }

    // Command to route a packet
    command void LinkStateRouting.routePacket(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Routing packet to destination: %d\n", myMsg->dest);
        // Perform routing logic, possibly using the routing table
    }

    /*/ Event when a neighbor is lost (used in NeighborDiscovery)
    event void NeighborDiscovery.clearExpiredNeighbors() {
        dbg(GENERAL_CHANNEL, "A neighbor expired\n");
        // Handle expired neighbors in the routing logic
    }*/
}
