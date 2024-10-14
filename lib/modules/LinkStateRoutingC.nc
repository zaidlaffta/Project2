#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP, NeighborDiscoveryC;
    components new SimpleSendC(AM_PACK);  // Instantiate SimpleSendC with AM_PACK

    
    // Provide LinkStateRouting from LinkStateRoutingP
    LinkStateRouting = LinkStateRoutingP;

    // Connect LinkStateRoutingP's NeighborDiscovery interface to NeighborDiscoveryC
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;

    // Connect LinkStateRoutingP's Broadcast interface to SimpleSendC
    LinkStateRoutingP.Broadcast -> SimpleSendC;
}