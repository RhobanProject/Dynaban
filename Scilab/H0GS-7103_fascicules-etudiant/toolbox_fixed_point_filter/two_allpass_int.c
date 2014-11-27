/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_S2z short int
# define int_32_S2z long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_Fz coeffs_16bits_Fz[16]={
       20735 /* cel +1:  b0.2^21 */
       ,31612 /*  cel +2:  -a1.2^14 */
       ,-28643 /*  cel +2:  -a2.2^14 */
       ,22359 /*  cel +2:  b1.2^19, note that b0=0 */
       ,-12600 /*  cel +2:  b2.2^19 */
       ,28815 /*  cel +3:  -a1.2^14 */
       ,-22874 /*  cel +3:  -a2.2^14 */
       ,-31860 /*  cel +3:  b1.2^18, note that b0=0 */
       ,-12855 /*  cel +3:  b2.2^18 */
       ,26955 /*  cel +4:  -a1.2^15 */
       ,-23259 /*  cel +4:  -a2.2^15 */
       ,4784 /*  cel +4:  b1.2^15, note that b0=0 */
       ,28212 /*  cel +4:  b2.2^15 */
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
      p_Fz->nb_coeffs=16;
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
    int_32_Fz tmp_32;
    int_16_Fz vn_16;
    int_16_Fz x1_16;
    int_16_Fz x2_16;
    int_32_Fz en_32;
    int_32_Fz sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_Fz)en_16;
    en_32=(int_32_Fz)(en_32); /* en<-en .2^0 */
    en_32=20735* ( (int_16_Fz) en_32); /* en<-b0 . en */
    tmp_32=en_32>>7; /* scale output of cel 1*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_Fz)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-6,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_Fz)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_Fz)(tmp_32>>1);
    en_32+=31612*x1_16; /* en<-en - a1 . x1 */
    en_32+=-28643*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_Fz)(tmp_32>>1);
    en_32=22359*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-12600*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
     /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_Fz)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_Fz)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_Fz)(tmp_32>>1);
    en_32+=28815*x1_16; /* en<-en - a1 . x1 */
    en_32+=-22874*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_Fz)(tmp_32>>1);
    en_32=-31860*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-12855*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32; /* scale output of cel 3*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_Fz)en_16;
    en_32=en_32<<14; /* en<-en<<L+LA ,L=-1,LA=15*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_Fz)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_Fz)(tmp_32>>1);
    en_32+=26955*x1_16; /* en<-en - a1 . x1 */
    en_32+=-23259*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_Fz)(tmp_32>>1);
    en_32=4784*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=28212*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    tmp_32=en_32; /* scale output of cel 4*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    tmp_32=sn_32>>12; /* scale global output */
    tmp_32+=1;
    sn_32=tmp_32>>1;
    return  ( sn_32) ;
  } /* int_32_Fz one_step_+16bits_filter_Fz(..) */
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
  const int_16_S1z coeffs_16bits_S1z[8]={
       -10536 /*  cel +1:  -a1.2^15 */
       ,-8107 /*  cel +1:  b0.2^14 */
       ,18934 /*  cel +1:  b1.2^14 */
       ,30542 /*  cel +2:  -a1.2^14 */
       ,-26049 /*  cel +2:  -a2.2^14 */
       ,8163 /*  cel +2:  b0.2^13 */
       ,-17067 /*  cel +2:  b1.2^13 */
       ,14849 /*  cel +2:  b2.2^13 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_S1z *coeffs;
      int_32_S1z *states;
    }s_16bits_filter_S1z;
    typedef s_16bits_filter_S1z *p_16bits_filter_S1z;
  /* creator of structure p_16bits_filter_S1z */
    p_16bits_filter_S1z new_16bits_filter_S1z() {
      p_16bits_filter_S1z p_S1z;
      p_S1z = (s_16bits_filter_S1z *) malloc(sizeof(s_16bits_filter_S1z));
      int_32_S1z *states;
      int is;
      p_S1z->nb_coeffs=8;
      p_S1z->nb_states=3;
      p_S1z->coeffs=(int_16_S1z *)&(coeffs_16bits_S1z[0]);
      states =(int_32_S1z *) malloc(3 * sizeof(int_32_S1z));
      p_S1z->states = states;
      for (is=0;is<3;is++) {
        *(states++)=0;
      }
      return p_S1z;
    } /* p_16bits_filter_S1z new_16bits_filter_S1z()  */
  /* destructor of structure p_16bits_filter_S1z */
    void  destroy_16bits_filter_S1z(p_16bits_filter_S1z p_S1z) {
      free((void *) (p_S1z->states) ); /* release memory allocated for states */
      free((void *)p_S1z) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_S1z(p_16bits_filter_S1z p_S1z) */
  int_32_S1z one_step_16bits_filter_S1z(int_16_S1z en_16 , p_16bits_filter_S1z p_S1z) {
    int_16_S1z *coeffs;
    int_32_S1z *states;
    coeffs=p_S1z->coeffs;
    states=p_S1z->states;
    int_32_S1z tmp_32;
    int_16_S1z vn_16;
    int_16_S1z x1_16;
    int_16_S1z x2_16;
    int_32_S1z en_32;
    en_32 = (int_32_S1z) en_16 ;
    /* code of cel 1 */
    en_32=en_32<<14; /* en<-en<<L+LA ,L=-1,LA=15*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_S1z)(tmp_32>>1);
    en_32+=-10536*x1_16; /* en<-en - a1 . x1 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_S1z)(tmp_32>>1);
    en_32=-8107*vn_16; /* en<-b0 . vn */
    en_32+=18934*x1_16; /* en<-en +b1 . x1  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    /* code of cel 2 */
    tmp_32=en_32>>2; /* en<-en<<L+LA ,L=-17,LA=14*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_S1z)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_S1z)(tmp_32>>1);
    en_32+=30542*x1_16; /* en<-en - a1 . x1 */
    en_32+=-26049*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_S1z)(tmp_32>>1);
    en_32=8163*vn_16; /* en<-b0 . vn */
    en_32+=-17067*x1_16; /* en<-en +b1 . x1  */
    en_32+=14849*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>8; /* scale global output */
    tmp_32+=1;
    en_32=tmp_32>>1;
    return  ( en_32) ;
  } /*  one_step_16bits_filter_S1z(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_S1z(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_S1z en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_S1z p_S1z=new_16bits_filter_S1z();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_S1z) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_S1z(en_16 , p_S1z) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_S1z(p_S1z) ;
    } /* void teste_16bits_filter_S1z(void)  */
  const int_16_S2z coeffs_16bits_S2z[10]={
       19819 /*  cel +1:  -a1.2^14 */
       ,-31108 /*  cel +1:  -a2.2^14 */
       ,8094 /*  cel +1:  b0.2^14 */
       ,-22230 /*  cel +1:  b1.2^14 */
       ,27973 /*  cel +1:  b2.2^14 */
       ,31996 /*  cel +2:  -a1.2^14 */
       ,-29025 /*  cel +2:  -a2.2^14 */
       ,16373 /*  cel +2:  b0.2^14 */
       ,-32680 /*  cel +2:  b1.2^14 */
       ,29720 /*  cel +2:  b2.2^14 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_S2z *coeffs;
      int_32_S2z *states;
    }s_16bits_filter_S2z;
    typedef s_16bits_filter_S2z *p_16bits_filter_S2z;
  /* creator of structure p_16bits_filter_S2z */
    p_16bits_filter_S2z new_16bits_filter_S2z() {
      p_16bits_filter_S2z p_S2z;
      p_S2z = (s_16bits_filter_S2z *) malloc(sizeof(s_16bits_filter_S2z));
      int_32_S2z *states;
      int is;
      p_S2z->nb_coeffs=10;
      p_S2z->nb_states=4;
      p_S2z->coeffs=(int_16_S2z *)&(coeffs_16bits_S2z[0]);
      states =(int_32_S2z *) malloc(4 * sizeof(int_32_S2z));
      p_S2z->states = states;
      for (is=0;is<4;is++) {
        *(states++)=0;
      }
      return p_S2z;
    } /* p_16bits_filter_S2z new_16bits_filter_S2z()  */
  /* destructor of structure p_16bits_filter_S2z */
    void  destroy_16bits_filter_S2z(p_16bits_filter_S2z p_S2z) {
      free((void *) (p_S2z->states) ); /* release memory allocated for states */
      free((void *)p_S2z) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_S2z(p_16bits_filter_S2z p_S2z) */
  int_32_S2z one_step_16bits_filter_S2z(int_16_S2z en_16 , p_16bits_filter_S2z p_S2z) {
    int_16_S2z *coeffs;
    int_32_S2z *states;
    coeffs=p_S2z->coeffs;
    states=p_S2z->states;
    int_32_S2z tmp_32;
    int_16_S2z vn_16;
    int_16_S2z x1_16;
    int_16_S2z x2_16;
    int_32_S2z en_32;
    en_32 = (int_32_S2z) en_16 ;
    /* code of cel 1 */
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-2,LA=14*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_S2z)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_S2z)(tmp_32>>1);
    en_32+=19819*x1_16; /* en<-en - a1 . x1 */
    en_32+=-31108*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_S2z)(tmp_32>>1);
    en_32=8094*vn_16; /* en<-b0 . vn */
    en_32+=-22230*x1_16; /* en<-en +b1 . x1  */
    en_32+=27973*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    /* code of cel 2 */
    tmp_32=en_32>>3; /* en<-en<<L+LA ,L=-18,LA=14*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_S2z)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_S2z)(tmp_32>>1);
    en_32+=31996*x1_16; /* en<-en - a1 . x1 */
    en_32+=-29025*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_S2z)(tmp_32>>1);
    en_32=16373*vn_16; /* en<-b0 . vn */
    en_32+=-32680*x1_16; /* en<-en +b1 . x1  */
    en_32+=29720*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>7; /* scale global output */
    tmp_32+=1;
    en_32=tmp_32>>1;
    return  ( en_32) ;
  } /*  one_step_16bits_filter_S2z(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_S2z(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_S2z en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_S2z p_S2z=new_16bits_filter_S2z();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_S2z) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_S2z(en_16 , p_S2z) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_S2z(p_S2z) ;
    } /* void teste_16bits_filter_S2z(void)  */
