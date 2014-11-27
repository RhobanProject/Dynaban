/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_band_pass_alu short int
# define int_32_band_pass_alu long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_band_pass_alu coeffs_16bits_band_pass_alu[31]={
       18122 /* cel +1:  b0.2^23 */
       ,14875 /*  cel +2:  -a1.2^15 */
       ,-24468 /*  cel +2:  -a2.2^15 */
       ,-17693 /*  cel +2:  b1.2^16, note that b0=0 */
       ,-12304 /*  cel +2:  b2.2^16 */
       ,28233 /*  cel +3:  -a1.2^14 */
       ,-14503 /*  cel +3:  -a2.2^14 */
       ,21938 /*  cel +3:  b1.2^17, note that b0=0 */
       ,-15298 /*  cel +3:  b2.2^17 */
       ,16926 /*  cel +4:  -a1.2^15 */
       ,-13844 /*  cel +4:  -a2.2^15 */
       ,-19772 /*  cel +4:  b1.2^15, note that b0=0 */
       ,28624 /*  cel +4:  b2.2^15 */
       ,24470 /*  cel +5:  -a1.2^14 */
       ,-11014 /*  cel +5:  -a2.2^14 */
       ,-12152 /*  cel +5:  b1.2^15, note that b0=0 */
       ,16483 /*  cel +5:  b2.2^15 */
       ,24899 /*  cel +6:  -a1.2^15 */
       ,-9880 /*  cel +6:  -a2.2^15 */
       ,20389 /*  cel +6:  b1.2^13, note that b0=0 */
       ,-7985 /*  cel +6:  b2.2^13 */
       ,19404 /*  cel +7:  -a1.2^14 */
       ,-7350 /*  cel +7:  -a2.2^14 */
       ,-22918 /*  cel +7:  b1.2^14, note that b0=0 */
       ,6490 /*  cel +7:  b2.2^14 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_band_pass_alu *coeffs;
      int_32_band_pass_alu *states;
    }s_16bits_filter_band_pass_alu;
    typedef s_16bits_filter_band_pass_alu *p_16bits_filter_band_pass_alu;
  /* creator of structure p_16bits_filter_band_pass_alu */
    p_16bits_filter_band_pass_alu new_16bits_filter_band_pass_alu() {
      p_16bits_filter_band_pass_alu p_band_pass_alu;
      p_band_pass_alu = (s_16bits_filter_band_pass_alu *) malloc(sizeof(s_16bits_filter_band_pass_alu));
      int_32_band_pass_alu *states;
      int is;
      p_band_pass_alu->nb_coeffs=31;
      p_band_pass_alu->nb_states=12;
      p_band_pass_alu->coeffs=(int_16_band_pass_alu *)&(coeffs_16bits_band_pass_alu[0]);
      states =(int_32_band_pass_alu *) malloc(12 * sizeof(int_32_band_pass_alu));
      p_band_pass_alu->states = states;
      for (is=0;is<12;is++) {
        *(states++)=0;
      }
      return p_band_pass_alu;
    } /* p_16bits_filter_band_pass_alu new_16bits_filter_band_pass_alu()  */
  /* destructor of structure p_16bits_filter_band_pass_alu */
    void  destroy_16bits_filter_band_pass_alu(p_16bits_filter_band_pass_alu p_band_pass_alu) {
      free((void *) (p_band_pass_alu->states) ); /* release memory allocated for states */
      free((void *)p_band_pass_alu) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_band_pass_alu(p_16bits_filter_band_pass_alu p_band_pass_alu) */
  int_32_band_pass_alu one_step_16bits_filter_band_pass_alu(int_16_band_pass_alu en_16 , p_16bits_filter_band_pass_alu p_band_pass_alu) {
    int_16_band_pass_alu *coeffs;
    int_32_band_pass_alu *states;
    coeffs=p_band_pass_alu->coeffs;
    states=p_band_pass_alu->states;
    int_32_band_pass_alu tmp_32;
    int_16_band_pass_alu vn_16;
    int_16_band_pass_alu x1_16;
    int_16_band_pass_alu x2_16;
    int_32_band_pass_alu en_32;
    int_32_band_pass_alu sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=(int_32_band_pass_alu)(en_32); /* en<-en .2^0 */
    en_32=18122* ( (int_16_band_pass_alu) en_32); /* en<-b0 . en */
    en_32=en_32>>12; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-3,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=14875*x1_16; /* en<-en - a1 . x1 */
    en_32+=-24468*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-17693*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-12304*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>2; /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<9; /* en<-en<<L+LA ,L=-5,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=28233*x1_16; /* en<-en - a1 . x1 */
    en_32+=-14503*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=21938*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-15298*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>1; /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<13; /* en<-en<<L+LA ,L=-2,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=16926*x1_16; /* en<-en - a1 . x1 */
    en_32+=-13844*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-19772*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=28624*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>2; /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=24470*x1_16; /* en<-en - a1 . x1 */
    en_32+=-11014*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-12152*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=16483*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<13; /* en<-en<<L+LA ,L=-2,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=24899*x1_16; /* en<-en - a1 . x1 */
    en_32+=-9880*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=20389*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-7985*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<11; /* en<-en<<L+LA ,L=-3,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=19404*x1_16; /* en<-en - a1 . x1 */
    en_32+=-7350*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-22918*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=6490*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 7*/
    sn_32+=en_32;
    tmp_32=sn_32>>10; /* scale global output */
    tmp_32+=1;
    sn_32=tmp_32>>1;
    return  ( sn_32) ;
  } /* int_32_band_pass_alu one_step_+16bits_filter_band_pass_alu(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_band_pass_alu(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_band_pass_alu en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_band_pass_alu p_band_pass_alu=new_16bits_filter_band_pass_alu();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_band_pass_alu) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_band_pass_alu(en_16 , p_band_pass_alu) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_band_pass_alu(p_band_pass_alu) ;
    } /* void teste_16bits_filter_band_pass_alu(void)  */
