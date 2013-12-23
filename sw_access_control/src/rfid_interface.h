#ifndef RFID_INTERFACE_H_
#define RFID_INTERFACE_H_

void init_rfid_tags();
/* Returns -1 if no match is found; else returns a postive integer */
int get_rfid_template_index(char key[], int len);
/* Returns the stored index of the template */
int store_rfid_template(char key[], int len);
/* Deletes a rfid template */
int delete_rfid_template(char key[], int len);

#endif /* RFID_INTERFACE_H_ */
