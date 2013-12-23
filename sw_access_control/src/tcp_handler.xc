#include "xtcp.h"
#include "web_server.h"

void tcp_handler(chanend c_xtcp, chanend c_gpio) {
  xtcp_connection_t conn;
  web_server_init(c_xtcp, null, null);
  init_web_state(c_gpio);
  while (1) {
    select
      {
      case xtcp_event(c_xtcp,conn):
        web_server_handle_event(c_xtcp, null, null, conn);
        break;
      }
  }
}

