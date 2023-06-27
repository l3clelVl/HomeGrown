#!usr/bin/python

import socket, re


"""
 This script is for digit indexing
"""


IP = input("What's the IPv4?\n")
Port = input("What's the port?\n")


ServSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ServSocket.connect((IP,int(Port)))
print("\n\n\nGreetings from ", IP, ":", Port, "\n", ServSocket.recv(1024).decode())

print("\nYou're about to see", IP, "further instructions below:")
RawRecv = ServSocket.recv(1024).decode()
print(RawRecv)


print("Below is an analysis of ", IP, "'s instruction")

RecvRawArray = re.findall(r'\d+', RawRecv) 
print("The initial type of array:", type(RecvRawArray)) 
print("The specific data in the array:", RecvRawArray)

############################################################################
"""
Aspiring loop to:
    1) Change all values from class list to class integer
    2) Aside from index 0, assign the list into variables


RecvIntArray = [int(i) for i in RecvRawArray]
print("The converted raw data into integers:", RecvIntArray, "\n")

"""
############################################################################
"""
Values 1 - 3 are extracted into variables to be later mathmaticized
"""
FirstIntVar = int(RecvRawArray[1])
print("\nThe first integer's value:", FirstIntVar)

SecondIntVar = int(RecvRawArray[2])
print("The second integer's value:", SecondIntVar)

ThirdIntVar = int(RecvRawArray[3])
print("The third integer's value:", ThirdIntVar)


"""
Mathmaticize the integers in the variables
"""


ResponseSolution = ((FirstIntVar + SecondIntVar) * ThirdIntVar)
print ("\n", ResponseSolution) 



ServSocket.send(repr(ResponseSolution).encode())
print("\nIncoming flag:", ServSocket.recv(1024).decode())

ServSocket.close()
