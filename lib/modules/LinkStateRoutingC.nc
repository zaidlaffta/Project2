
#include <Timer.h>
#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

// Link state vars
//#define LS_MAX_ROUTES 256
//#define LS_MAX_COST 17
//#define LS_TTL 17

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