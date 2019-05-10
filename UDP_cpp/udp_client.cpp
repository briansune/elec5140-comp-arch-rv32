// udp_client.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <winsock2.h>
#include<WS2tcpip.h>

#pragma comment(lib,"ws2_32.lib")

int main(int argc, char* argv[])
{
	WORD socketVersion = MAKEWORD(2, 2);
	WSADATA wsaData;
	if (WSAStartup(socketVersion, &wsaData) != 0)
	{
		return 0;
	}
	SOCKET sclient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

	sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8080);

	inet_pton(AF_INET, "192.168.1.49", (void*)&sin.sin_addr.S_un.S_addr);

	int len = sizeof(sin);

	const char * sendData = "from client.\n";
	sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);

	char recvData[255];
	int ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);
	if (ret > 0)
	{
		recvData[ret] = 0x00;
		printf(recvData);
	}
	system("pause");
	closesocket(sclient);
	WSACleanup();
	return 0;
}
