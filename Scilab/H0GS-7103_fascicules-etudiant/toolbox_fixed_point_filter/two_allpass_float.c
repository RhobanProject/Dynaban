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
  }s_real_filter_S2z;
  typedef s_real_filter_S2z *p_real_filter_S2z ;
  double one_step_real_filter_S2z(double en,p_real_filter_S2z f) {
    int i;
    double *ci=f->coeffs;
    double *xi=f->states;
    double sn;
    for (i=f->nb_cels;i>0;i--) {
      en+=  *(ci++)*(*xi);  /* en=en-a2.xn_2*/
      sn=   *(ci++)*(*xi);  /* sn=b2.xn_2*/
      *(xi)=*(xi+1);        /* xn_2=xn_1*/
      xi++;                 /* xi is now xn_1*/
      en+=  *(ci++)*(*xi) ; /* en=en-a1.xn_1*/
      sn+=   *(ci++)*(*xi); /* sn=sn+b1.xn_1*/
      *(xi++)=en;           /* xn_1=en */
      en*=   *(ci++)   ;    /* en=b0.en*/
      en+=   sn        ;    /* en=sn+en*/
    }/*for (i=f->nb_cels;i>0;i--) */
    return en; 
  } /*double one_step_real_filter_S2z(...)*/
  p_real_filter_S2z get_memory_real_filter_S2z(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_S2z f=malloc(sizeof(s_real_filter_S2z));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_S2z new_real_filter_S2z(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_S2z(p_real_filter_S2z f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_S2z(p_real_filter_S2z f) */
  p_real_filter_Fz new_real_filter_Fz() {
  /* 4 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_Fz f =get_memory_real_filter_Fz(4,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00988731117945506; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99859529864408481; /* coeffs -a2[2] */
    *(coeffs++)=-0.00131455055344076; /* coeffs +b2[2] */
    *(coeffs++)=1.99779569141942681; /* coeffs -a1[2] */
    *(coeffs++)=0.00133272872255364; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99308247554443407; /* coeffs -a2[3] */
    *(coeffs++)=0.00363144904488723; /* coeffs +b2[3] */
    *(coeffs++)=1.99245998959594095; /* coeffs -a1[3] */
    *(coeffs++)=-0.00379802442582992; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.981819696721648; /* coeffs -a2[4] */
    *(coeffs++)=-0.00203516518773393; /* coeffs +b2[4] */
    *(coeffs++)=1.9816030930396016; /* coeffs -a1[4] */
    *(coeffs++)=0.00228100513145641; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    return f;
  }/* p_real_filter_Fz new_real_filter_Fz() */
 void teste_real_Fz(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_Fz f_real_Fz=new_real_filter_Fz();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_Fz(en,f_real_Fz) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_Fz(f_real_Fz) ;
  } /* void teste_real_Fz(void)  */
  p_real_filter_S1z new_real_filter_S1z() {
  /* 2 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_S1z f =get_memory_real_filter_S1z(2,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0.98967544167818322; /* coeffs -a1[1] */
    *(coeffs++)=0.5; /* coeffs +b1[1] */
    *(coeffs++)=-0.49483772083909161; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99646376399737380; /* coeffs -a2[2] */
    *(coeffs++)=1; /* coeffs +b2[2] */
    *(coeffs++)=1.99575504313363750; /* coeffs -a1[2] */
    *(coeffs++)=-1.99575504313363750; /* coeffs +b1[2] */
    *(coeffs++)=0.99646376399737380; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    return f;
  }/* p_real_filter_S1z new_real_filter_S1z() */
 void teste_real_S1z(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_S1z f_real_S1z=new_real_filter_S1z();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_S1z(en,f_real_S1z) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_S1z(f_real_S1z) ;
  } /* void teste_real_S1z(void)  */
  p_real_filter_S2z new_real_filter_S2z() {
  /* 2 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_S2z f =get_memory_real_filter_S2z(2,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=-0.98806344966659965; /* coeffs -a2[1] */
    *(coeffs++)=0.5; /* coeffs +b2[1] */
    *(coeffs++)=1.98765109333348544; /* coeffs -a1[1] */
    *(coeffs++)=-0.99382554666674272; /* coeffs +b1[1] */
    *(coeffs++)=0.49403172483329982; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99932641006247624; /* coeffs -a2[2] */
    *(coeffs++)=1; /* coeffs +b2[2] */
    *(coeffs++)=1.99852692309086200; /* coeffs -a1[2] */
    *(coeffs++)=-1.99852692309086200; /* coeffs +b1[2] */
    *(coeffs++)=0.99932641006247624; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    return f;
  }/* p_real_filter_S2z new_real_filter_S2z() */
 void teste_real_S2z(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_S2z f_real_S2z=new_real_filter_S2z();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_S2z(en,f_real_S2z) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_S2z(f_real_S2z) ;
  } /* void teste_real_S2z(void)  */
