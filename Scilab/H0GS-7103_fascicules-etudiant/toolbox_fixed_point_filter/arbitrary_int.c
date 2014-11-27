/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_arbitrary short int
# define int_32_arbitrary long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_arbitrary coeffs_16bits_arbitrary[9]={
       -24802 /* cel +1:  b0.2^15 */
       ,29657 /*  cel +2:  B1.2^8 */
       ,46 /*  cel +2:  A11.2^8 */
       ,-23873 /*  cel +2:  C1.2^9 */
       ,31308 /*  cel +3:  B1.2^14 */
       ,-6710 /*  cel +3:  A11.2^14 */
       ,-18976 /*  cel +3:  C1.2^15 */
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
      p_arbitrary->nb_coeffs=9;
      p_arbitrary->nb_states=2;
      p_arbitrary->coeffs=(int_16_arbitrary *)&(coeffs_16bits_arbitrary[0]);
      states =(int_32_arbitrary *) malloc(2 * sizeof(int_32_arbitrary));
      p_arbitrary->states = states;
      for (is=0;is<2;is++) {
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
    int_32_arbitrary accx_32;
    int_32_arbitrary en_32;
    int_32_arbitrary sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_arbitrary)en_16;
    en_32=(int_32_arbitrary)(en_32); /* en<-en .2^0 */
    en_32=-24802* ( (int_16_arbitrary) en_32); /* en<-b0 . en */
    en_32=en_32>>14; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_arbitrary)en_16;
    vn_16=(int_16_arbitrary)(en_32>>8); /* vn<-en<<L ,L=-8*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_arbitrary)((*states)>>13);
    accx_32=29657*vn_16; /* accx<-b1.vn */
    accx_32+=46*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32=accx_32>>8; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-13] */
    states++;
    en_32+=-23873*x1_16; /* sn<-sn+C1 . x1_16 */
     /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_arbitrary)en_16;
    vn_16=(int_16_arbitrary)(en_32>>1); /* vn<-en<<L ,L=-1*/
    en_32= 0; /* sn<-0,because D=0 */
    x1_16=(int_16_arbitrary)((*states)>>1);
    accx_32=31308*vn_16; /* accx<-b1.vn */
    accx_32+=-6710*x1_16; /* accx<-accx-a11 . x1_16 */
    accx_32=accx_32>>14; /* accx<-accx >> Lx1 */
    (*states)+= accx_32; /* update state(1) */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-1] */
    states++;
    en_32+=-18976*x1_16; /* sn<-sn+C1 . x1_16 */
    en_32=en_32>>13; /* scale output of cel 3*/
    sn_32+=en_32;
    sn_32=sn_32>>1; /* scale global output */
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
