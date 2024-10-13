/**
 * @author UCM ANDES Lab
 * $Author: abeltran2 $
 * $LastChangedDate: 2014-08-31 16:06:26 -0700 (Sun, 31 Aug 2014) $
 *
 */

#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"
/*
configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP, NeighborDiscoveryC, SimpleSendC;
    
    omponents new SimpleSendC(AM_PACK);
    LinkStateRoutingP.Broadcast -> SimpleSendC;
    LinkStateRouting = LinkStateRoutingP;
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;
    LinkStateRoutingP.Broadcast -> SimpleSendC;
}*/
configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP, NeighborDiscoveryC;
    components new SimpleSendC(AM_PACK);  // Instantiate SimpleSendC with AM_PACK

    // Connect LinkStateRoutingP to NeighborDiscoveryC and SimpleSendC
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;
    LinkStateRoutingP.Broadcast -> SimpleSendC;

    // Provide LinkStateRouting from LinkStateRoutingP
    LinkStateRouting = LinkStateRoutingP;
}
