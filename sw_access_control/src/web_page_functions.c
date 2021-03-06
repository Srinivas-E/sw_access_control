// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "simplefs.h"
#include "gpio.h"
#include "web_server.h"
#include <stdlib.h>
#include <string.h>
#include "xccompat.h"

typedef struct app_state_t {
  chanend c_gpio;
  gpio_state_t gpio_data;
} app_state_t;

static app_state_t app_state;

void init_web_state(chanend c_gpio) {
  app_state.c_gpio = c_gpio;
  web_server_set_app_state((int) &app_state);
}

int process_web_page_data(char buf[], int app_state, int connection_state)
{
  char * user_choice;
  chanend c_gpio = (chanend) ((app_state_t *) app_state)->c_gpio;

  if (!web_server_is_post(connection_state))
    return 0;

  user_choice = web_server_get_param("l0", connection_state);
  if (!user_choice || !(*user_choice)) {
    char selstr[] = "Error in parsing web page variables";
    strcpy(buf, selstr);
    return strlen(selstr);
  } else
	((app_state_t *) app_state)->gpio_data.door_position = atoi(user_choice);

  /* Send web page request to acs_handler to send door requests */
  set_gpio_state(c_gpio, &((app_state_t *) app_state)->gpio_data);

  get_gpio_state(c_gpio, &((app_state_t *) app_state)->gpio_data);

  return 0;
}

int get_web_user_selection(char buf[],
		int app_state,
		int connection_state,
		int selected_value,
		int ui_param)
{
  int select_flag = 0;
  switch (ui_param) {
  case 1:
	if (((app_state_t *) app_state)->gpio_data.door_position == selected_value)
	  select_flag = 1;
  break;
  default:
  break;
  }
  if (select_flag) {
	char selstr[] = "checked";
	strcpy(buf, selstr);
	return strlen(selstr);
  } else
	return 0;
}
