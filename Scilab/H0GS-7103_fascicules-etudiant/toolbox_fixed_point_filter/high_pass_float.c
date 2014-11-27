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
  }s_real_filter_high_pass;
  typedef s_real_filter_high_pass *p_real_filter_high_pass ;
  double one_step_real_filter_high_pass(double en,p_real_filter_high_pass f) {
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
  } /*double one_step_real_filter_high_pass(...)*/
  p_real_filter_high_pass get_memory_real_filter_high_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_high_pass f=malloc(sizeof(s_real_filter_high_pass));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_high_pass new_real_filter_high_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_high_pass(p_real_filter_high_pass f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_high_pass(p_real_filter_high_pass f) */
  p_real_filter_high_pass new_real_filter_high_pass() {
  /* 16 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_high_pass f =get_memory_real_filter_high_pass(16,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.94912248756956852; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99942815234598659; /* coeffs -a2[2] */
    *(coeffs++)=0.00053420994155514; /* coeffs +b2[2] */
    *(coeffs++)=1.99845336039456667; /* coeffs -a1[2] */
    *(coeffs++)=-0.00051268701138111; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99829168507035604; /* coeffs -a2[3] */
    *(coeffs++)=0.00385677532306198; /* coeffs +b2[3] */
    *(coeffs++)=1.99733802282672857; /* coeffs -a1[3] */
    *(coeffs++)=-0.00385045270539719; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.99717516311090482; /* coeffs -a2[4] */
    *(coeffs++)=0.00743011452251806; /* coeffs +b2[4] */
    *(coeffs++)=1.99626226386232974; /* coeffs -a1[4] */
    *(coeffs++)=-0.00763672433190982; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.99609072025762302; /* coeffs -a2[5] */
    *(coeffs++)=0.00250026191051427; /* coeffs +b2[5] */
    *(coeffs++)=1.99523642415404057; /* coeffs -a1[5] */
    *(coeffs++)=-0.00304985280417241; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.99505010623690671; /* coeffs -a2[6] */
    *(coeffs++)=-0.01409922576069710; /* coeffs +b2[6] */
    *(coeffs++)=1.99426968565573137; /* coeffs -a1[6] */
    *(coeffs++)=0.01339998088320779; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.99406456433371637; /* coeffs -a2[7] */
    *(coeffs++)=-0.03607968830382295; /* coeffs +b2[7] */
    *(coeffs++)=1.99337006240047665; /* coeffs -a1[7] */
    *(coeffs++)=0.03563380936249054; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    *(coeffs++)=-0.99314471540914051; /* coeffs -a2[8] */
    *(coeffs++)=-0.05368755503709748; /* coeffs +b2[8] */
    *(coeffs++)=1.99254442597648973; /* coeffs -a1[8] */
    *(coeffs++)=0.05383279091553757; /* coeffs +b1[8] */
    *(coeffs++)=0; /* coeffs +b0[8] */
    *(states++)=0;/* xn_2[8]=0 */
    *(states++)=0;/* xn_1[8]=0 */
    *(coeffs++)=-0.9923004492422688; /* coeffs -a2[9] */
    *(coeffs++)=-0.05943193346289335; /* coeffs +b2[9] */
    *(coeffs++)=1.99179856043282277; /* coeffs -a1[9] */
    *(coeffs++)=0.06026294152512061; /* coeffs +b1[9] */
    *(coeffs++)=0; /* coeffs +b0[9] */
    *(states++)=0;/* xn_2[9]=0 */
    *(states++)=0;/* xn_1[9]=0 */
    *(coeffs++)=-0.99154082405458666; /* coeffs -a2[10] */
    *(coeffs++)=-0.05031251547903391; /* coeffs +b2[10] */
    *(coeffs++)=1.9911372403678289; /* coeffs -a1[10] */
    *(coeffs++)=0.05166223791112473; /* coeffs +b1[10] */
    *(coeffs++)=0; /* coeffs +b0[10] */
    *(states++)=0;/* xn_2[10]=0 */
    *(states++)=0;/* xn_1[10]=0 */
    *(coeffs++)=-0.99087397500878283; /* coeffs -a2[11] */
    *(coeffs++)=-0.02758427109329164; /* coeffs +b2[11] */
    *(coeffs++)=1.99056432528220739; /* coeffs -a1[11] */
    *(coeffs++)=0.02911605220757743; /* coeffs +b1[11] */
    *(coeffs++)=0; /* coeffs +b0[11] */
    *(states++)=0;/* xn_2[11]=0 */
    *(states++)=0;/* xn_1[11]=0 */
    *(coeffs++)=-0.99030703240877060; /* coeffs -a2[12] */
    *(coeffs++)=0.00450972178394285; /* coeffs +b2[12] */
    *(coeffs++)=1.9900828629342304; /* coeffs -a1[12] */
    *(coeffs++)=-0.00316846852330907; /* coeffs +b1[12] */
    *(coeffs++)=0; /* coeffs +b0[12] */
    *(states++)=0;/* xn_2[12]=0 */
    *(states++)=0;/* xn_1[12]=0 */
    *(coeffs++)=-0.98984605026045447; /* coeffs -a2[13] */
    *(coeffs++)=0.04019006943952072; /* coeffs +b2[13] */
    *(coeffs++)=1.98969519442392739; /* coeffs -a1[13] */
    *(coeffs++)=-0.03932628588445313; /* coeffs +b1[13] */
    *(coeffs++)=0; /* coeffs +b0[13] */
    *(states++)=0;/* xn_2[13]=0 */
    *(states++)=0;/* xn_1[13]=0 */
    *(coeffs++)=-0.98949594578067190; /* coeffs -a2[14] */
    *(coeffs++)=0.07341317852274050; /* coeffs +b2[14] */
    *(coeffs++)=1.98940305404933415; /* coeffs -a1[14] */
    *(coeffs++)=-0.07314981608727389; /* coeffs +b1[14] */
    *(coeffs++)=0; /* coeffs +b0[14] */
    *(states++)=0;/* xn_2[14]=0 */
    *(states++)=0;/* xn_1[14]=0 */
    *(coeffs++)=-0.98926045036242338; /* coeffs -a2[15] */
    *(coeffs++)=0.09885509648367860; /* coeffs +b2[15] */
    *(coeffs++)=1.98920765760232499; /* coeffs -a1[15] */
    *(coeffs++)=-0.09912770403531543; /* coeffs +b1[15] */
    *(coeffs++)=0; /* coeffs +b0[15] */
    *(states++)=0;/* xn_2[15]=0 */
    *(states++)=0;/* xn_1[15]=0 */
    *(coeffs++)=-0.98914207241691854; /* coeffs -a2[16] */
    *(coeffs++)=0.11260587345602306; /* coeffs +b2[16] */
    *(coeffs++)=1.98910977367347908; /* coeffs -a1[16] */
    *(coeffs++)=-0.1131914359805812; /* coeffs +b1[16] */
    *(coeffs++)=0; /* coeffs +b0[16] */
    *(states++)=0;/* xn_2[16]=0 */
    *(states++)=0;/* xn_1[16]=0 */
    return f;
  }/* p_real_filter_high_pass new_real_filter_high_pass() */
 void teste_real_high_pass(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_high_pass f_real_high_pass=new_real_filter_high_pass();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_high_pass(en,f_real_high_pass) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_high_pass(f_real_high_pass) ;
  } /* void teste_real_high_pass(void)  */
