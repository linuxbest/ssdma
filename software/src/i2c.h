#ifndef _I2C_H
#define _I2C_H

//#define DEBUG(x) x
#define DEBUG(x)

int i2cInit();
int i2cCleanUp();
void i2cSetDelay(int delay);

void i2cStart();
void i2cStop();

int i2cSendByte(int byte);
int i2cReadByte(int ackControl);

enum { EXPECT_ACK, SEND_ACK, SEND_NACK };

#endif
