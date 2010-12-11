/*
 *
 * BeamBreakIt: A simple Arduino based application that integrates a
 *              pair of beam break sensors with a Ruby on Rails
 *              application via a REST API.
 *
 * Copyright (C) 2010 Georg Kaindl (http://gkaindl.com)
 * Copyright (C) 2010 Crossroads Foundation Limited
 *                    <itdept@crossroads.org.hk>
 *
 * This program is based on the SynchronousDHCP and SynchronousDNS
 * example programs provided as part of the EthernetDHCP and
 * EthernteDNS libraries.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with EthernetDHCP. If not, see
 * <http://www.gnu.org/licenses/>.
 */

#include <Ethernet.h>
#include <EthernetDNS.h>
#include <EthernetDHCP.h>
#include <AdvButton.h>
#include <ButtonManager.h>

/*
 * Global Constants:
 * ipAddr:      IP address of the Ethernet shield.
 * gatewayAddr: IP address of default gateway.
 * dnsAddr:     IP address of DNS server.
 */ 

const byte * ipAddr      = NULL;
const byte * gatewayAddr = NULL;
const byte * dnsAddr     = NULL;

/*
 * MAC Address of Ethernet shield. Replace with the MAC address
 * written on the sticker attached to the base of the shield!
 */

byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x0E, 0x00 };

void setup() {

  /*
   * Set up the serial port for logging.
   */  
  Serial.begin(9600);
  
  /* 
   * Obtain a DHCP lease. Note that this call will block until a
   * valid address is obtained.
   */

  Serial.println("Attempting to obtain a DHCP lease...");
  EthernetDHCP.begin(mac);

  /*
   * Retrieve the IP address of the shield, the gateway and the
   * DNS server from the DHCP library.
   */
   
  ipAddr      = EthernetDHCP.ipAddress();
  gatewayAddr = EthernetDHCP.gatewayIpAddress();
  dnsAddr     = EthernetDHCP.dnsIpAddress();

  /*
   * Dump debugging information to the serial console.
   */

  Serial.println("A DHCP lease has been obtained:");
  Serial.print("  IP Address: ");
  Serial.println(ip_to_str(ipAddr));
  Serial.print("  Gateway Address:");
  Serial.println(ip_to_str(gatewayAddr));
  Serial.print("  DNS Server Address:");
  Serial.println(ip_to_str(dnsAddr));

  /*
   * Initialise the DNS library with the DNS server address returned
   * from the previous DHCP request.
   */
  EthernetDNS.setDNSServer(dnsAddr);

}

void loop() {

  byte serverAddr[4];
  
  DNSError err = EthernetDNS.resolveHostName("www.globalhand.org", serverAddr);
  
  /*
   * Finally, we have a result. We're just handling the most common
   * errors  here (success, timed out, not found) and just print others
   * as an integer. A full listing of possible errors codes is available
   * in EthernetDNS.h
   */
  if (err == DNSSuccess) {
    Serial.print("The IP address is: ");
    Serial.println(ip_to_str(ipAddr));
  } else if (err == DNSTimedOut) {
    Serial.println("DNS query timed out");
  } else if (err == DNSNotFound) {
    Serial.println("DNS name does not exist");
  } else {
    Serial.print("Failed with error code: ");
    Serial.println((int)err, DEC);
  }
 
  /*
   * Periodically maintain the DHCP lease.
   */
  EthernetDHCP.maintain();
  
}

/*
 * Nicely format an IP address.
 */

const char* ip_to_str(const uint8_t* ipAddr) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}
