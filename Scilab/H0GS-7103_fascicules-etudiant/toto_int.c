/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_Fz short int
# define int_32_Fz long int
  const int_16_Fz coeffs_16bits_Fz[15]={
       32732 /*  cel +1:  -a1.2^14 */
       ,-16361 /*  cel +1:  -a2.2^14 */
       ,14132 /*  cel +1:  b0.2^16 */
       ,-28163 /*  cel +1:  b1.2^16 */
       ,14132 /*  cel +1:  b2.2^16 */
       ,32644 /*  cel +2:  -a1.2^14 */
       ,-16271 /*  cel +2:  -a2.2^14 */
       ,14073 /*  cel +2:  b0.2^16 */
       ,-28127 /*  cel +2:  b1.2^16 */
       ,14073 /*  cel +2:  b2.2^16 */
       ,32467 /*  cel +3:  -a1.2^14 */
       ,-16086 /*  cel +3:  -a2.2^14 */
       ,13994 /*  cel +3:  b0.2^16 */
       ,-27973 /*  cel +3:  b1.2^16 */
       ,13994 /*  cel +3:  b2.2^16 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_Fz *coeffs;
      int_32_Fz *states;
    }s_16bits_filter_Fz;
    typedef s_16bits_filter_Fz *p_16bits_filter_Fz;
  /* creator of structure p_16bits_filter_Fz */
    p_16bits_filter_Fz new_16bits_filter_Fz() {
      p_16bits_filter_Fz p_Fz;
      p_Fz = (s_16bits_filter_Fz *) malloc(sizeof(s_16bits_filter_Fz));
      int_32_Fz *states;
      int is;
      p_Fz->nb_coeffs=15;
      p_Fz->nb_states=6;
      p_Fz->coeffs=(int_16_Fz *)&(coeffs_16bits_Fz[0]);
      states =(int_32_Fz *) malloc(6 * sizeof(int_32_Fz));
      p_Fz->states = states;
      for (is=0;is<6;is++) {
        *(states++)=0;
      }
      return p_Fz;
    } /* p_16bits_filter_Fz new_16bits_filter_Fz()  */
  /* destructor of structure p_16bits_filter_Fz */
    void  destroy_16bits_filter_Fz(p_16bits_filter_Fz p_Fz) {
      free((void *) (p_Fz->states) ); /* release memory allocated for states */
      free((void *)p_Fz) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_Fz(p_16bits_filter_Fz p_Fz) */
  int_32_Fz one_step_16bits_filter_Fz(int_16_Fz en_16 , p_16bits_filter_Fz p_Fz) {
    int_16_Fz *coeffs;
    int_32_Fz *states;
    coeffs=p_Fz->coeffs;
    states=p_Fz->states;
    int_16_Fz vn_16;
    int_16_Fz x1_16;
    int_16_Fz x2_16;
    int_32_Fz en_32;
    en_32 = (int_32_Fz) en_16 ;
    /* code of cel 1 */
    en_32=en_32>>1; /* en<-en<<L+LA ,L=-15,LA=14*/
    x1_16= (int_16_Fz)(* states ); /* init x1 */
    x2_16= (int_16_Fz)(* (states+1)); /* init x2 */
    en_32+=32732*x1_16; /* en<-en - a1 . x1 */
    en_32+=-16361*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_Fz)(en_32>>14); /* vn<-en >> LA */
    en_32=14132*vn_16; /* en<-b0 . vn */
    en_32+=-28163*x1_16; /* en<-en +b1 . x1  */
    en_32+=14132*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_Fz)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_Fz)x1_16; /* x2=x1  */
    states++;
    /* code of cel 2 */
    en_32=en_32>>5; /* en<-en<<L+LA ,L=-19,LA=14*/
    x1_16= (int_16_Fz)(* states ); /* init x1 */
    x2_16= (int_16_Fz)(* (states+1)); /* init x2 */
    en_32+=32644*x1_16; /* en<-en - a1 . x1 */
    en_32+=-16271*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_Fz)(en_32>>14); /* vn<-en >> LA */
    en_32=14073*vn_16; /* en<-b0 . vn */
    en_32+=-28127*x1_16; /* en<-en +b1 . x1  */
    en_32+=14073*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_Fz)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_Fz)x1_16; /* x2=x1  */
    states++;
    /* code of cel 3 */
    x1_16= (int_16_Fz)(* states ); /* init x1 */
    x2_16= (int_16_Fz)(* (states+1)); /* init x2 */
    en_32+=32467*x1_16; /* en<-en - a1 . x1 */
    en_32+=-16086*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_Fz)(en_32>>14); /* vn<-en >> LA */
    en_32=13994*vn_16; /* en<-b0 . vn */
    en_32+=-27973*x1_16; /* en<-en +b1 . x1  */
    en_32+=13994*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_Fz)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_Fz)x1_16; /* x2=x1  */
    states++;
     /* scale global output */
    return  ( en_32) ;
  } /*  one_step_16bits_filter_Fz(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_Fz(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_Fz en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_Fz p_Fz=new_16bits_filter_Fz();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_Fz) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_Fz(en_16 , p_Fz) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_Fz(p_Fz) ;
    } /* void teste_16bits_filter_Fz(void)  */
