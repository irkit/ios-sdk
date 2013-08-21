#ifndef __IRPACKER_CONFIG_H__
#define __IRPACKER_CONFIG_H__

// arduino doesn't have enough memory to handle packing
#ifndef ARDUINO
# define IRPACKER_SUPPORTS_PACK 1
#endif

#endif
