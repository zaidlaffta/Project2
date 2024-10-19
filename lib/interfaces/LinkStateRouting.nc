
#include "../../includes/packet.h"

interface LinkStateRouting {
  //  command error_t start();
    command void start();
    command void ping(uint16_t destination, uint8_t *payload);
    command void routePacket(pack* myMsg);
    command void handleLS(pack* myMsg);
    command void handleNeighborLost(uint16_t lostNeighbor);
    command void handleNeighborFound(uint16_t neighbor);
    command void printRouteTable();
    command void printAllRoutingTables();
    command void printGlobalRouteTable();
    command void runDijkstra();
}
