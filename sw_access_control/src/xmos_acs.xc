#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <xscope.h>
#include "uart_rx.h"
#include "uart_tx.h"
#include "fP_interface.h"
#include "rfid_interface.h"
#include "xtcp.h"
#include "gpio.h"
#include "tcp_handler.h"
#include "ethernet_board_support.h"
#include "c_utils.h"

#define	FP_MODULE_CORE	0  //GPIO to STAR slot
#define RFID_MODULE_CORE	FP_MODULE_CORE  //Connect to Triangle
#define	ETH_CORE	1
#define	FP_BAUD_RATE	RFID_BAUD_RATE //57600
#define	RFID_BAUD_RATE	9600

on stdcore[FP_MODULE_CORE] : buffered in port:1 p_rx =  XS1_PORT_1G;
on stdcore[FP_MODULE_CORE] : out port p_tx = XS1_PORT_1C;
on stdcore[FP_MODULE_CORE] : port p_led=XS1_PORT_4A;
on stdcore[FP_MODULE_CORE] : port p_button=XS1_PORT_4C;
on stdcore[FP_MODULE_CORE] : out port p_door_ctrl =  XS1_PORT_4D;

on stdcore[RFID_MODULE_CORE] : buffered in port:1 p_rfid_rx =  XS1_PORT_1P; //xnD39

ethernet_xtcp_ports_t xtcp_ports =  {
on stdcore[ETH_CORE] :
             OTP_PORTS_INITIALIZER,
             ETHERNET_DEFAULT_SMI_INIT,
             ETHERNET_DEFAULT_MII_INIT_lite,
             ETHERNET_DEFAULT_RESET_INTERFACE_INIT };

#define	DEBOUNCE_INTERVAL	XS1_TIMER_MHZ*1000
#define	BUTTON_1_PRESS_VALUE	0x2
#define	ARRAY_SIZE(x)	(sizeof(x)/sizeof(x[0]))

unsigned char uart_tx_buffer[64];
unsigned char uart_rx_buffer[64];
unsigned char rfid_uart_rx_buffer[64];
#pragma unsafe arrays
gpio_state_t gpio_state;

#ifdef STATIC_IP
xtcp_ipconfig_t ipconfig = {
  { 172, 17, 0, 139 },
  { 255, 255, 255, 0 },
  { 172, 17, 0, 254 }
};
#else
xtcp_ipconfig_t ipconfig = {
  { 0, 0, 0, 0 }, // ip address (eg 192,168,0,2)
  { 0, 0, 0, 0 }, // netmask (eg 255,255,255,0)
  { 0, 0, 0, 0 } // gateway (eg 192,168,0,1)
};
#endif

void xscope_user_init(void) {
   xscope_register(0, 0, "", 0, "");
   xscope_config_io(XSCOPE_IO_BASIC);
}


void acs_manager(chanend c_tx, chanend c_rx, chanend c_gpio, chanend c_rfid_rx)
{
  int scan_button_flag = 1;
  unsigned button_state_1 = 0;
  unsigned button_state_2 = 0;
  timer t_scan_button_flag;
  unsigned time;
  uart_rx_client_state rx_state;
  char uart_rx_char;
  char msg[5] = "1234";
  char uart_rx_response[50];
  unsigned resp_idx=0;
  unsigned resp_len=0;
  static gen_img = 0;
  int cmd;
  int door_position = 0; //Close
  timer t;
  unsigned do_ts = 0;
  int idx = -1;
  uart_rx_client_state rx_rfid_state;


  printstrln ("Welcome to XMOS access control system");
  uart_rx_init(c_rx, rx_state);
  uart_rx_set_baud_rate(c_rx, rx_state, FP_BAUD_RATE);
  uart_tx_set_baud_rate(c_tx, FP_BAUD_RATE);

  uart_rx_init(c_rfid_rx, rx_rfid_state);
  uart_rx_set_baud_rate(c_rfid_rx, rx_rfid_state, RFID_BAUD_RATE);

  t_scan_button_flag :> time;
  p_button :> button_state_1;
  printstrln ("Starting...");
  t :> do_ts;

  init_rfid_tags();
  str_cpy(uart_rx_response, "^g^^eop^`dsc");
  idx = store_rfid_template(uart_rx_response, 12);
  str_cpy(uart_rx_response, "^g^^eopscpgd");
  idx = store_rfid_template(uart_rx_response, 12);

  while(1) {
    select {
      case scan_button_flag => p_button when pinsneq(button_state_1) :> button_state_1 :
        t_scan_button_flag :> time;
        scan_button_flag = 0;
      break;
      case !scan_button_flag => t_scan_button_flag when timerafter(time + DEBOUNCE_INTERVAL) :> void:
        p_button :> button_state_2;
        if(button_state_1 == button_state_2) {
   	      resp_idx = 0;
   	      resp_len = 0;
       	  switch (button_state_1) {
       	    case 0x0C:
       	      printstrln("Both buttons are pressed");
       	    break;
       	    case 0x0E:
       	      if (gen_img == 0) {
         	    printstrln("Collect img1");
       	    	gen_img_cmd(c_tx, msg, 4);
       	    	resp_len = 12;
       	      }
       	      else if (gen_img == 1) {
         	    printstrln("Generate chtr from img1");
         	    gen_chtr_file1_from_img_cmd(c_tx, msg, 4);
         	    resp_len = 13;
       	      }
       	      else if (gen_img == 2) {
         	    printstrln("Collect img2");
       	    	gen_img_cmd(c_tx, msg, 4);
       	    	resp_len = 12;
       	      }
       	      else if (gen_img == 3) {
         	    printstrln("Generate chtr from img2");
         	    gen_chtr_file2_from_img_cmd(c_tx, msg, 4);
         	    resp_len = 13;
       	      }
       	      else if (gen_img == 4) {
       	    	printstrln("Combine chtr from img1 and img2");
       	    	combine_chtr_file_1_2_cmd(c_tx, msg, 4);
       	    	resp_len = 12;
       	      }
       	      else if (gen_img == 5) {
       	    	printstrln("Store img in flash");
       	    	store_templt_cmd(c_tx, msg, 4);
       	    	resp_len = 12;
       	      }
       	      gen_img++;
       	    break;
       	    case 0x0D:
       	      printstrln("Button 2 pressed");
       	      printstrln("Reseting finger img collection process");
       	      gen_img = 0;
       	    break;
       	    default:
       	    break;
       	  }
        }
        scan_button_flag = 1;
        break;
        //TBR, but flashed code with below segment as active crashes!!!
        case uart_rx_get_byte_byref(c_rx, rx_state, uart_rx_char):
		  //printchar(uart_rx_char+46);
		  uart_rx_response[resp_idx] = uart_rx_char+46;
          resp_idx++;
          if (resp_idx == 12) {
        	  //printstrln("Got RFID tag!!!");
        	  if (get_rfid_template_index(uart_rx_response, 12) >= 0) {
             	  t :> do_ts;
              	  p_led <: 0x0;
              	  p_door_ctrl <: 0b0010;
              	  door_position = 0;
              	  resp_idx = 0;
              	  printstrln("RFID door open is pressed!!!");
        	  }
          }
        break;
        case c_gpio :> cmd:
          switch (cmd) {
            case APP_HANDLER_SET_GPIO_STATE: {
          	gpio_state_t gpio_new_state;

          	c_gpio :> gpio_new_state;

          	if (gpio_new_state.door_position == 1) {//Open the door
          	  t :> do_ts;
          	  p_led <: 0x0;
          	  p_door_ctrl <: 0b0010;
          	  door_position = 0;
          	  printstrln("Door Open is pressed!!!");
          	}
            }
            break;
            case APP_HANDLER_GET_GPIO_STATE:
              c_gpio <: gpio_state;
            break;
          }
        break;

        case uart_rx_get_byte_byref(c_rfid_rx, rx_rfid_state, uart_rx_char):
		  //printchar(uart_rx_char+46);
		  printchar(uart_rx_char);
        break;

        case !door_position => t when timerafter(do_ts + 1000000000) :> void:
          t :> do_ts;
          p_led <: 0xF;
          door_position = 1;
          p_door_ctrl <: 0x0;
          printstrln("Door Closed ;-)");
          break;
    }
  }
}

int main(void)
{
  chan c_xtcp[1];
  chan c_tx;
  chan c_rx;
  chan c_gpio;
  chan c_rfid_rx;

  par {
	on stdcore[ETH_CORE] : ethernet_xtcp_server(xtcp_ports, ipconfig, c_xtcp, 1);
	on stdcore[FP_MODULE_CORE] : tcp_handler(c_xtcp[0], c_gpio);
	//on stdcore[FP_MODULE_CORE] : uart_rx(p_rx, uart_rx_buffer, ARRAY_SIZE(uart_rx_buffer), FP_BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_rx);
	on stdcore[FP_MODULE_CORE] : uart_rx(p_rx, uart_rx_buffer, ARRAY_SIZE(uart_rx_buffer), FP_BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, c_rx);
	on stdcore[FP_MODULE_CORE] : uart_tx(p_tx, uart_tx_buffer, ARRAY_SIZE(uart_tx_buffer), FP_BAUD_RATE, 8, UART_TX_PARITY_EVEN, 1, c_tx);
	on stdcore[FP_MODULE_CORE] : acs_manager(c_tx, c_rx, c_gpio, c_rfid_rx);
	on stdcore[RFID_MODULE_CORE] : uart_rx(p_rfid_rx, rfid_uart_rx_buffer, ARRAY_SIZE(rfid_uart_rx_buffer), RFID_BAUD_RATE, 8, UART_TX_PARITY_NONE, 1, c_rfid_rx);
  }
  return 0;
}
