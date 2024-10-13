/**
 * @author
 * $Author: abeltran2 $
 * $LastChangedDate: 2014-08-31 16:06:26 -0700 (Sun, 31 Aug 2014) $
 *
 */

#include "../../includes/packet.h"
#include "../../includes/protocol.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

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
        dbg(GENERAL_CHANNEL, "Printing routing table:\n");
        for (i = 0; i < routeTableSize; i++) {
            dbg(GENERAL_CHANNEL, "Route to %d via %d with cost %d\n", routeTable[i].dest, routeTable[i].nextHop, routeTable[i].cost);
        }
    }

    // Command to start the link-state routing process
    command error_t LinkStateRouting.start() {
        dbg(GENERAL_CHANNEL, "Starting Link State Routing\n");
        // Initialize NeighborDiscovery and start it
        return call NeighborDiscovery.initialize();
    }

    // Command to handle link-state packets
    command void LinkStateRouting.handleLS(pack* myMsg) {
        dbg(GENERAL_CHANNEL, "Handling Link State Packet\n");
        // Process link-state packet, update routing table
        uint16_t src = myMsg->src;
        uint16_t cost = myMsg->TTL;
        
        // Example of adding route
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

    // Event when a neighbor is lost (used in NeighborDiscovery)
    event void NeighborDiscovery.clearExpiredNeighbors() {
        dbg(GENERAL_CHANNEL, "A neighbor expired\n");
        // Handle expired neighbors in the routing logic
    }
}
