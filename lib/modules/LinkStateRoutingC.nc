#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP, NeighborDiscoveryC;  // Ensure NeighborDiscoveryC is instantiated
    components new SimpleSendC(AM_PACK);  // Instantiate SimpleSendC with AM_PACK
    LinkStateRoutingP.Broadcast -> SimpleSendC;
    // Provide LinkStateRouting from LinkStateRoutingP
    LinkStateRouting = LinkStateRoutingP;

    // Connect LinkStateRoutingP's NeighborDiscovery interface to NeighborDiscoveryC's NeighborDiscovery interface
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC.NeighborDiscovery;

    // Connect the Broadcast (SimpleSend) interface from LinkStateRoutingP to SimpleSendC
    
}
