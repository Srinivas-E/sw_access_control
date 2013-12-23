#include "uart_tx.h"
#include <print.h>

void uart_tx_string(chanend c_tx, unsigned char message[])
{
  int i=0;
  while(message[i]!='\0')
	{
		uart_tx_send_byte(c_tx,message[i]); //send data to uart byte by byte
		i++;
	}
}

void gen_img_cmd(chanend c_tx, char buffer[], unsigned buf_len)
{
  unsigned char cmd[] = {0xEF, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x00, 0x03, 0x01, 0x00, 0x05, '#'};
  int i = 0;
  while (cmd[i] != '#') {
    uart_tx_send_byte(c_tx, cmd[i]);
    i++;
  }
}

void gen_chtr_file1_from_img_cmd(chanend c_tx, char buffer[], unsigned buf_len)
{
  uart_tx_send_byte(c_tx,0xEF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x04);
  uart_tx_send_byte(c_tx,0x02);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x08);
}

void gen_chtr_file2_from_img_cmd(chanend c_tx, char buffer[], unsigned buf_len)
{
  uart_tx_send_byte(c_tx,0xEF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x04);
  uart_tx_send_byte(c_tx,0x02);
  uart_tx_send_byte(c_tx,0x02);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x09);
}

void combine_chtr_file_1_2_cmd(chanend c_tx, char buffer[], unsigned buf_len)
{
  uart_tx_send_byte(c_tx,0xEF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x03);
  uart_tx_send_byte(c_tx,0x05);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x09);
}

void store_templt_cmd(chanend c_tx, char buffer[], unsigned buf_len)
{
  static int fpid = 0x10;

  uart_tx_send_byte(c_tx,0xEF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0xFF);
  uart_tx_send_byte(c_tx,0x01);
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x06);
  uart_tx_send_byte(c_tx,0x06);
  uart_tx_send_byte(c_tx,0x02);
  /*Flash page-id*/
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,(fpid+0x1));
  /* checksum*/
  uart_tx_send_byte(c_tx,0x00);
  uart_tx_send_byte(c_tx,0x1F);
}

