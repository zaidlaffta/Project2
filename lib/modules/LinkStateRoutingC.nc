/*#include "../../includes/CommandMsg.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
    uses interface NeighborDiscovery;
    uses interface SimpleSend as Broadcast;
}

implementation {
    components LinkStateRoutingP;
    components NeighborDiscoveryC;  
    components new SimpleSendC(AM_PACK);  // Instantiate SimpleSendC with AM_PACK

    // Provide LinkStateRouting from LinkStateRoutingP
    LinkStateRouting = LinkStateRoutingP;

    // Connect LinkStateRoutingP's NeighborDiscovery interface to NeighborDiscoveryC's NeighborDiscovery interface
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;

    // Connect the Broadcast (SimpleSend) interface from LinkStateRoutingP to SimpleSendC
    LinkStateRoutingP.Broadcast -> SimpleSendC;
}
*/
#include <Timer.h>
#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

// Link state vars
#define LS_MAX_ROUTES 256
#define LS_MAX_COST 17
#define LS_TTL 17

configuration LinkStateRoutingC {
    provides interface LinkStateRouting;
}

implementation {
    components LinkStateRoutingP;
    LinkStateRouting = LinkStateRoutingP;

    components new SimpleSendC(AM_PACK);
    LinkStateRoutingP.Sender -> SimpleSendC;

    components new MapListC(uint16_t, uint16_t, LS_MAX_ROUTES, 30); //what to do with maplist, same as the other time?
    LinkStateRoutingP.PacketsReceived -> MapListC;

    components NeighborDiscoveryC;
    LinkStateRoutingP.NeighborDiscovery -> NeighborDiscoveryC;    

    components FloodingC;
    LinkStateRoutingP.Flooding -> FloodingC;

    components new TimerMilliC() as LSRTimer;   
    LinkStateRoutingP.LSRTimer -> LSRTimer;

    components RandomC as Random;               
    LinkStateRoutingP.Random -> Random;
}