
#include <Timer.h>
#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
}

implementation {
    components LinkStateRoutingP;
    LinkStateRouting = LinkStateRoutingP;

    components new SimpleSendC(AM_PACK);
    LinkStateRoutingP.Broadcast -> SimpleSendC;

    components NeighborDiscoveryC;
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;    

   

    

}