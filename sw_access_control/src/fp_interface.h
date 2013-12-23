#ifndef FP_INTERFACE_H_
#define FP_INTERFACE_H_

void uart_tx_string(chanend c_tx, unsigned char message[]);
void gen_img_cmd(chanend c_tx, char buffer[], unsigned buf_len);
void gen_chtr_file1_from_img_cmd(chanend c_tx, char buffer[], unsigned buf_len);
void gen_chtr_file2_from_img_cmd(chanend c_tx, char buffer[], unsigned buf_len);
void combine_chtr_file_1_2_cmd(chanend c_tx, char buffer[], unsigned buf_len);
void store_templt_cmd(chanend c_tx, char buffer[], unsigned buf_len);

#endif /* FP_INTERFACE_H_ */
