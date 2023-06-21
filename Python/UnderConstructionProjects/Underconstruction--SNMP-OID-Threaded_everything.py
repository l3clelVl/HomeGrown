import sys
from pysnmp.hlapi import *
from pysnmp.smi import builder, view

def snmp_walk(community, hostname):
    # Create a MIB tree loader and an SNMP context
    mib_builder = builder.MibBuilder()
    mib_view_controller = view.MibViewController(mib_builder)

    # Load required MIB modules
    mib_builder.loadModules("SNMPv2-MIB", "IF-MIB")

    # Get the root OID of the MIB tree
    mib_tree_root = mib_builder.importSymbols("SNMPv2-MIB", "system")[0]
    print("MIB tree root: ", mib_tree_root)

    oid = ObjectIdentity("SNMPv2-MIB", "system")  # Starting root OID
    oid.resolveWithMib(mib_view_controller)

    while True:
        print("Sending SNMP GETNEXT request for OID: ", oid)

        errorIndication, errorStatus, errorIndex, varBinds = nextCmd(
            SnmpEngine(),
            CommunityData(community),
            UdpTransportTarget((hostname, 161)),
            ContextData(),
            ObjectType(ObjectIdentity(oid)),
            lexicographicMode=False,
            lookupNames=True,
            lookupValues=True
        )

        if errorIndication:
            print(f"SNMP error: {errorIndication}")
            break
        elif errorStatus:
            print(f"SNMP error: {errorStatus.prettyPrint()} at {errorIndex and varBinds[int(errorIndex) - 1][0] or '?'}")
            break
            
def main():
    if len(sys.argv) < 3:
        print("USAGE: python snmpwalk.py <community> <hostname>")
        return

    community = sys.argv[1]
    hostname = sys.argv[2]

    print("Community: ", community)
    print("Hostname: ", hostname)

    snmp_walk(community, hostname)

if __name__ == "__main__":
    main()
