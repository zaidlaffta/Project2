/*/ Project 1
// CSE 160
// Sep/28/2024
// Zaid Laffta

#include <Timer.h>
#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"
#include "../../includes/command.h"
#include "../../includes/channels.h"

configuration NeighborDiscoveryC {
    // Provides the NeighborDiscovery interface to other modules.
    provides interface NeighborDiscovery;
}

implementation {

    // NeighborDiscoveryP provides the actual implementation of NeighborDiscovery interface
    components NeighborDiscoveryP;
    NeighborDiscovery = NeighborDiscoveryP;
    // Setup of RandomC for generating random values
    components RandomC as RandomGen;
    NeighborDiscoveryP.Random -> RandomGen;
    // TimerMilliC handles periodic timer events
    components new TimerMilliC() as PeriodicTimer;
    NeighborDiscoveryP.Timer -> PeriodicTimer;
    // SimpleSendC for broadcasting packets
    components new SimpleSendC(AM_PACK);
    NeighborDiscoveryP.Broadcast -> SimpleSendC;
    // HashmapC is a storage component for neighbor information (up to 20 neighbors)
    components new HashmapC(uint32_t, 22);
    NeighborDiscoveryP.NeighborCache -> HashmapC;

    ///Add as prat of Project 2
    components LinkStateRoutingC;                             
    NeighborDiscoveryP.LinkStateRouting -> LinkStateRoutingC;
    
}*/
#include <Timer.h>
#include "../../includes/CommandMsg.h"
#include "../../includes/packet.h"

configuration NeighborDiscoveryC {
	provides interface NeighborDiscovery;
}
implementation {

	components NeighborDiscoveryP;
	NeighborDiscovery = NeighborDiscoveryP;

	components RandomC as Random;
    NeighborDiscoveryP.Random -> Random;
    
    components new TimerMilliC() as Timer;
    NeighborDiscoveryP.Timer -> Timer;

    components new SimpleSendC(AM_PACK);
    NeighborDiscoveryP.Broadcast -> SimpleSendC;

    components new HashmapC(uint32_t, 22);
    NeighborDiscoveryP.NeighborCache -> HashmapC;

    //components DistanceVectorRoutingC;
    //NeighborDiscoveryP.DistanceVectorRouting -> DistanceVectorRoutingC;

    components LinkStateRoutingC;                              
    NeighborDiscoveryP.LinkStateRouting -> LinkStateRoutingC;
}