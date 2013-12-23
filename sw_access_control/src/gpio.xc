#include <platform.h>
#include <xs1.h>
#include "xccompat.h"
#include "gpio.h"

void set_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, data))
{
  c_gpio <: APP_HANDLER_SET_GPIO_STATE;
  c_gpio <: data;
}

void get_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, data))
{
  c_gpio <: APP_HANDLER_GET_GPIO_STATE;
  c_gpio :> data;
}
