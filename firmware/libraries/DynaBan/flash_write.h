#ifndef _MAPLE_FLASH_H
#define _MAPLE_FLASH_H

void flashUnlock();
void flashLock();
bool flashErasePage(unsigned int pageAddr);
bool flashWriteWord(unsigned int addr, unsigned int word);
void flashRead(unsigned int addr, void *data, unsigned int size);
void flashWrite(unsigned int addr, void *data, unsigned int size);

#endif
