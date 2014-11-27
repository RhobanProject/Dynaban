/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_arbitrary short int
# define int_32_arbitrary long int
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
  }s_real_filter_arbitrary;
  typedef s_real_filter_arbitrary *p_real_filter_arbitrary ;
  double one_step_real_filter_arbitrary(double en,p_real_filter_arbitrary f) {
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
  } /*double one_step_real_filter_arbitrary(...)*/
  p_real_filter_arbitrary get_memory_real_filter_arbitrary(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_arbitrary f=malloc(sizeof(s_real_filter_arbitrary));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_arbitrary new_real_filter_arbitrary(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_arbitrary(p_real_filter_arbitrary f) {
    if (f->nb_coeffs >0) {
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */
    if (f->nb_states >0) {
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_arbitrary(p_real_filter_arbitrary f) */
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_arbitrary coeffs_16bits_arbitrary[14]={
       25876 /* cel +1:  b0.2^18 */
       ,4350 /*  cel +2:  B1.2^15 */
       ,30914 /*  cel +2:  A11.2^15 */
       ,-4392 /*  cel +2:  A12.2^15 */
       ,-22905 /*  cel +2:  C1.2^18 */
       ,-13556 /*  cel +2:  B2.2^15 */
       ,30914 /*  cel +2:  A22.2^15 */
       ,4968 /*  cel +2:  A21.2^15 */
       ,7350 /*  cel +2:  C2.2^18 */
       ,32534 /*  cel +3:  B1.2^15 */
       ,3905 /*  cel +3:  A11.2^15 */
       ,32343 /*  cel +3:  C1.2^18 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_arbitrary *coeffs;
      int_32_arbitrary *states;
    }s_16bits_filter_arbitrary;
    typedef s_16bits_filter_arbitrary *p_16bits_filter_arbitrary;
  /* creator of structure p_16bits_filter_arbitrary */
    p_16bits_filter_arbitrary new_16bits_filter_arbitrary() {
      p_16bits_filter_arbitrary p_arbitrary;
      p_arbitrary = (s_16bits_filter_arbitrary *) malloc(sizeof(s_16bits_filter_arbitrary));
      int_32_arbitrary *states;
      int is;
      p_arbitrary->nb_coeffs=14;
      p_arbitrary->nb_states=3;
      p_arbitrary->coeffs=(int_16_arbitrary *)&(coeffs_16bits_arbitrary[0]);
      states =(int_32_arbitrary *) malloc(3 * sizeof(int_32_arbitrary));
      p_arbitrary->states = states;
      for (is=0;is<3;is++) {
        *(states++)=0;
      }
      return p_arbitrary;
    } /* p_16bits_filter_arbitrary new_16bits_filter_arbitrary()  */
  /* destructor of structure p_16bits_filter_arbitrary */
    void  destroy_16bits_filter_arbitrary(p_16bits_filter_arbitrary p_arbitrary) {
      free((void *) (p_arbitrary->states) ); /* release memory allocated for states */
      free((void *)p_arbitrary) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_arbitrary(p_16bits_filter_arbitrary p_arbitrary) */
  int_32_arbitrary one_step_16bits_filter_arbitrary(int_16_arbitrary en_16 , p_16bits_filter_arbitrary p_arbitrary) {
    int_16_arbitrary *coeffs;
    int_32_arbitrary *states;
    coeffs=p_arbitrary->coeffs;
    states=p_arbitrary->states;
    int_16_arbitrary vn_16;
    int_16_arbitrary x1_16;
    int_16_arbitrary x2_16;
    int_32_arbitrary accx_32;
    int_32_arbitrary en_32;
    int_32_arbitrary sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_arbitrary)en_16;
    en_32=(int_32_arbitrary)(en_32); /* en<-en .2^0 */
    en_32=25876* ( (int_16_arbitrary) en_32); /* en<-b0 . en */
    en_32=en_32>>3; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_arbitrary)en_16;
    vn_16=(int_16_arbitrary)(en_32>>3); /* vn<-en<<L ,L=-3*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16= (int_16_arbitrary)(*states); /* x1_16 <- previous value*/
    x2_16= (int_16_arbitrary)(*(states + 1)); /* x2_16 <- previous value*/
    accx_32=4350*vn_16; /* accx<-b1.vn */
    accx_32+=30914*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32+=-4392*x2_16; /* accx<-accx-a12 . x2_16 */
    accx_32=accx_32>>15; /* accx<-accx >> Lx1 */
    *(states++)= (int_32_arbitrary)accx_32; /* update state(1) */
    en_32+=-22905*x1_16; /* sn<-sn+C1 . x1_16 */
    accx_32=-13556*vn_16; /* accx<-b2.vn */
    accx_32+=30914*x2_16; /* accx<-accx-a22 . x2_16 */
    accx_32+=4968*x1_16; /* accx<-accx-a21 . x1_16 */
    accx_32=accx_32>>15; /* accx<-accx >> Lx2 */
    *(states++)= (int_32_arbitrary)accx_32; /* update state(2) */
    en_32+=7350*x2_16; /* sn<-sn+C2 . x2_16 */
     /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_arbitrary)en_16;
    vn_16=(int_16_arbitrary)(en_32>>1); /* vn<-en<<L ,L=-1*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16= (int_16_arbitrary)(*states); /* x1_16 <- previous value*/
    accx_32=32534*vn_16; /* accx<-b1.vn */
    accx_32+=3905*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32=accx_32>>15; /* accx<-accx >> Lx1 */
    *(states++)= (int_32_arbitrary)accx_32; /* update state(1) */
    en_32+=32343*x1_16; /* sn<-sn+C1 . x1_16 */
    en_32=en_32>>2; /* scale output of cel 3*/
    sn_32+=en_32;
    sn_32=sn_32>>15; /* scale global output */
    return  ( sn_32) ;
  } /* int_32_arbitrary one_step_+16bits_filter_arbitrary(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_arbitrary(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ;
      const double PI=3.141592653589793115998 ;
      int_16_arbitrary en_16 ;
      double phi_n=0 ;
      double sn ;
      p_16bits_filter_arbitrary p_arbitrary=new_16bits_filter_arbitrary();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_arbitrary) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_arbitrary(en_16 , p_arbitrary) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_arbitrary(p_arbitrary) ;
    } /* void teste_16bits_filter_arbitrary(void)  */
  p_real_filter_arbitrary new_real_filter_arbitrary() {
  /* 3 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_arbitrary f =get_memory_real_filter_arbitrary(3,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=-0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=-0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.09871004850842344; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.91034677716200030; /* coeffs -a2[2] */
    *(coeffs++)=0.01760470028177181; /* coeffs +b2[2] */
    *(coeffs++)=1.88682723829640531; /* coeffs -a1[2] */
    *(coeffs++)=-0.02319732533497626; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0; /* coeffs -a2[3] */
    *(coeffs++)=0; /* coeffs +b2[3] */
    *(coeffs++)=0.11918349048721820; /* coeffs -a1[3] */
    *(coeffs++)=0.12250069317320214; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    return f;
  }/* p_real_filter_arbitrary new_real_filter_arbitrary() */
 void teste_real_arbitrary(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ;
    const double PI=3.141592653589793115998 ;
    double phi_n=0 ;
    double sn ;
    p_real_filter_arbitrary f_real_arbitrary=new_real_filter_arbitrary();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_arbitrary(en,f_real_arbitrary) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_arbitrary(f_real_arbitrary) ;
  } /* void teste_real_arbitrary(void)  */
