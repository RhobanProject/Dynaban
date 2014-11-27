/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_low_pass short int
# define int_32_low_pass long int
/* stdio.h contains printf declaration */
#include <stdio.h>
/* stdlib.h contains malloc declaration */
#include <stdlib.h>
/* math.h contains cos declaration */
/* do not forget to link with -lm */
#include <math.h>
  typedef struct {
    int nb_cels;
    int nb_coeffs;
    int nb_states;
    double *coeffs;
    double *states;
  }s_real_filter_low_pass;
  typedef s_real_filter_low_pass *p_real_filter_low_pass ;
  double one_step_real_filter_low_pass(double en,p_real_filter_low_pass f) {
    int i;
    double *ci=f->coeffs;
    double *xi=f->states;
    double sn,vn;
    sn=0;
    for (i=f->nb_cels;i>0;i--) {
      vn=  en;  /* vn=en*/
      vn+=  *(ci++)*(*xi);  /* vn=vn-a2.xn_2*/
      sn+=  *(ci++)*(*xi);  /* sn=sn+b2.xn_2*/
      *(xi)=*(xi+1);        /* xn_2=xn_1*/
      xi++;                 /* xi is now xn_1*/
      vn+=  *(ci++)*(*xi) ; /* vn=vn-a1.xn_1*/
      sn+=   *(ci++)*(*xi); /* sn=sn+b1.xn_1*/
      *(xi++)=vn;           /* xn_1=vn */
      sn+=   *(ci++)*vn   ;    /* sn=sn+b0.vn*/
    }/*for (i=f->nb_cels;i>0;i--) */
    return sn;
  } /*double one_step_real_filter_low_pass(...)*/
  p_real_filter_low_pass get_memory_real_filter_low_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_low_pass f=malloc(sizeof(s_real_filter_low_pass));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_low_pass new_real_filter_low_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_low_pass(p_real_filter_low_pass f) {
    if (f->nb_coeffs >0) {
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */
    if (f->nb_states >0) {
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_low_pass(p_real_filter_low_pass f) */
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_low_pass coeffs_16bits_low_pass[55]={
       19845 /* cel +1:  b0.2^21 */
       ,3103 /*  cel +2:  B1.2^14 */
       ,14633 /*  cel +2:  A11.2^14 */
       ,-20492 /*  cel +2:  A12.2^14 */
       ,21662 /*  cel +2:  C1.2^21 */
       ,-2161 /*  cel +2:  B2.2^14 */
       ,14848 /*  cel +2:  A22.2^14 */
       ,20546 /*  cel +2:  A21.2^14 */
       ,-25322 /*  cel +2:  C2.2^21 */
       ,97 /*  cel +3:  B1.2^14 */
       ,14230 /*  cel +3:  A11.2^14 */
       ,-20484 /*  cel +3:  A12.2^14 */
       ,26369 /*  cel +3:  C1.2^20 */
       ,8203 /*  cel +3:  B2.2^14 */
       ,15066 /*  cel +3:  A22.2^14 */
       ,20431 /*  cel +3:  A21.2^14 */
       ,-26443 /*  cel +3:  C2.2^20 */
       ,13237 /*  cel +4:  B1.2^14 */
       ,12693 /*  cel +4:  A11.2^14 */
       ,-20622 /*  cel +4:  A12.2^14 */
       ,-27341 /*  cel +4:  C1.2^19 */
       ,6859 /*  cel +4:  B2.2^14 */
       ,16024 /*  cel +4:  A22.2^14 */
       ,19952 /*  cel +4:  A21.2^14 */
       ,25423 /*  cel +4:  C2.2^19 */
       ,22952 /*  cel +5:  B1.2^14 */
       ,9531 /*  cel +5:  A11.2^14 */
       ,-18319 /*  cel +5:  A12.2^14 */
       ,21309 /*  cel +5:  C1.2^18 */
       ,-20056 /*  cel +5:  B2.2^14 */
       ,17297 /*  cel +5:  A22.2^14 */
       ,21326 /*  cel +5:  A21.2^14 */
       ,-25627 /*  cel +5:  C2.2^18 */
       ,-13133 /*  cel +6:  B1.2^14 */
       ,5672 /*  cel +6:  A11.2^14 */
       ,-17760 /*  cel +6:  A12.2^14 */
       ,20820 /*  cel +6:  C1.2^17 */
       ,23099 /*  cel +6:  B2.2^13 */
       ,7868 /*  cel +6:  A22.2^13 */
       ,8333 /*  cel +6:  A21.2^13 */
       ,-20692 /*  cel +6:  C2.2^17 */
       ,1216 /*  cel +7:  B1.2^14 */
       ,821 /*  cel +7:  A11.2^14 */
       ,-20121 /*  cel +7:  A12.2^14 */
       ,-21757 /*  cel +7:  C1.2^17 */
       ,22729 /*  cel +7:  B2.2^13 */
       ,5623 /*  cel +7:  A22.2^13 */
       ,2051 /*  cel +7:  A21.2^13 */
       ,18175 /*  cel +7:  C2.2^17 */
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
    accx_32=3103*vn_16; /* accx<-b1.vn */
    accx_32+=14633*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-20492*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=21662*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=-2161*vn_16; /* accx<-b2.vn */
    accx_32+=14848*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=20546*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-25322*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>6); /* vn<-en<<L ,L=-6*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=97*vn_16; /* accx<-b1.vn */
    accx_32+=14230*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-20484*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=26369*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=8203*vn_16; /* accx<-b2.vn */
    accx_32+=15066*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=20431*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-26443*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>5); /* vn<-en<<L ,L=-5*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=13237*vn_16; /* accx<-b1.vn */
    accx_32+=12693*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-20622*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-27341*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=6859*vn_16; /* accx<-b2.vn */
    accx_32+=16024*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=19952*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=25423*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>4); /* vn<-en<<L ,L=-4*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=22952*vn_16; /* accx<-b1.vn */
    accx_32+=9531*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-18319*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=21309*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=-20056*vn_16; /* accx<-b2.vn */
    accx_32+=17297*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=21326*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-25627*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>3); /* vn<-en<<L ,L=-3*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=-13133*vn_16; /* accx<-b1.vn */
    accx_32+=5672*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-17760*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=20820*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=23099*vn_16; /* accx<-b2.vn */
    accx_32+=7868*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=8333*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>13; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=-20692*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_low_pass)en_16;
    vn_16=(int_16_low_pass)(en_32>>3); /* vn<-en<<L ,L=-3*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_low_pass)((*states)>>3);
    x2_16=(int_16_low_pass)((*(states + 1))>>3);
    accx_32=1216*vn_16; /* accx<-b1.vn */
    accx_32+=821*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-20121*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    en_32+=-21757*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=22729*vn_16; /* accx<-b2.vn */
    accx_32+=5623*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=2051*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>13; /* accx<-accx >> Lx2 */
    (*states)+= accx_32; /* update state(2) */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32+=18175*x2_16; /* sn<-sn+C2 . x2_16 */
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
  p_real_filter_low_pass new_real_filter_low_pass() {
  /* 7 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_low_pass f =get_memory_real_filter_low_pass(7,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=-0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=-0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00946271625774325; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99958576475619410; /* coeffs -a2[2] */
    *(coeffs++)=-0.00045622928364048; /* coeffs +b2[2] */
    *(coeffs++)=1.97492232414580693; /* coeffs -a1[2] */
    *(coeffs++)=0.00044357299842489; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99803670926460009; /* coeffs -a2[3] */
    *(coeffs++)=0.00128509422654634; /* coeffs +b2[3] */
    *(coeffs++)=1.97351098906227418; /* coeffs -a1[3] */
    *(coeffs++)=-0.00155971047517500; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.99312130472545423; /* coeffs -a2[4] */
    *(coeffs++)=0.00396074957972312; /* coeffs +b2[4] */
    *(coeffs++)=1.96909508750626649; /* coeffs -a1[4] */
    *(coeffs++)=-0.00272899376574096; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.97705880955575419; /* coeffs -a2[5] */
    *(coeffs++)=-0.02955730495055679; /* coeffs +b2[5] */
    *(coeffs++)=1.95468348702957817; /* coeffs -a1[5] */
    *(coeffs++)=0.02919344135907691; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.93096306956691899; /* coeffs -a2[6] */
    *(coeffs++)=0.06135864279678237; /* coeffs +b2[6] */
    *(coeffs++)=1.91333009916706898; /* coeffs -a1[6] */
    *(coeffs++)=-0.07155954332594301; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.85152342925275171; /* coeffs -a2[7] */
    *(coeffs++)=-0.03202461411387111; /* coeffs +b2[7] */
    *(coeffs++)=1.84206400062150699; /* coeffs -a1[7] */
    *(coeffs++)=0.04655197957071436; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    return f;
  }/* p_real_filter_low_pass new_real_filter_low_pass() */
 void teste_real_low_pass(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ;
    const double PI=3.141592653589793115998 ;
    double phi_n=0 ;
    double sn ;
    p_real_filter_low_pass f_real_low_pass=new_real_filter_low_pass();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_low_pass(en,f_real_low_pass) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_low_pass(f_real_low_pass) ;
  } /* void teste_real_low_pass(void)  */
