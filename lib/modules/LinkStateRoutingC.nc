#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP;
    LinkStateRouting = LinkStateRoutingP;

    components NeighborDiscoveryC;
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;

    components new SimpleSendC(AM_PACK);  // Instantiate SimpleSendC with AM_PACK
    LinkStateRoutingP.Broadcast -> SimpleSendC;
    /////
    components LinkStateRoutingC;                             
    NeighborDiscoveryP.LinkStateRouting -> LinkStateRoutingC;
    
}
