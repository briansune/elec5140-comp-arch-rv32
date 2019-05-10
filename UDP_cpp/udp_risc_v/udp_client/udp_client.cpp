#include "stdafx.h"

#include <stdio.h>
#include <winsock2.h>
#include <WS2tcpip.h>
#include <iostream>
#include <fstream>
#include <string>
#include <limits>

#pragma comment(lib,"ws2_32.lib")

using namespace std;

typedef enum {
	CMD_NOP = 0,
	CMD_RST,
	CMD_PRG,
	CMD_RUN,
	CMD_HLD,
	CMD_RDRAM,
	CMD_QUIT = 99
}MENU_ID;

void menu_print(void);
char* load_program_to_fpga(int* data_len);

int main(int argc, char* argv[]){

	int timeout = 3000; //3s
	int ret;
	int ret2;
	int len;

	char recvData[255];
	char* sendData = "nop-";

	WORD socketVersion = MAKEWORD(2, 2);
	WSADATA wsaData;

	if (WSAStartup(socketVersion, &wsaData) != 0){
		return 0;
	}
	
	SOCKET sclient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	sockaddr_in sin = {0};
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8080);
	len = sizeof(sin);

	if (bind(sclient, (LPSOCKADDR)&sin, sizeof(sin)) == SOCKET_ERROR) {
		cout << "error!" << endl;
	}
	
	inet_pton(AF_INET, "192.168.1.183", (void*)&sin.sin_addr.S_un.S_addr);

	cout << "Send NOP to 192.168.1.183 and verify FPGA-RISC_V is connected." << endl;
	sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);
	
	cout << "Wait FPGA-RISC_V to response..." << endl;
	ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
	ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

	if (ret == -1) {
		system("pause");
		return 0;
	}

	if (ret > 0){
		recvData[ret] = 0x00;

		string str1(recvData);
		string str2("ack+nop-OK!\r");

		if (str1.compare(str2) != 0) {
			cout << "FPGA-RISC_V LAN OK!" << endl;
		}else {
			system("pause");
			return 0;
		}
	}

	menu_print();

	int cmd_sel = 0;
	int exit_flag = 0;

	char* get_data;
	int data_len;
	char read_dram[5] = { 0 };

	int user_offset = 0;
	bool valid_input = false;

	while (!exit_flag) {

		do {
			cout << "Please select: ";
			cin >> cmd_sel;
		} while ( (cmd_sel > CMD_RDRAM) && (cmd_sel != CMD_QUIT) );
		
		switch (cmd_sel) {
			
			case CMD_NOP:
				sendData = "nop-";
				sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);
				ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
				ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

				if (ret == -1) {
					system("pause");
					return 0;
				}

				if (ret > 0) {
					recvData[ret] = 0x00;

					string str1(recvData);
					string str2("ack+nop-OK!\r");

					if (str1.compare(str2) != 0) {
						cout << "FPGA-RISC_V LAN OK!" << endl;
					}else {
						exit_flag = 1;
					}
				}
				break;

			case CMD_RST:
				sendData = "rst-";
				sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);
				ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
				ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

				if (ret == -1) {
					system("pause");
					return 0;
				}

				if (ret > 0) {
					recvData[ret] = 0x00;

					string str1(recvData);
					string str2("ack+rst-OK!\r");

					if (str1.compare(str2) != 0) {
						cout << "FPGA-RISC_V RESET OK!" << endl;
					}
					else {
						exit_flag = 1;
					}
				}
				break;

			case CMD_PRG:

				get_data = load_program_to_fpga(&data_len);

				if (get_data != NULL) {

					int tot_prog_len = data_len + 4;

					char* prg_header = "prg-";
					char* send_char = new char[tot_prog_len];
					
					send_char[0] = 'p';
					send_char[1] = 'r';
					send_char[2] = 'g';
					send_char[3] = '-';

					for (int i = 4; i < tot_prog_len; i=i+4) {
						send_char[i+0] = get_data[3 + i - 4];
						send_char[i+1] = get_data[2 + i - 4];
						send_char[i+2] = get_data[1 + i - 4];
						send_char[i+3] = get_data[0 + i - 4];
					}

					sendto(sclient, send_char, tot_prog_len, 0, (sockaddr *)&sin, len);
					ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
					ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

					if (ret == -1) {
						system("pause");
						return 0;
					}

					if (ret > 0) {
						recvData[ret] = 0x00;

						string str1(recvData);
						string str2("ack+prg-OK!\r");

						if (str1.compare(str2) != 0) {
							cout << "FPGA-RISC_V PROGRAM OK!" << endl;
						}
						else {
							exit_flag = 1;
						}
					}
				}
				break;

			case CMD_RUN:
				sendData = "run-";
				sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);
				ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
				ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

				if (ret == -1) {
					system("pause");
					return 0;
				}

				if (ret > 0) {
					recvData[ret] = 0x00;

					string str1(recvData);
					string str2("ack+run-OK!\r");

					if (str1.compare(str2) != 0) {
						cout << "FPGA-RISC_V EXECUTE OK!" << endl;
					}
					else {
						exit_flag = 1;
					}
				}
				break;

			case CMD_HLD:
				sendData = "hld-";
				sendto(sclient, sendData, strlen(sendData), 0, (sockaddr *)&sin, len);
				ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
				ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

				if (ret == -1) {
					system("pause");
					return 0;
				}

				if (ret > 0) {
					recvData[ret] = 0x00;

					string str1(recvData);
					string str2("ack+hld-OK!\r");

					if (str1.compare(str2) != 0) {
						cout << "FPGA-RISC_V held OK!" << endl;
					}
					else {
						exit_flag = 1;
					}
				}
				break;

			case CMD_RDRAM:

				
				user_offset = 0;

				do {
					valid_input = true;

					cout << "please enter the memory offset: ";
					cin >> user_offset;

					if (cin.fail()){
						cin.clear();
						cin.ignore();
						cout << "Please enter an Integer only." << endl;
						valid_input = false;
					}

				} while (!valid_input);
				

				user_offset = user_offset % 256;
				
				cout << "User offset entered: " << user_offset << endl;

				read_dram[0] = 'r';
				read_dram[1] = 'd';
				read_dram[2] = 0x00;
				read_dram[3] = user_offset;
				sendto(sclient, read_dram, 4, 0, (sockaddr *)&sin, len);
				ret2 = setsockopt(sclient, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
				ret = recvfrom(sclient, recvData, 255, 0, (sockaddr *)&sin, &len);

				if (ret == -1) {
					system("pause");
					return 0;
				}

				if (ret > 0) {
					recvData[ret] = 0x00;
					
					int i = 0;
					char* buff = new char[ret - 16];

					for (; i < ret - 16; i++) {
						buff[i] = recvData[i];
					}

					int data_res = recvData[i+0] << 24 | recvData[i+1] << 16 | recvData[i+2] << 8 | recvData[i+3];
					std::string s = to_string(data_res);

					cout << "FPGA-RISC_V Read: " << buff << "=>" << s << endl;
				}
				break;

			case CMD_QUIT:
				exit_flag = 1;
				break;
		}
	};

	closesocket(sclient);
	WSACleanup();

	return 0;
}

char* load_program_to_fpga(int* data_len) {

	ifstream bin_file;

	bin_file.open("./fibonacci.bin", ios::binary | ios::ate);

	if (!bin_file.is_open()) {
		return NULL;
	}

	ifstream::pos_type pos = bin_file.tellg();
	int length = pos;
	*data_len = length;

	char *pChars = new char[length];
	bin_file.seekg(0, ios::beg);
	bin_file.read(pChars, length);

	bin_file.close();

	return pChars;
}

void menu_print(void) {

	printf("\r\n");
	printf("=================================\r\n");
	printf("|      select the command #     |\r\n");
	printf("=================================\r\n");
	printf("|                               |\r\n");
	printf("|      0:       NOP             |\r\n");
	printf("|      1:       RESET           |\r\n");
	printf("|      2:       PROGRAM ICACHE  |\r\n");
	printf("|      3:       RUN PROGRAM     |\r\n");
	printf("|      4:       HELD PROGRAM    |\r\n");
	printf("|      5:       READ RESULT     |\r\n");
	printf("|     99:       EXIT            |\r\n");
	printf("|                               |\r\n");
	printf("=================================\r\n");
	printf("\r\n");
}
