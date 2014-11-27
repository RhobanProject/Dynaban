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
  p_real_filter_low_pass new_real_filter_low_pass() {
  /* 7 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_low_pass f =get_memory_real_filter_low_pass(7,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00946271625774325; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99958576475619398; /* coeffs -a2[2] */
    *(coeffs++)=-0.00045622928363983; /* coeffs +b2[2] */
    *(coeffs++)=1.97492232414580671; /* coeffs -a1[2] */
    *(coeffs++)=0.00044357299842435; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99803670926459975; /* coeffs -a2[3] */
    *(coeffs++)=0.00128509422654593; /* coeffs +b2[3] */
    *(coeffs++)=1.97351098906227396; /* coeffs -a1[3] */
    *(coeffs++)=-0.00155971047517475; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.99312130472545446; /* coeffs -a2[4] */
    *(coeffs++)=0.00396074957972329; /* coeffs +b2[4] */
    *(coeffs++)=1.96909508750626672; /* coeffs -a1[4] */
    *(coeffs++)=-0.00272899376574106; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.97705880955575453; /* coeffs -a2[5] */
    *(coeffs++)=-0.02955730495055806; /* coeffs +b2[5] */
    *(coeffs++)=1.95468348702957861; /* coeffs -a1[5] */
    *(coeffs++)=0.02919344135907810; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.93096306956691899; /* coeffs -a2[6] */
    *(coeffs++)=0.06135864279678496; /* coeffs +b2[6] */
    *(coeffs++)=1.91333009916706898; /* coeffs -a1[6] */
    *(coeffs++)=-0.07155954332594562; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.85152342925275137; /* coeffs -a2[7] */
    *(coeffs++)=-0.03202461411387179; /* coeffs +b2[7] */
    *(coeffs++)=1.84206400062150655; /* coeffs -a1[7] */
    *(coeffs++)=0.04655197957071510; /* coeffs +b1[7] */
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
