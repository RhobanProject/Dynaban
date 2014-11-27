/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_low_pass short int
# define int_32_low_pass long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_low_pass coeffs_16bits_low_pass[55]={
       19845 /* cel +1:  b0.2^21 */
       ,-2161 /*  cel +2:  B1.2^14 */
       ,14848 /*  cel +2:  A11.2^14 */
       ,20546 /*  cel +2:  A12.2^14 */
       ,-25322 /*  cel +2:  C1.2^21 */
       ,3103 /*  cel +2:  B2.2^14 */
       ,14633 /*  cel +2:  A22.2^14 */
       ,-20492 /*  cel +2:  A21.2^14 */
       ,21662 /*  cel +2:  C2.2^21 */
       ,8203 /*  cel +3:  B1.2^14 */
       ,15066 /*  cel +3:  A11.2^14 */
       ,20431 /*  cel +3:  A12.2^14 */
       ,-26443 /*  cel +3:  C1.2^20 */
       ,97 /*  cel +3:  B2.2^14 */
       ,14230 /*  cel +3:  A22.2^14 */
       ,-20484 /*  cel +3:  A21.2^14 */
       ,26369 /*  cel +3:  C2.2^20 */
       ,6859 /*  cel +4:  B1.2^14 */
       ,16024 /*  cel +4:  A11.2^14 */
       ,19952 /*  cel +4:  A12.2^14 */
       ,25423 /*  cel +4:  C1.2^19 */
       ,13237 /*  cel +4:  B2.2^14 */
       ,12693 /*  cel +4:  A22.2^14 */
       ,-20622 /*  cel +4:  A21.2^14 */
       ,-27341 /*  cel +4:  C2.2^19 */
       ,-20056 /*  cel +5:  B1.2^14 */
       ,17297 /*  cel +5:  A11.2^14 */
       ,21326 /*  cel +5:  A12.2^14 */
       ,-25627 /*  cel +5:  C1.2^18 */
       ,22952 /*  cel +5:  B2.2^14 */
       ,9531 /*  cel +5:  A22.2^14 */
       ,-18319 /*  cel +5:  A21.2^14 */
       ,21309 /*  cel +5:  C2.2^18 */
       ,23099 /*  cel +6:  B1.2^13 */
       ,7868 /*  cel +6:  A11.2^13 */
       ,8333 /*  cel +6:  A12.2^13 */
       ,-20692 /*  cel +6:  C1.2^17 */
       ,-13133 /*  cel +6:  B2.2^14 */
       ,5672 /*  cel +6:  A22.2^14 */
       ,-17760 /*  cel +6:  A21.2^14 */
       ,20820 /*  cel +6:  C2.2^17 */
       ,22729 /*  cel +7:  B1.2^13 */
       ,5623 /*  cel +7:  A11.2^13 */
       ,2051 /*  cel +7:  A12.2^13 */
       ,18175 /*  cel +7:  C1.2^17 */
       ,1216 /*  cel +7:  B2.2^14 */
       ,821 /*  cel +7:  A22.2^14 */
       ,-20121 /*  cel +7:  A21.2^14 */
       ,-21757 /*  cel +7:  C2.2^17 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_low_pass *coeffs;
      int_32_low_pass *states;
    }s_16bits_filter_low_pass;
    typedef s_16bits_filter_low_pass *p_16bits_filter_low_pass;
  /* creator of structure p_16bits_filter_low_pass */
    p_16bits_filter_low_pass new_16bits_filter_low_pass() {
      p_16bits_filter_low_pass p_low_pass;
      p_low_pass = (s_16bits_filter_low_pass *) malloc(sizeof(s_16bits_filter_low_pass));
      int_32_low_pass *states;
      int is;
      p_low_pass->nb_coeffs=55;
      p_low_pass->nb_states=12;
      p_low_pass->coeffs=(int_16_low_pass *)&(coeffs_16bits_low_pass[0]);
      states =(int_32_low_pass *) malloc(12 * sizeof(int_32_low_pass));
      p_low_pass->states = states;
      for (is=0;is<12;is++) {
        *(states++)=0;
      }
      return p_low_pass;
    } /* p_16bits_filter_low_pass new_16bits_filter_low_pass()  */
  /* destructor of structure p_16bits_filter_low_pass */
    void  destroy_16bits_filter_low_pass(p_16bits_filter_low_pass p_low_pass) {
      free((void *) (p_low_pass->states) ); /* release memory allocated for states */
      free((void *)p_low_pass) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_low_pass(p_16bits_filter_low_pass p_low_pass) */
  int_32_low_pass one_step_16bits_filter_low_pass(int_16_low_pass en_16 , p_16bits_filter_low_pass p_low_pass) {
    int_16_low_pass *coeffs;
    int_32_low_pass *states;
    coeffs=p_low_pass->coeffs;
    states=p_low_pass->states;
    int_16_low_pass vn_16;
    int_16_low_pass x1_16;
    int_16_low_pass x2_16;
    int_32_low_pass accx_32;
    int_32_low_pass en_32;
    int_32_low_pass sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_low_pass)en_16;
    en_32=(int_32_low_pass)(en_32); /* en<-en .2^0 */
    en_32=19845* ( (int_16_low_pass) en_32); /* en<-b0 . en */
    en_32=en_32>>7; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>7); /* vn<-en<<L ,L=-7*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=-2161*vn_16; /* accx<-b1.vn */
    accx_32+=14848*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=20546*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-25322*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=3103*vn_16; /* accx<-b2.vn */
    accx_32+=14633*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-20492*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=21662*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>6); /* vn<-en<<L ,L=-6*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=8203*vn_16; /* accx<-b1.vn */
    accx_32+=15066*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=20431*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-26443*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=97*vn_16; /* accx<-b2.vn */
    accx_32+=14230*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-20484*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=26369*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>5); /* vn<-en<<L ,L=-5*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=6859*vn_16; /* accx<-b1.vn */
    accx_32+=16024*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=19952*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=25423*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=13237*vn_16; /* accx<-b2.vn */
    accx_32+=12693*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-20622*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-27341*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>4); /* vn<-en<<L ,L=-4*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=-20056*vn_16; /* accx<-b1.vn */
    accx_32+=17297*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=21326*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-25627*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=22952*vn_16; /* accx<-b2.vn */
    accx_32+=9531*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-18319*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=21309*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>3); /* vn<-en<<L ,L=-3*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=23099*vn_16; /* accx<-b1.vn */
    accx_32+=7868*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=8333*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>13; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-20692*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=-13133*vn_16; /* accx<-b2.vn */
    accx_32+=5672*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-17760*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=20820*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>3); /* vn<-en<<L ,L=-3*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=22729*vn_16; /* accx<-b1.vn */
    accx_32+=5623*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=2051*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>13; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=18175*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=1216*vn_16; /* accx<-b2.vn */
    accx_32+=821*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=-20121*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-21757*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 7*/
    sn_32+=en_32;
    sn_32=sn_32>>14; /* scale global output */
    return  ( sn_32) ;
  } /* int_32_low_pass one_step_+16bits_filter_low_pass(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_low_pass(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_low_pass en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_low_pass p_low_pass=new_16bits_filter_low_pass();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_low_pass) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_low_pass(en_16 , p_low_pass) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_low_pass(p_low_pass) ;
    } /* void teste_16bits_filter_low_pass(void)  */
