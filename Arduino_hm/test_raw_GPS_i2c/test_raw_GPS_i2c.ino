#include <Wire.h> //Needed for I2C to GPS

#include "SparkFun_Ublox_Arduino_Library.h" 
//Click here to get the library: http://librarymanager/All#SparkFun_Ublox_GPS

SFE_UBLOX_GPS myGPS;


void scanner()
{
  // Scan only valid addresses (8 to 0x7B)
  // 0x00 - Reserved - General Call Address
  // 0x01 - Reserved for CBUS Compatibility
  // 0x02 - Reserved for I2C-compatible Bus Variants
  // 0x03 - Reserved for Future Use
  // 0x04, 0x05, 0x06, 0x07 - Reserved for Hs-mode Master
  // 0x78 0x79 0x7A 0x7B - Reserved for 10-bit I2C Addressing
  // 0x7C 0x7D 0x7E 0x7F - Reserved for Future Purposes
    
  int result;
  byte devices = 0; // for consistency of Arduino programming style, the byte data type is to be preferred rather than unsigned char.
  byte ad;

  for (ad=0;ad<0x7C;ad++){
    if (ad>7){ 
      // skip address from 0 to 7
      Wire.beginTransmission(ad);          // start transmission
      delay(10);
      result = Wire.endTransmission();     // end transmission and store answer
      // 0:success
      // 1:data too long to fit in transmit buffer
      // 2:received NACK on transmit of address
      // 3:received NACK on transmit of data
      // 4:other error
      if (!result){
        devices++;                         // operator returns either 0 or 1, depending on whether the input is non-zero or 0 respectively. Add a device to the count if ACK
        Serial.print(ad<16?"0x0":"0x");
        Serial.println(ad,HEX);
        }
      }
    }
  Serial.print(devices, DEC);
  Serial.print(" device");
  Serial.print(devices>1?"s":"");
  Serial.println(" found on the bus");
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void setup()
{
  // Initialization of communication
  Serial.begin(115200);
  Serial.println("SparkFun Ublox Example");
  Wire.begin();

  // I2C scanning procedure
  Serial.println("---Scan---");
  scanner();
  Serial.println();
  delay(500);

  // Is GPS here?
  if (myGPS.begin() == false)
  {
    Serial.println(F("Ublox GPS not detected at default I2C address. Please check wiring. Freezing."));
    while (1);
  }

  //This will pipe all NMEA sentences to the serial port so we can see them
  myGPS.setNMEAOutputPort(Serial);
}


void loop()
{
  myGPS.checkUblox(); //See if new data is available. Process bytes as they come in.

  delay(250); //Don't pound too hard on the I2C bus
}
