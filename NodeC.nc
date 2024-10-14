// Project 1
// CSE 160
// Sep/28/2024
// Zaid Laffta

#include <Timer.h>
#include "includes/command.h"
#include "includes/packet.h"
#include "includes/CommandMsg.h"
#include "includes/sendInfo.h"
#include "includes/channels.h"
#include <string.h>

configuration NodeC {
}
implementation {
    components MainC;
    components Node;
    components LinkStateRoutingC;

    components new AMReceiverC(AM_PACK) as GeneralReceive;

    Node -> MainC.Boot;
    Node.Receive -> GeneralReceive;

    components ActiveMessageC;
    Node.AMControl -> ActiveMessageC;

    components new SimpleSendC(AM_PACK);
    Node.Sender -> SimpleSendC;

    components CommandHandlerC;
    Node.CommandHandler -> CommandHandlerC;

    // Add Flooding component
    components FloodingC;
    Node.Flooding -> FloodingC;

    // Add NeighborDiscovery component
    components NeighborDiscoveryC;
    Node.NeighborDiscovery -> NeighborDiscoveryC;

    // Add LinkStateRouting component
    components LinkStateRoutingC;
    Node.LinkStateRouting -> LinkStateRoutingC;

    // Connecting LinkStateRouting to NeighborDiscovery and SimpleSend
    LinkStateRoutingC.NeighborDiscovery -> NeighborDiscoveryC;
    LinkStateRoutingC.Broadcast -> SimpleSendC;
    
}
