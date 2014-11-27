/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_band_pass short int
# define int_32_band_pass long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_band_pass coeffs_16bits_band_pass[31]={
       0 /* no init of cel 1 wich has zero gain*/
       ,14058 /*  cel +2:  -a1.2^13 */
       ,-18837 /*  cel +2:  -a2.2^13 */
       ,22797 /*  cel +2:  b1.2^18, note that b0=0 */
       ,-8059 /*  cel +2:  b2.2^18 */
       ,30623 /*  cel +3:  -a1.2^14 */
       ,-30589 /*  cel +3:  -a2.2^14 */
       ,15337 /*  cel +3:  b1.2^18, note that b0=0 */
       ,-26497 /*  cel +3:  b2.2^18 */
       ,26666 /*  cel +4:  -a1.2^14 */
       ,-30649 /*  cel +4:  -a2.2^14 */
       ,-24271 /*  cel +4:  b1.2^17, note that b0=0 */
       ,-3800 /*  cel +4:  b2.2^17 */
       ,27888 /*  cel +5:  -a1.2^14 */
       ,-32083 /*  cel +5:  -a2.2^14 */
       ,-7001 /*  cel +5:  b1.2^16, note that b0=0 */
       ,22379 /*  cel +5:  b2.2^16 */
       ,27007 /*  cel +6:  -a1.2^14 */
       ,-23817 /*  cel +6:  -a2.2^14 */
       ,17195 /*  cel +6:  b1.2^17, note that b0=0 */
       ,17713 /*  cel +6:  b2.2^17 */
       ,12210 /*  cel +7:  -a1.2^13 */
       ,-19800 /*  cel +7:  -a2.2^13 */
       ,-578 /*  cel +7:  b1.2^15, note that b0=0 */
       ,-20765 /*  cel +7:  b2.2^15 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_band_pass *coeffs;
      int_32_band_pass *states;
    }s_16bits_filter_band_pass;
    typedef s_16bits_filter_band_pass *p_16bits_filter_band_pass;
  /* creator of structure p_16bits_filter_band_pass */
    p_16bits_filter_band_pass new_16bits_filter_band_pass() {
      p_16bits_filter_band_pass p_band_pass;
      p_band_pass = (s_16bits_filter_band_pass *) malloc(sizeof(s_16bits_filter_band_pass));
      int_32_band_pass *states;
      int is;
      p_band_pass->nb_coeffs=31;
      p_band_pass->nb_states=12;
      p_band_pass->coeffs=(int_16_band_pass *)&(coeffs_16bits_band_pass[0]);
      states =(int_32_band_pass *) malloc(12 * sizeof(int_32_band_pass));
      p_band_pass->states = states;
      for (is=0;is<12;is++) {
        *(states++)=0;
      }
      return p_band_pass;
    } /* p_16bits_filter_band_pass new_16bits_filter_band_pass()  */
  /* destructor of structure p_16bits_filter_band_pass */
    void  destroy_16bits_filter_band_pass(p_16bits_filter_band_pass p_band_pass) {
      free((void *) (p_band_pass->states) ); /* release memory allocated for states */
      free((void *)p_band_pass) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_band_pass(p_16bits_filter_band_pass p_band_pass) */
  int_32_band_pass one_step_16bits_filter_band_pass(int_16_band_pass en_16 , p_16bits_filter_band_pass p_band_pass) {
    int_16_band_pass *coeffs;
    int_32_band_pass *states;
    coeffs=p_band_pass->coeffs;
    states=p_band_pass->states;
    int_16_band_pass vn_16;
    int_16_band_pass x1_16;
    int_16_band_pass x2_16;
    int_32_band_pass en_32;
    int_32_band_pass sn_32;
    sn_32=0;
    /* no accumulation because cel 1 has zero gain */
    /* code of cel 2 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-5,LA=13*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=14058*x1_16; /* en<-en - a1 . x1 */
    en_32+=-18837*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>13); /* vn<-en >> LA */
    en_32=22797*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-8059*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-6,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=30623*x1_16; /* en<-en - a1 . x1 */
    en_32+=-30589*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=15337*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-26497*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=26666*x1_16; /* en<-en - a1 . x1 */
    en_32+=-30649*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=-24271*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-3800*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=27888*x1_16; /* en<-en - a1 . x1 */
    en_32+=-32083*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=-7001*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=22379*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=27007*x1_16; /* en<-en - a1 . x1 */
    en_32+=-23817*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=17195*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=17713*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-3,LA=13*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=12210*x1_16; /* en<-en - a1 . x1 */
    en_32+=-19800*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>13); /* vn<-en >> LA */
    en_32=-578*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-20765*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 7*/
    sn_32+=en_32;
    sn_32=sn_32>>12; /* scale global output */
    return  ( sn_32) ;
  } /* int_32_band_pass one_step_+16bits_filter_band_pass(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_band_pass(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_band_pass en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_band_pass p_band_pass=new_16bits_filter_band_pass();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_band_pass) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_band_pass(en_16 , p_band_pass) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_band_pass(p_band_pass) ;
    } /* void teste_16bits_filter_band_pass(void)  */
