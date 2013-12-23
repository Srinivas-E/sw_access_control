#ifndef GPIO_H_
#define GPIO_H_

typedef struct gpio_state {
  int door_position;
} gpio_state_t;

typedef enum gpio_cmd_t {
  APP_HANDLER_SET_GPIO_STATE,
  APP_HANDLER_GET_GPIO_STATE,
} gpio_cmd_t;

void set_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, data));
void get_gpio_state(chanend c_gpio, REFERENCE_PARAM(gpio_state_t, data));

#endif /* GPIO_H_ */
