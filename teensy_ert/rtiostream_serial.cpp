/*
 * File: rtiostream_serial.cpp
 */

#include "Arduino.h"

extern "C" {
#include "rtiostream.h"
}

/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: rtIOStreamOpen =================================================
 * Abstract:
 *  Open the connection with the target.
 */
int rtIOStreamOpen(int argc, void * argv[])
{    
    Serial.begin(4000000);

    return RTIOSTREAM_NO_ERROR;
}

/* Function: rtIOStreamSend =====================================================
 * Abstract:
 *  Sends the specified number of bytes on the serial line. Returns the number of
 *  bytes sent (if successful) or a negative value if an error occurred.
 */
int rtIOStreamSend(
    int          streamID,
    const void * src,
    size_t       size,
    size_t     * sizeSent)
{
    Serial.write( (const uint8_t *)src, (int16_t)size);
    *sizeSent = size;
    return RTIOSTREAM_NO_ERROR;
}

/* Function: rtIOStreamRecv ================================================
 * Abstract: receive data
 *
 */
int rtIOStreamRecv(
    int      streamID,
    void   * dst,
    size_t   size,
    size_t * sizeRecvd)
{
    int data;
    uint8_t *ptr = (uint8_t *)dst;

    *sizeRecvd=0U;

    while ((*sizeRecvd < size)) {
        data = Serial.read();
        if (data != -1) {
            *ptr++ = (uint8_t) data;
            (*sizeRecvd)++;
        }
    }
    return RTIOSTREAM_NO_ERROR;
}

/* Function: rtIOStreamClose ================================================
 * Abstract: close the connection.
 *
 */
int rtIOStreamClose(int streamID)
{
    return RTIOSTREAM_NO_ERROR;
}
