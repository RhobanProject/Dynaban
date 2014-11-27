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
  }s_real_filter_band_stop;
  typedef s_real_filter_band_stop *p_real_filter_band_stop ;
  double one_step_real_filter_band_stop(double en,p_real_filter_band_stop f) {
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
  } /*double one_step_real_filter_band_stop(...)*/
  p_real_filter_band_stop get_memory_real_filter_band_stop(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_band_stop f=malloc(sizeof(s_real_filter_band_stop));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_band_stop new_real_filter_band_stop(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_band_stop(p_real_filter_band_stop f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_band_stop(p_real_filter_band_stop f) */
  p_real_filter_band_stop new_real_filter_band_stop() {
  /* 6 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_band_stop f =get_memory_real_filter_band_stop(6,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.97850096614292215; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99757781641148446; /* coeffs -a2[2] */
    *(coeffs++)=-0.00206406304882888; /* coeffs +b2[2] */
    *(coeffs++)=1.99713265493134529; /* coeffs -a1[2] */
    *(coeffs++)=0.00210543856042437; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99887287015120074; /* coeffs -a2[3] */
    *(coeffs++)=-0.00085524264504432; /* coeffs +b2[3] */
    *(coeffs++)=1.99877654671473559; /* coeffs -a1[3] */
    *(coeffs++)=0.00084614833486254; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.98779028463552276; /* coeffs -a2[4] */
    *(coeffs++)=0.01106779295387960; /* coeffs +b2[4] */
    *(coeffs++)=1.98728225272735637; /* coeffs -a1[4] */
    *(coeffs++)=-0.01091001735509505; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.99503104748641802; /* coeffs -a2[5] */
    *(coeffs++)=0.00603234099821400; /* coeffs +b2[5] */
    *(coeffs++)=1.99494722044639383; /* coeffs -a1[5] */
    *(coeffs++)=-0.00605765704774866; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.97758702450486012; /* coeffs -a2[6] */
    *(coeffs++)=0.02849581905209876; /* coeffs +b2[6] */
    *(coeffs++)=1.9773820863308207; /* coeffs -a1[6] */
    *(coeffs++)=-0.02849286601839999; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    return f;
  }/* p_real_filter_band_stop new_real_filter_band_stop() */
 void teste_real_band_stop(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_band_stop f_real_band_stop=new_real_filter_band_stop();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_band_stop(en,f_real_band_stop) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_stop(f_real_band_stop) ;
  } /* void teste_real_band_stop(void)  */
