/*/ Project 1
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



configuration NodeC{
}
implementation {
    components MainC;
    components Node;
    components new AMReceiverC(AM_PACK) as GeneralReceive;


    Node -> MainC.Boot;
    Node.Receive -> GeneralReceive;
    components ActiveMessageC;
    Node.AMControl -> ActiveMessageC;
    components new SimpleSendC(AM_PACK);
    Node.Sender -> SimpleSendC;
    components CommandHandlerC;
    Node.CommandHandler -> CommandHandlerC;
    // add components for FloodingC
     components FloodingC;
    Node.Flooding -> FloodingC;
    // Adding neighbor discovery as component
    components NeighborDiscoveryC;
    Node.NeighborDiscovery -> NeighborDiscoveryC;
   



}

*/
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
    components new AMReceiverC(AM_PACK) as GeneralReceive;

    Node -> MainC.Boot;
    Node.Receive -> GeneralReceive;
    components ActiveMessageC;
    Node.AMControl -> ActiveMessageC;

    components new SimpleSendC(AM_PACK);
    Node.Sender -> SimpleSendC;

    components CommandHandlerC;
    Node.CommandHandler -> CommandHandlerC;

    // Adding Flooding component
    components FloodingC;
    Node.Flooding -> FloodingC;

    // Adding NeighborDiscovery component
    components NeighborDiscoveryC;
    Node.NeighborDiscovery -> NeighborDiscoveryC;

    // Adding LinkStateRouting component
    
   // components LinkStateRoutingC;
   // Node.LinkStateRouting -> LinkStateRoutingC;

    // Connecting LinkStateRouting to NeighborDiscovery and SimpleSend

    //LinkStateRoutingC.NeighborDiscovery -> NeighborDiscoveryC;
    //LinkStateRoutingC.Broadcast -> SimpleSendC;
}
