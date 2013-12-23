/* Mainly implements parse functions to manage active rfid tag keys */

#define NUMBER_OF_RFID_TAGS		20
#define RFID_TAG_LEN			20

char rfid_tags[NUMBER_OF_RFID_TAGS][RFID_TAG_LEN];

void init_rfid_tags()
{
  for (int i=0; i<NUMBER_OF_RFID_TAGS; i++) {
	rfid_tags[i][0] = 'u';
  }
}

/* Returns -1 if no match is found; else returns a postive integer */
int get_rfid_template_index(char key[], int len)
{
  int match = 0;
  for (int i=0; i<NUMBER_OF_RFID_TAGS; i++) {
	match = 0;
	for (int j=0; j<len; j++) {
		if (rfid_tags[i][j] == key[j])
		  match++;
	}
	if (match == len)
	  return i;
  }
  return -1;
}

/* Returns the stored index of the template */
int store_rfid_template(char key[], int len)
{
  for (int i=0; i<NUMBER_OF_RFID_TAGS; i++) {
	if (rfid_tags[i][0] == 'u') {
	  for (int j=0; j<len; j++) {
		rfid_tags[i][j] = key[j];
	  }
	  return i;
	}
  }
  return -1;
}

/* Deletes a rfid template */
int delete_rfid_template(char key[], int len)
{
  int index = -1;
  int match = 0;
  for (int i=0; i<NUMBER_OF_RFID_TAGS; i++) {
	match = 0;
	for (int j=0; j<len; j++) {
		if (rfid_tags[i][j] == key[j])
		  match++;
	}
	if (match == len) {
	  rfid_tags[i][0] = 'u';
	  return i;
	}
  }
  return -1;
}
