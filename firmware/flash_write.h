#ifndef _MAPLE_FLASH_H
#define _MAPLE_FLASH_H

void flash_unlock();
void flash_lock();
bool flash_erase_page(unsigned int pageAddr);
bool flash_write_word(unsigned int addr, unsigned int word);
void flash_read(unsigned int addr, void *data, unsigned int size);
void flash_write(unsigned int addr, void *data, unsigned int size);

#endif
