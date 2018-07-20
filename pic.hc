#include "craft_def.h"
#include "win.h"


inline int cno (int color)
  {switch (color)
     {case blue   : return 0 * max_pics_per_player; break;
      case red    : return 1 * max_pics_per_player; break;
      case yellow : return 2 * max_pics_per_player; break;
      case cyan   : return 3 * max_pics_per_player; break;
      default     : return 0 * max_pics_per_player; break;
     };
  }

int pic_worker_idle  (int color)
  {return xpic_worker_idle + cno (color);
  }

int pic_worker_move  (int color)
  {return xpic_worker_move + cno (color);
  }

int pic_worker_work  (int color)
  {return xpic_worker_work + cno (color);
  }

int pic_worker_sack  (int color) 
  {return xpic_worker_sack + cno (color);
  }

int pic_worker_wood  (int color) 
  {return xpic_worker_wood + cno (color);
  }

int pic_trader_idle  (int color)
  {return xpic_trader_idle + cno (color);
  }

int pic_trader_move  (int color)
  {return xpic_trader_move + cno (color);
  }

int pic_trader_gold  (int color)
  {return xpic_trader_gold + cno (color);
  }

int pic_trader_wood  (int color)
  {return xpic_trader_wood + cno (color);
  }

int pic_knight_idle  (int color)
  {return xpic_knight_idle + cno (color);
  }

int pic_knight_move  (int color)
  {return xpic_knight_move + cno (color);
  }

int pic_knight_fight (int color)
  {return xpic_knight_fight + cno (color);
  }
		    
int pic_pawn_idle    (int color)
  {return xpic_pawn_idle + cno (color);
  }

int pic_pawn_move    (int color) 
  {return xpic_pawn_move + cno (color);
  }

int pic_pawn_fight   (int color)
  {return xpic_pawn_fight + cno (color);
  }

int pic_scout_idle    (int color)
  {return xpic_scout_idle + cno (color);
  }

int pic_scout_move    (int color) 
  {return xpic_scout_move + cno (color);
  }

int pic_scout_hide   (int color)
  {return xpic_scout_hide + cno (color);
  }
		    
int pic_archer_idle  (int color)
  {return xpic_archer_idle + cno (color);
  }

int pic_archer_move  (int color)
  {return xpic_archer_move + cno (color);
  }

int pic_archer_fight (int color)
  {return xpic_archer_fight + cno (color);
  }
		    
int pic_cata_idle    (int color)
  {return xpic_cata_idle + cno (color);
  }

int pic_cata_move    (int color)
  {return xpic_cata_move + cno (color);
  }

int pic_cata_fight   (int color)
  {return xpic_cata_fight + cno (color);
  }
		    
int pic_doktor_idle  (int color)
  {return xpic_doktor_idle + cno (color);
  }

int pic_doktor_move  (int color)
  {return xpic_doktor_move + cno (color);
  }

int pic_doktor_fight (int color)
  {return xpic_doktor_fight + cno (color);
  }
		    
int pic_zombi        (int color)
  {return xpic_zombi + cno (color);
  }

int pic_swim         (int color)
  {return xpic_swim + cno (color);
  }

int pic_ship_idle    (int color)
  {return xpic_ship1_idle + cno (color);
  }

int pic_ship_empty (int color)
  {return xpic_ship1_empty + cno (color);
  }

int pic_ship_move    (int color) 
  {return xpic_ship1_move + cno (color);
  }

int pic_ship_zombi    (int color) 
  {return xpic_ship_zombi + cno (color);
  }

int pic_ship2_idle    (int color)
  {return xpic_ship2_idle + cno (color);
  }

int pic_ship2_empty (int color)
  {return xpic_ship2_empty + cno (color);
  }

int pic_ship2_move    (int color) 
  {return xpic_ship2_move + cno (color);
  }

