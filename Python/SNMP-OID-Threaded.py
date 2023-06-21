import subprocess
import threading

def run_snmpwalk(oid):
    output_file = f"output_{oid.replace('.', '_')}.txt"
    command = f"snmpwalk -t 10 -Oa -v2c -c public 192.168.241.151 {oid} > {output_file}"
    subprocess.run(command, shell=True)
    print(f"Finished OID {oid}")

oids = [
    "1.3.6.1.2.1.25.1.6.0",
    "1.3.6.1.2.1.25.4.2.1.2",
    "1.3.6.1.2.1.25.4.2.1.4",
    "1.3.6.1.2.1.25.2.3.1.4",
    "1.3.6.1.2.1.25.6.3.1.2",
    "1.3.6.1.4.1.77.1.2.25",
    "1.3.6.1.2.1.6.13.1.3",
    "1.3.6.1.2.1.2.2.1.2",
    "1.3.6.1.2.1.31.1.1.1.1",
    "1.3.6.1.2.1.31.1.1.1.18"
]

threads = []
for oid in oids:
    thread = threading.Thread(target=run_snmpwalk, args=(oid,))
    threads.append(thread)
    thread.start()

# Wait for all threads to complete
for thread in threads:
    thread.join()
