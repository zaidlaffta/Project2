

#ifndef PACKET_H
#define PACKET_H

#include "protocol.h"
#include "channels.h"

// Define constants related to packet structure
enum {
    AM_PACK = 6,  // Active Message type for packets
    PACKET_HEADER_LENGTH = 8,
    PACKET_MAX_PAYLOAD_SIZE = 28 - PACKET_HEADER_LENGTH,
    MAX_TTL = 15
};

// Packet structure
typedef nx_struct pack {
    nx_uint16_t dest;
    nx_uint16_t src;
    nx_uint16_t seq;  // Sequence Number
    nx_uint8_t TTL;   // Time to Live
    nx_uint8_t protocol;
    nx_uint8_t payload[PACKET_MAX_PAYLOAD_SIZE];
} pack;

/*
 * logPack
 * Sends packet information to the general channel.
 * @param:
 *   pack *input = pack to be printed.
 */
void logPack(pack *input) {
    dbg(GENERAL_CHANNEL, "Src: %hhu Dest: %hhu Seq: %hhu TTL: %hhu Protocol: %hhu Payload: %s\n",
        input->src, input->dest, input->seq, input->TTL, input->protocol, input->payload);
}

#endif /* PACKET_H */
