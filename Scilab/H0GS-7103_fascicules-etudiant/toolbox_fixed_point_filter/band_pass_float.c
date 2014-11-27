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
  }s_real_filter_band_pass;
  typedef s_real_filter_band_pass *p_real_filter_band_pass ;
  double one_step_real_filter_band_pass(double en,p_real_filter_band_pass f) {
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
  } /*double one_step_real_filter_band_pass(...)*/
  p_real_filter_band_pass get_memory_real_filter_band_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_band_pass f=malloc(sizeof(s_real_filter_band_pass));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_band_pass new_real_filter_band_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_band_pass(p_real_filter_band_pass f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_band_pass(p_real_filter_band_pass f) */
  p_real_filter_band_pass new_real_filter_band_pass() {
  /* 7 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_band_pass f =get_memory_real_filter_band_pass(7,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00000000098510815; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.98924933250095248; /* coeffs -a2[2] */
    *(coeffs++)=-0.00999190732335460; /* coeffs +b2[2] */
    *(coeffs++)=1.96450892851677938; /* coeffs -a1[2] */
    *(coeffs++)=0.01087037088098281; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99571441993691789; /* coeffs -a2[3] */
    *(coeffs++)=-0.00382290485596488; /* coeffs +b2[3] */
    *(coeffs++)=1.9918162458590127; /* coeffs -a1[3] */
    *(coeffs++)=0.00365661054700025; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.97286871859228208; /* coeffs -a2[4] */
    *(coeffs++)=0.01980010442430241; /* coeffs +b2[4] */
    *(coeffs++)=1.95344573317804926; /* coeffs -a1[4] */
    *(coeffs++)=-0.02314638721028294; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.98629220249986493; /* coeffs -a2[5] */
    *(coeffs++)=0.00759285530417286; /* coeffs +b2[5] */
    *(coeffs++)=1.98138584277524576; /* coeffs -a1[5] */
    *(coeffs++)=-0.00667625343194211; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.96863111008981628; /* coeffs -a2[6] */
    *(coeffs++)=-0.01223696817450325; /* coeffs +b2[6] */
    *(coeffs++)=1.95604865295546970; /* coeffs -a1[6] */
    *(coeffs++)=0.01639837527094032; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.97568189282822648; /* coeffs -a2[7] */
    *(coeffs++)=-0.00144162710079911; /* coeffs +b2[7] */
    *(coeffs++)=1.96815680145166905; /* coeffs -a1[7] */
    *(coeffs++)=-0.00110270441728844; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    return f;
  }/* p_real_filter_band_pass new_real_filter_band_pass() */
 void teste_real_band_pass(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_band_pass f_real_band_pass=new_real_filter_band_pass();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_band_pass(en,f_real_band_pass) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_pass(f_real_band_pass) ;
  } /* void teste_real_band_pass(void)  */
