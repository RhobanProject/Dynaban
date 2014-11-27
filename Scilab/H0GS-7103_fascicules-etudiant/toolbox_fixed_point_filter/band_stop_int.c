/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_band_stop short int
# define int_32_band_stop long int
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_band_stop coeffs_16bits_band_stop[26]={
       32064 /* cel +1:  b0.2^15 */
       ,14881 /*  cel +2:  -a1.2^13 */
       ,-21626 /*  cel +2:  -a2.2^13 */
       ,17662 /*  cel +2:  b1.2^17, note that b0=0 */
       ,4552 /*  cel +2:  b2.2^17 */
       ,15101 /*  cel +3:  -a1.2^13 */
       ,-19837 /*  cel +3:  -a2.2^13 */
       ,7098 /*  cel +3:  b1.2^16, note that b0=0 */
       ,-16863 /*  cel +3:  b2.2^16 */
       ,26100 /*  cel +4:  -a1.2^14 */
       ,-18240 /*  cel +4:  -a2.2^14 */
       ,-11440 /*  cel +4:  b1.2^15, note that b0=0 */
       ,16734 /*  cel +4:  b2.2^15 */
       ,22172 /*  cel +5:  -a1.2^14 */
       ,-28290 /*  cel +5:  -a2.2^14 */
       ,-25408 /*  cel +5:  b1.2^15, note that b0=0 */
       ,11816 /*  cel +5:  b2.2^15 */
       ,18103 /*  cel +6:  -a1.2^15 */
       ,-12841 /*  cel +6:  -a2.2^15 */
       ,-29877 /*  cel +6:  b1.2^14, note that b0=0 */
       ,30075 /*  cel +6:  b2.2^14 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_band_stop *coeffs;
      int_32_band_stop *states;
    }s_16bits_filter_band_stop;
    typedef s_16bits_filter_band_stop *p_16bits_filter_band_stop;
  /* creator of structure p_16bits_filter_band_stop */
    p_16bits_filter_band_stop new_16bits_filter_band_stop() {
      p_16bits_filter_band_stop p_band_stop;
      p_band_stop = (s_16bits_filter_band_stop *) malloc(sizeof(s_16bits_filter_band_stop));
      int_32_band_stop *states;
      int is;
      p_band_stop->nb_coeffs=26;
      p_band_stop->nb_states=10;
      p_band_stop->coeffs=(int_16_band_stop *)&(coeffs_16bits_band_stop[0]);
      states =(int_32_band_stop *) malloc(10 * sizeof(int_32_band_stop));
      p_band_stop->states = states;
      for (is=0;is<10;is++) {
        *(states++)=0;
      }
      return p_band_stop;
    } /* p_16bits_filter_band_stop new_16bits_filter_band_stop()  */
  /* destructor of structure p_16bits_filter_band_stop */
    void  destroy_16bits_filter_band_stop(p_16bits_filter_band_stop p_band_stop) {
      free((void *) (p_band_stop->states) ); /* release memory allocated for states */
      free((void *)p_band_stop) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_band_stop(p_16bits_filter_band_stop p_band_stop) */
  int_32_band_stop one_step_16bits_filter_band_stop(int_16_band_stop en_16 , p_16bits_filter_band_stop p_band_stop) {
    int_16_band_stop *coeffs;
    int_32_band_stop *states;
    coeffs=p_band_stop->coeffs;
    states=p_band_stop->states;
    int_32_band_stop tmp_32;
    int_16_band_stop vn_16;
    int_16_band_stop x1_16;
    int_16_band_stop x2_16;
    int_32_band_stop en_32;
    int_32_band_stop sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_band_stop)en_16;
    en_32=(int_32_band_stop)(en_32); /* en<-en .2^0 */
    en_32=32064* ( (int_16_band_stop) en_32); /* en<-b0 . en */
    en_32=en_32>>4; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_band_stop)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-5,LA=13*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_band_stop)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_band_stop)(tmp_32>>1);
    en_32+=14881*x1_16; /* en<-en - a1 . x1 */
    en_32+=-21626*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>12; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_stop)(tmp_32>>1);
    en_32=17662*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=4552*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    en_32=en_32>>1; /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_band_stop)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-5,LA=13*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_band_stop)(tmp_32>>1);
    tmp_32=(* (states+1))>>6; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_band_stop)(tmp_32>>1);
    en_32+=15101*x1_16; /* en<-en - a1 . x1 */
    en_32+=-19837*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>12; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_stop)(tmp_32>>1);
    en_32=7098*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-16863*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-7] */
    states++;
     /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_band_stop)en_16;
    en_32=en_32<<11; /* en<-en<<L+LA ,L=-3,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_band_stop)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_band_stop)(tmp_32>>1);
    en_32+=26100*x1_16; /* en<-en - a1 . x1 */
    en_32+=-18240*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_stop)(tmp_32>>1);
    en_32=-11440*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=16734*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    en_32=en_32>>1; /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_band_stop)en_16;
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-2,LA=14*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_band_stop)(tmp_32>>1);
    tmp_32=(* (states+1))>>6; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_band_stop)(tmp_32>>1);
    en_32+=22172*x1_16; /* en<-en - a1 . x1 */
    en_32+=-28290*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_stop)(tmp_32>>1);
    en_32=-25408*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=11816*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-7] */
    states++;
    en_32=en_32>>2; /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_band_stop)en_16;
    en_32=en_32<<14; /* en<-en<<L+LA ,L=-1,LA=15*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_band_stop)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_band_stop)(tmp_32>>1);
    en_32+=18103*x1_16; /* en<-en - a1 . x1 */
    en_32+=-12841*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_stop)(tmp_32>>1);
    en_32=-29877*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=30075*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    en_32=en_32>>2; /* scale output of cel 6*/
    sn_32+=en_32;
    tmp_32=sn_32>>10; /* scale global output */
    tmp_32+=1;
    sn_32=tmp_32>>1;
    return  ( sn_32) ;
  } /* int_32_band_stop one_step_+16bits_filter_band_stop(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_band_stop(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_band_stop en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_band_stop p_band_stop=new_16bits_filter_band_stop();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_band_stop) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_band_stop(en_16 , p_band_stop) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_band_stop(p_band_stop) ;
    } /* void teste_16bits_filter_band_stop(void)  */
