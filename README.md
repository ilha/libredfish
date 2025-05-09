# libRedfish

Copyright 2017-2019 DMTF. All rights reserved.

## About

libRedfish is a C client library that allows for Creation of Entities (POST), Read of Entities (GET), Update of Entities (PATCH), Deletion of Entities (DELETE), running Actions (POST), receiving events, and providing some basic query abilities.

# Installation

## CentOS 7/Redhat Linux 7

1. Add the EPEL repository
```# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm```
2. Install libjansson, libcurl, and libreadline
```# yum install jansson libcurl readline```
3. Download RPM (example only please download latest RPM)
```$ wget https://github.com/DMTF/libredfish/releases/download/1.2.0/libredfish-1.2.0-1.el7.x86_64.rpm```
4. Install the RPM (substititue the file name from the lastest RPM)
```# rpm -ivh libredfish-1.2.0-1.el7.x86_64.rpm```

## CentOS 6/Redhat Linux 6

1. Add the EPEL repository
```# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm```
2. Install libjansson, libcurl, and libreadline
```# yum install jansson libcurl readline```
3. Download RPM (example only please download latest RPM)
```$ wget https://github.com/DMTF/libredfish/releases/download/1.2.0/libredfish-1.2.0-1.el6.x86_64.rpm```
4. Install the RPM (substititue the file name from the lastest RPM)
```# rpm -ivh libredfish-1.2.0-1.el6.x86_64.rpm```

## Ubuntu

1. Install libjansson, libcurl, and libreadline
```apt-get install libjansson4 libcurl4 libreadline7```
2. Download Debian Package
3. Install Debian Package
```#dpkg -i libredfish-1.2.0-1.x86_64.deb```

## Other OS/Distro

Compile from source, see below.

# Compilation

## Pre-requisists

libRedfish is based on C and the compiling system is required to have:
* CMake
* C Compiler
* libjansson - http://www.digip.org/jansson/
* libcurl - https://curl.haxx.se/libcurl/
To receive events a user needs an existing webserver supporting FastCGI (such as Apache or nginx) and libczmq (https://github.com/zeromq/czmq).

## Build

Run cmake.

# RedPath

libRedfish uses a query language based on XPath (https://www.w3.org/TR/1999/REC-xpath-19991116/). This library and query language essentially treat the entire Redfish Service like it was a single JSON document. In other words whenever it encounters an @odata.id it will retrieve the new document (if needed).

| Expression        | Description                                                                                                    |
| ----------------- | -------------------------------------------------------------------------------------------------------------- |
| *nodename*        | Selects the JSON entity with the name "nodename"                                                               |
| /                 | Selects from the root node                                                                                     |
| [*index*]         | Selects the index number JSON entity from an array or object. For arrays, the index is 0-based.                |
| [last()]          | Selects the last index number JSON entity from an array or object                                              |
| [*nodename*]      | Selects all the elements from an array or object that contain a property named "nodename"                      |
| [*name*=*value*]  | Selects all the elements from an array or object where the property "name" is equal to "value"                 |
| [*name*<*value*]  | Selects all the elements from an array or object where the property "name" is less than "value"                |
| [*name*<=*value*] | Selects all the elements from an array or object where the property "name" is less than or equal to "value"    |
| [*name*>*value*]  | Selects all the elements from an array or object where the property "name" is greater than "value"             |
| [*name*>=*value*] | Selects all the elements from an array or object where the property "name" is greater than or equal to "value" |
| [*name*!=*value*] | Selects all the elements from an array or object where the property "name" does not equal "value"              |
| [*]               | Selects all the elements from an array or object                                                               |
| [*node*.*child*]  | Selects all the elements from an array or object that contain a property named "node" which contains "child"   |

Some examples:

* /Chassis[0] - Will return the first Chassis instance
* /Chassis[SKU=1234] - Will return all Chassis instances with a SKU field equal to 1234
* /Systems[Storage] - Will return all the System instances that have Storage field populated
* /Systems[*] - Will return all the System instances
* /SessionService/Sessions[last()] - Will return the last Session instance
* /Chassis[Location.Info] - Will return all the Chassis instances that have a Location field and a Info subfield of Location
* /Systems[Status.Health=OK] - Will return all System instances that have a Health of OK

# C Example

```C
#include <redfish.h>
#include <stdio.h>

int main(int argc, char** argv)
{
    redfishService* service = createRedfishServiceEnumerator(argv[1], NULL, NULL, 0);
    redfishPayload* payload = getPayloadByPath(service, argv[2]);
    char* payloadStr = payloadToString(payload, true);
    printf("Payload Value = %s\n", payloadStr);
    free(payloadStr);
    cleanupPayload(payload);
    cleanupEnumerator(service);
}
```

# Building the redfishcli container

To build, cd into the project root directory and execute:

```
docker build -f redfishcli.Dockerfile -t redfishcli:latest .
```

To run the CLI:

```
docker run -it --rm redfishcli --help                  
Usage: /usr/local/bin/redfishcli [OPTIONS] [Query]

Test libRedfish.

Mandatory arguments to long options are mandatory for short options too.
  -?, --help                 Display this usage message
  -V, --version              Display the software version
  -H, --host                 The host to query
  -v, --verbose              Log more information
  -T, --token [bearer token] A bearer token to use instead of standard redfish auth
  -u, --username [user]      The username to authenticate with
  -p, --password [pass]      The password to authenticate with
  -S, --session              Use session based auth, as opposed to basic auth
Report bugs on GitHub: https://github.com/DMTF/libredfish/issues
```

Example of connecting to a service running on localhost, port 8081

```
docker run -it --rm redfishcli -H http://localhost:8081     
createServiceEnumerator: Entered. host = http://localhost:8081, rootUri = (null), auth = (nil), flags = 0
...
/>
```


## Examples of redfishcli queries

Queries based on attribute value
```
/> cd Chassis[Id=Enclosure]
...

/Chassis[Id=Enclosure]> cat .
{
  "@odata.id": "/redfish/v1/Chassis/Enclosure",
  "@odata.type": "#Chassis.v1_24_0.Chassis",
...
}

/> cd Chassis[Location.PartLocation.LocationOrdinalValue=1]
...
/Chassis[Location.PartLocation.LocationOrdinalValue=1]> cat .
{
  "@odata.id": "/redfish/v1/Chassis/Iom1",
  "@odata.type": "#Chassis.v1_24_0.Chassis",
  ...
}

/> cd Chassis[Location.PartLocation.LocationType=Bay and Location.PartLocation.LocationOrdinalValue=1]
This does not work as epxected, it ignores the and condition
```

Queries based on array position
```
/> cd Chassis[1]
/Chassis[1]> cat .
{
  "@odata.id": "/redfish/v1/Chassis/Enclosure",
  "@odata.type": "#Chassis.v1_24_0.Chassis",
  ...
}
```

## Release Process

1. Go to the "Actions" page
2. Select the "Release and Publish" workflow
3. Click "Run workflow"
4. Fill out the form
5. Click "Run workflow"
