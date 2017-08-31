/************************************************
  Code to read sensors via I2C bus:
       HTU21D(F) - temperature and humidty
            &
       TSL2561 - light
************************************************/
//What libraries do we need?
#include <Wire.h> //the "Wire.h" library is required to use the I2C commands
#include <math.h> //use the "math.h" library so we can compute the base 10 logarithm (for the dew point) 
#include <Adafruit_Sensor.h> //Adafruit unified sensors library
#include <Adafruit_TSL2561_U.h> //light sensor library

Adafruit_TSL2561_Unified tsl = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);

void RequestMeas(int Address, int CommandCode)
{
  Wire.beginTransmission(Address); // The HTU21D will respond to its address
  Wire.write(CommandCode); // request the measurement, ie temperature or humidity
  Wire.endTransmission();
  return;
}
long ReadMeas(int Address)
{
  byte DataHIGH; //The location to store the high measurement byte
  byte DataLOW; //The low measurement byte
  byte CRC; //If you want to compute the CRC feel free to do so.
  long Data; //The temporary memory location we are storing our data in as we receive it from the HTU21D
  Wire.requestFrom(Address, 3); //We are requesting data from the HTU21D and there will be 3x bytes that must be read.
  while (Wire.available()) // Check for data from the HTU21D
  {
    DataHIGH = Wire.read(); // Read high byte
    DataLOW = Wire.read(); // Read low byte
    CRC = Wire.read(); // Read the CRC byte
  }
  Data = DataHIGH; //The data sits in the low byte of 'int Data'.
  Data = Data << 8; //Shift all the bits to the left for 8 bits. The old locations fill with zeros.
  Data = Data + DataLOW; //Now simply add the low byte of data to the int.
  return Data; //return our measurement.
}
//configure TSL2561
void configureSensor(void)
{
  /* You can also manually set the gain or enable auto-gain support  and integration time gives you better sensor resolution (402ms = 16-bit data)*/
  // tsl.setGain(TSL2561_GAIN_1X);      /* No gain ... use in bright light to avoid sensor saturation */
  // tsl.setGain(TSL2561_GAIN_16X);     /* 16x gain ... use in low light to boost sensitivity */
  tsl.enableAutoRange(true);            /* Auto-gain ... switches automatically between 1x and 16x */
  // tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS);   /* fast but low resolution */
  // tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_101MS);  /* medium resolution and speed   */
  tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);  /* 16-bit data but slowest conversions */
}
//setup
void setup()
{
  Wire.begin(); // join i2c bus (address optional for master)
  Serial.begin(9600); // start serial for output
  //Serial.println("TSL2561 ready ...");
  //Serial.println("HTU21D(F) ready ..."); // print "ready" once for every sensor

  /* initialise TSL2561 & setup the sensor gain and integration time*/
  if (!tsl.begin())
  {
    Serial.print("Ooops, no TSL2561 detected ... Check your wiring or I2C ADDR!");
    while (1);
  }
  configureSensor();
}

/********************* We're ready to go! **********************/

//loop
void loop()
{
  /* HTU21D(F) sensor values */

  //Set the address of the HTU21D. This detail is hidden at the bototm of page 10 of the datasheet.
  const int I2C_address = 0x40; // I2C write address.

  const int TempCode = 0xE3; // command for temperature measurement  (see page 11 of datasheet)
  const int HumidCode = 0xE5; // command for humidity measurement (see page 11 of datasheet)

  const float TempCoefficient = -0.15; //temperature compensation coefficient value to guaratnee RH accuracy between 20-80%RH
  const float TempOffset = 0.03; //if exist offset temperature difference vs DS18B20

  const float DewConstA = 8.1332; //constants required to calclulate the partial pressure and dew point (see page 16 of datasheet)
  const float DewConstB = 1762.39;
  const float DewConstC = 235.66;

  long Temperature; //perform our calculation using LONG to prevent overflow at high measuremetn values when using 14bit mode.
  long Humidity;

  float TemperatureFL; //variable to store our final calculated temperature measurement
  float HumidityFL;
  float HumidityCompFL; //%RH value that has been temperature compensated to gurantee performance of +-3% between 20-80%RH
  float PartialPressureFL; //calculated partial pressure in mmHg. used to calculate Dew Point.
  float DewPointFL; //calculated Dew Point in degrees Celsius

  delay(100); // a short delay to let everything stabilise

  while (true) // execute all the instructions in this loop forever
  {
    delay(10); //add a small delay to slow things down

    RequestMeas(I2C_address, TempCode); //request the current temperature
    Temperature = ReadMeas(I2C_address); //read the result

    //We must now convert our temp measurement into an actual proper temperature value (see page 15 of datasheet)
    //Experimentally I observed a litle correction of temperature = TempOffset
    TemperatureFL = -47.75 + 175.72 * (Temperature / pow(2, 16)) + TempOffset;

    delay(10); //add a small delay to slow things down

    RequestMeas(I2C_address, HumidCode); //Request the current humidity
    Humidity = ReadMeas(I2C_address); //read the result

    HumidityFL = -6 + 125 * (Humidity / pow(2, 16));

    //The relative humidty value read from directly from the chip is not the optimised value. we need some compensations (see pages 3, 4 of datasheet)
    HumidityCompFL = HumidityFL + (25 - TemperatureFL) * TempCoefficient;

    //To calculate the dew point, the partial pressure must be determined first (see page 16 of datasheet)
    PartialPressureFL = (DewConstA - (DewConstB / (TemperatureFL + DewConstC)));
    PartialPressureFL = pow(10, PartialPressureFL);

    //Arduino doesn't have a LOG base 10 function. But Arduino can use the AVRLibC libraries, so we'll use the "math.h".
    DewPointFL = (HumidityCompFL * PartialPressureFL / 100); //do the innermost brackets
    DewPointFL = log10(DewPointFL) - DewConstA; //we have calculated the denominator of the equation
    DewPointFL = DewConstB / DewPointFL; //the whole fraction of the equation has been calculated
    DewPointFL = -(DewPointFL + DewConstC); //The whole dew point calculation has been performed

    /* TSL2561 sensor event */
    sensors_event_t event;
    tsl.getEvent(&event);

/******************* NOW PRINTIG ******************************/
/********************** clearing terminal **********************
Serial.write(12); // ASCII for a Form feed (new page)
***************************** or *******************************
Serial.write(27); // ESC
Serial.print("[2J"); // clear screen
Serial.write(27); // ESC
Serial.print("[H"); // cursor to home
****************************** or ******************************
// clear the terminal screen and send the cursor home
Serial.print(27,BYTE); // ESC
Serial.print("[2J"); // clear screen
Serial.print(27,BYTE); // ESC
Serial.print("[H"); // cursor to home
************************* degree symbol ************************
// degree symbol in different approachess
Serial.print((char)176);
****************************** or ******************************
Serial.print("\xb0");
****************************** or ******************************
Serial.print("\xc2\xb0");  // not working in Serial monitor
****************************** or ******************************
Serial.print("\u00b0");
***************************************************************/
//display TSL2561 results - light is measured in lux...

    if (event.light)
    {
      // clering terminal
      Serial.print("Iluminance      ; ");
      delay(10);
      Serial.print(event.light);
      delay(10);
      Serial.println("lux");
      delay(10);
    }
    else
    {
      /* if event.light = 0 lux then the sensor is saturated and no reliable data could be generated! */
      Serial.print("Iluminance      ; ");
      delay(10);
      //Serial.println("0.00");  /* >>> Sensor overload <<< */
      //delay(10);
      //Serial.println("lux");
      Serial.println("Null");  /* >>> Sensor overload <<< */
      delay(10);
    }

//display HTU25D(F) results - temperature and humidity...

    Serial.print("Temperature     ; ");
    delay(10);
    Serial.print(TemperatureFL);
    delay(10);
    Serial.print((char)176);  //Degrees character
    delay(10);
    Serial.println("C");
    delay(10);

    Serial.print("Dew Point       ; ");
    delay(10);
    Serial.print(DewPointFL);
    delay(10);
    Serial.print((char)176);  //Degrees character
    delay(10);
    Serial.println("C");
    delay(10);
    
    Serial.print("Humidity (raw)  ; ");
    delay(10);
    Serial.print(HumidityFL);
    delay(10);
    Serial.println("%RH");
    delay(10);

    Serial.print("Humidity (comp) ; ");
    delay(10);
    Serial.print(HumidityCompFL);
    delay(10);
    Serial.println("%RH");
    delay(10);

    Serial.print("Vapor Pressure  ; ");
    delay(10);
    Serial.print(PartialPressureFL);
    delay(10);
    Serial.println("mmHg");
    delay(10);

    //delay(60000);
    delay(10000);
  }

  return;
}

