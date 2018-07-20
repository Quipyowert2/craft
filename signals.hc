#include "signals.h"

void set_interrupt (int indicator, void (*handler)())
  {signal (indicator, (*handler));
  }
