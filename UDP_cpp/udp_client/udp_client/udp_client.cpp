// udp_client.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <winsock2.h>
#include<WS2tcpip.h>
#include <iostream>

#pragma comment(lib,"ws2_32.lib")

int main(int argc, char* argv[])
{
	WORD socketVersion = MAKEWORD(2, 2);
	WSADATA wsaData;

	if (WSAStartup(socketVersion, &wsaData) != 0){
		return 0;
	}
	
	SOCKET sclient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8080);
	int len = sizeof(sin);

	if (bind(sclient, (LPSOCKADDR)&sin, sizeof(sin)) == SOCKET_ERROR)
		printf("error!\r\n");

	int i = 0;
	char * sendData = "nop-99999999999999999999999999999999999999999999";

	do {
		inet_pton(AF_INET, "192.168.1.183", (void*)&sin.sin_addr.S_un.S_addr);

		sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);

		char recvData[255];
		int ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);
		if (ret > 0)
		{
			recvData[ret] = 0x00;
			printf(recvData);
		}

		Sleep(100);

		switch(i) {
			case 1: sendData = "rst-";break;
			case 2: sendData = "run-"; break;
			case 3: sendData = "hld-"; break;
			case 4: sendData = "nop-"; break;
			case 5: sendData = "prg-asdsadasdasdasdas"; break;
			case 6: sendData = "run-"; break;
			case 7: sendData = "hld-"; break;
			case 8: sendData = "nop-"; break;
			case 9: sendData = "rst-"; break;
			default:  sendData = "nop-";
		}

		i++;
	} while (i < 10);


	system("pause");
	closesocket(sclient);
	WSACleanup();
	return 0;
}
