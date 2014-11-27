/* 
 * File:   main.c
 * Author: stephane
 *
 * Created on 1 novembre 2008, 16:13
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
/* integer functions */
#define int_16 short int
#define int_32 long int
void init_coeffs_states_int_Fz(int_8 **p_coeffs,int_32 **p_states,int *nb_coeffs,int *nb_states);
extern int_32 one_step_int_Fz(int_16 en_16, int_16 *coeffs, int_32 *states);

/* double precision functions */
typedef struct {
    int nb_cels;
    int nb_coeffs;
    int nb_states;
    double *coeffs;
    double *states;
} s_filter;
typedef s_filter *p_filter;
extern p_filter new_real_filter_Fz(void);
extern double one_step_real_filter(double en, p_filter f);
extern void destroy_real_filter(p_filter f);

void teste__Fz(void) {
    long int n = 0, NB_ECHS = 500000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double freq_en = 0.001; /* f/fe */
    double en;
    const double PI = 3.141592653589793115998;
    double phi_n = 0;
    double sn;
    int_16 en_16;
    int_32 sn_32;
    int_16 *coeffs;
    int_32 *states;
    int nb_coeffs,nb_states;
    int N;
    double err_i, abs_err_i,max_err, pow_err, sigma_err, mean_err;
    init_coeffs_states_int_Fz(&coeffs, &states,&nb_coeffs,&nb_states);
    p_filter f_Fz = new_real_filter_Fz();
    mean_err = 0;
    max_err = 0;
    pow_err = 0;
    N=0;
    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        sn = one_step_real_filter(en, f_Fz);
        en_16 = (int_16) floor(en + 0.5);
        sn_32 = one_step_int_Fz(en_16, coeffs, states);
        err_i = sn - sn_32;
        if (n > NB_ECHS / 2) {
            N=N+1;
            pow_err = pow_err + err_i*err_i;
            mean_err += err_i;
            if (err_i>=0) {
                abs_err_i=err_i;
            }
            else {   
                abs_err_i=-err_i;
            }
            if (abs_err_i > max_err) {
                max_err = abs_err_i;
            }
        }
        if ((n < 10) || (n > NB_ECHS - 10)) {
            printf(" n=%ld, en=%e ,sn=%e,sn_32=%ld\n", n, en, sn, sn_32);
        }
        phi_n += 2 * PI*freq_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    pow_err /= (double) N;
    mean_err /= (double) N;
    sigma_err = pow_err - mean_err*mean_err;
    if (sigma_err < 0) {
        sigma_err = 0;
    }
    sigma_err = sqrt(sigma_err);
    printf(" max error=%e, standard deviation error=%e,mean error=%e\n", max_err, sigma_err, mean_err);
    destroy_real_filter(f_Fz);
}

/* void teste_Fz(void)  */


int main(int argc, char** argv) {
    teste__Fz();
    return (EXIT_SUCCESS);
}

