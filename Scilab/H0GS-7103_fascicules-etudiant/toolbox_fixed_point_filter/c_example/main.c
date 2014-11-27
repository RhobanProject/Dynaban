/* 
 * File:   main.c
 * Author: ygorra
 *
 * Created on 15 juin 2010, 09:25
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "band_stop.h"
#include "band_pass.h"
#include "low_pass.h"
#include "high_pass.h"
#include "arbitrary.h"
#include "statistics.h"

void compare_high_pass(void) {
    const double PI = 3.141592653589793115998;
    long int n = 0, NB_ECHS = 200000, N_MES = 100000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double f_ech = 20000; /* sampling frequency hz */
    double f_reelle = 502.5; /* real frequency hz, try also 502.5hz (where gain <0.01) */
    double freq_en = f_reelle / f_ech; /* f/fe */
    double w_en = 2 * PI*freq_en;
    double en;
    int_16_high_pass en_16;
    double phi_n = 0;
    double sn, sn_16, errn;
    p_real_filter_high_pass f_real_high_pass = new_real_filter_high_pass();
    p_16bits_filter_high_pass p_high_pass = new_16bits_filter_high_pass();
    struct_statistics* p_statistics_sn = new_struct_statistics();
    struct_statistics* p_statistics_sn_16 = new_struct_statistics();
    struct_statistics* p_statistics_errn = new_struct_statistics();

    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        en_16 = (int_16_high_pass) floor(en + 0.5);
        sn_16 = (double) one_step_16bits_filter_high_pass(en_16, p_high_pass);
        sn = one_step_real_filter_high_pass(en, f_real_high_pass);
        errn = sn - sn_16;
        if (n > N_MES) {
            update_struct_statistics(sn, p_statistics_sn);
            update_struct_statistics(sn_16, p_statistics_sn_16);
            update_struct_statistics(errn, p_statistics_errn);
        }
        phi_n += w_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_high_pass(f_real_high_pass);
    destroy_16bits_filter_high_pass(p_high_pass);
    finalize_struct_statistics(p_statistics_sn);
    finalize_struct_statistics(p_statistics_sn_16);
    finalize_struct_statistics(p_statistics_errn);
    printf("----------------------------------\n");
    printf("--results for high_pass filter   --\n");
    printf("----------------------------------\n");
    printf("  sampling frequency hz       =%e\n", f_ech);
    printf("  input signal frequency  hz  =%e\n", f_reelle);
    printf("  input signal amplitude      =%e\n", amp_en);
    printf("  nb_echs =%ld, corresponding time (s)=%e\n", NB_ECHS, NB_ECHS / f_ech);
    printf("  first measure ech=%ld, corresponding time (s)=%e\n", N_MES, N_MES / f_ech);
    print_struct_statistics(p_statistics_sn, " real output");
    print_struct_statistics(p_statistics_sn_16, " integer output");
    print_struct_statistics(p_statistics_errn, " output error");
    destroy_struct_statistics(p_statistics_sn);
    destroy_struct_statistics(p_statistics_sn_16);
    destroy_struct_statistics(p_statistics_errn);

}
void compare_arbitrary(void) {
    const double PI = 3.141592653589793115998;
    long int n = 0, NB_ECHS = 200000, N_MES = 100000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double f_ech = 20000; /* sampling frequency hz */
    double f_reelle = 502.5; /* real frequency hz, try also 502.5hz (where gain <0.01) */
    double freq_en = f_reelle / f_ech; /* f/fe */
    double w_en = 2 * PI*freq_en;
    double en;
    int_16_arbitrary en_16;
    double phi_n = 0;
    double sn, sn_16, errn;
    p_real_filter_arbitrary f_real_arbitrary = new_real_filter_arbitrary();
    p_16bits_filter_arbitrary p_arbitrary = new_16bits_filter_arbitrary();
    struct_statistics* p_statistics_sn = new_struct_statistics();
    struct_statistics* p_statistics_sn_16 = new_struct_statistics();
    struct_statistics* p_statistics_errn = new_struct_statistics();

    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        en_16 = (int_16_arbitrary) floor(en + 0.5);
        sn_16 = (double) one_step_16bits_filter_arbitrary(en_16, p_arbitrary);
        sn = one_step_real_filter_arbitrary(en, f_real_arbitrary);
        errn = sn - sn_16;
        if (n > N_MES) {
            update_struct_statistics(sn, p_statistics_sn);
            update_struct_statistics(sn_16, p_statistics_sn_16);
            update_struct_statistics(errn, p_statistics_errn);
        }
        phi_n += w_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_arbitrary(f_real_arbitrary);
    destroy_16bits_filter_arbitrary(p_arbitrary);
    finalize_struct_statistics(p_statistics_sn);
    finalize_struct_statistics(p_statistics_sn_16);
    finalize_struct_statistics(p_statistics_errn);
    printf("----------------------------------\n");
    printf("--results for arbitrary filter   --\n");
    printf("----------------------------------\n");
    printf("  sampling frequency hz       =%e\n", f_ech);
    printf("  input signal frequency  hz  =%e\n", f_reelle);
    printf("  input signal amplitude      =%e\n", amp_en);
    printf("  nb_echs =%ld, corresponding time (s)=%e\n", NB_ECHS, NB_ECHS / f_ech);
    printf("  first measure ech=%ld, corresponding time (s)=%e\n", N_MES, N_MES / f_ech);
    print_struct_statistics(p_statistics_sn, " real output");
    print_struct_statistics(p_statistics_sn_16, " integer output");
    print_struct_statistics(p_statistics_errn, " output error");
    destroy_struct_statistics(p_statistics_sn);
    destroy_struct_statistics(p_statistics_sn_16);
    destroy_struct_statistics(p_statistics_errn);

}
void compare_low_pass(void) {
    const double PI = 3.141592653589793115998;
    long int n = 0, NB_ECHS = 200000, N_MES = 100000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double f_ech = 20000; /* sampling frequency hz */
    double f_reelle = 502.5; /* real frequency hz, try also 502.5hz (where gain <0.01) */
    double freq_en = f_reelle / f_ech; /* f/fe */
    double w_en = 2 * PI*freq_en;
    double en;
    int_16_low_pass en_16;
    double phi_n = 0;
    double sn, sn_16, errn;
    p_real_filter_low_pass f_real_low_pass = new_real_filter_low_pass();
    p_16bits_filter_low_pass p_low_pass = new_16bits_filter_low_pass();
    struct_statistics* p_statistics_sn = new_struct_statistics();
    struct_statistics* p_statistics_sn_16 = new_struct_statistics();
    struct_statistics* p_statistics_errn = new_struct_statistics();

    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        en_16 = (int_16_low_pass) floor(en + 0.5);
        sn_16 = (double) one_step_16bits_filter_low_pass(en_16, p_low_pass);
        sn = one_step_real_filter_low_pass(en, f_real_low_pass);
        errn = sn - sn_16;
        if (n > N_MES) {
            update_struct_statistics(sn, p_statistics_sn);
            update_struct_statistics(sn_16, p_statistics_sn_16);
            update_struct_statistics(errn, p_statistics_errn);
        }
        phi_n += w_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_low_pass(f_real_low_pass);
    destroy_16bits_filter_low_pass(p_low_pass);
    finalize_struct_statistics(p_statistics_sn);
    finalize_struct_statistics(p_statistics_sn_16);
    finalize_struct_statistics(p_statistics_errn);
    printf("----------------------------------\n");
    printf("--results for low_pass filter   --\n");
    printf("----------------------------------\n");
    printf("  sampling frequency hz       =%e\n", f_ech);
    printf("  input signal frequency  hz  =%e\n", f_reelle);
    printf("  input signal amplitude      =%e\n", amp_en);
    printf("  nb_echs =%ld, corresponding time (s)=%e\n", NB_ECHS, NB_ECHS / f_ech);
    printf("  first measure ech=%ld, corresponding time (s)=%e\n", N_MES, N_MES / f_ech);
    print_struct_statistics(p_statistics_sn, " real output");
    print_struct_statistics(p_statistics_sn_16, " integer output");
    print_struct_statistics(p_statistics_errn, " output error");
    destroy_struct_statistics(p_statistics_sn);
    destroy_struct_statistics(p_statistics_sn_16);
    destroy_struct_statistics(p_statistics_errn);

}
void compare_band_pass(void) {
    const double PI = 3.141592653589793115998;
    long int n = 0, NB_ECHS = 200000, N_MES = 100000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double f_ech = 20000; /* sampling frequency hz */
    double f_reelle = 300; /* real frequency hz */
    double freq_en = f_reelle / f_ech; /* f/fe */
    double w_en = 2 * PI*freq_en;
    double en;
    int_16_band_pass en_16;
    double phi_n = 0;
    double sn, sn_16, errn;
    p_real_filter_band_pass f_real_band_pass = new_real_filter_band_pass();
    p_16bits_filter_band_pass p_band_pass = new_16bits_filter_band_pass();
    struct_statistics* p_statistics_sn = new_struct_statistics();
    struct_statistics* p_statistics_sn_16 = new_struct_statistics();
    struct_statistics* p_statistics_errn = new_struct_statistics();

    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        en_16 = (int_16_band_pass) floor(en + 0.5);
        sn_16 = (double) one_step_16bits_filter_band_pass(en_16, p_band_pass);
        sn = one_step_real_filter_band_pass(en, f_real_band_pass);
        errn = sn - sn_16;
        if (n > N_MES) {
            update_struct_statistics(sn, p_statistics_sn);
            update_struct_statistics(sn_16, p_statistics_sn_16);
            update_struct_statistics(errn, p_statistics_errn);
        }
        phi_n += w_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_pass(f_real_band_pass);
    destroy_16bits_filter_band_pass(p_band_pass);
    finalize_struct_statistics(p_statistics_sn);
    finalize_struct_statistics(p_statistics_sn_16);
    finalize_struct_statistics(p_statistics_errn);
    printf("----------------------------------\n");
    printf("--results for band_pass filter   --\n");
    printf("----------------------------------\n");
    printf("  sampling frequency hz       =%e\n", f_ech);
    printf("  input signal frequency  hz  =%e\n", f_reelle);
    printf("  input signal amplitude      =%e\n", amp_en);
    printf("  nb_echs =%ld, corresponding time (s)=%e\n", NB_ECHS, NB_ECHS / f_ech);
    printf("  first measure ech=%ld, corresponding time (s)=%e\n", N_MES, N_MES / f_ech);
    print_struct_statistics(p_statistics_sn, " real output");
    print_struct_statistics(p_statistics_sn_16, " integer output");
    print_struct_statistics(p_statistics_errn, " output error");
    destroy_struct_statistics(p_statistics_sn);
    destroy_struct_statistics(p_statistics_sn_16);
    destroy_struct_statistics(p_statistics_errn);

}

void compare_band_stop(void) {
    const double PI = 3.141592653589793115998;
    long int n = 0, NB_ECHS = 100000, N_MES = 50000; /* YOU CAN CHANGE THIS  */
    double amp_en = 10000; /* amplitude of input */
    double f_ech = 20000; /* sampling frequency hz */
    double f_reelle = 100; /* real frequency hz */
    double freq_en = f_reelle / f_ech; /* f/fe */
    double w_en = 2 * PI*freq_en;
    double en;
    int_16_band_stop en_16;
    double phi_n = 0;
    double sn, sn_16, errn;
    p_real_filter_band_stop f_real_band_stop = new_real_filter_band_stop();
    p_16bits_filter_band_stop p_band_stop = new_16bits_filter_band_stop();
    struct_statistics* p_statistics_sn = new_struct_statistics();
    struct_statistics* p_statistics_sn_16 = new_struct_statistics();
    struct_statistics* p_statistics_errn = new_struct_statistics();

    for (n = 0; n < NB_ECHS; n++) {
        en = amp_en * cos(phi_n);
        en_16 = (int_16_band_stop) floor(en + 0.5);
        sn_16 = (double) one_step_16bits_filter_band_stop(en_16, p_band_stop);
        sn = one_step_real_filter_band_stop(en, f_real_band_stop);
        errn = sn - sn_16;
        if (n > N_MES) {
            update_struct_statistics(sn, p_statistics_sn);
            update_struct_statistics(sn_16, p_statistics_sn_16);
            update_struct_statistics(errn, p_statistics_errn);
        }
        phi_n += w_en;
        if (phi_n > 2 * PI) {
            phi_n -= 2 * PI;
        }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_stop(f_real_band_stop);
    destroy_16bits_filter_band_stop(p_band_stop);
    finalize_struct_statistics(p_statistics_sn);
    finalize_struct_statistics(p_statistics_sn_16);
    finalize_struct_statistics(p_statistics_errn);
    printf("----------------------------------\n");
    printf("--results for band_stop filter   --\n");
    printf("----------------------------------\n");
    printf("  sampling frequency hz       =%e\n", f_ech);
    printf("  input signal frequency  hz  =%e\n", f_reelle);
    printf("  input signal amplitude      =%e\n", amp_en);
    printf("  nb_echs =%ld, corresponding time (s)=%e\n", NB_ECHS, NB_ECHS / f_ech);
    printf("  first measure ech=%ld, corresponding time (s)=%e\n", N_MES, N_MES / f_ech);
    print_struct_statistics(p_statistics_sn, " real output");
    print_struct_statistics(p_statistics_sn_16, " integer output");
    print_struct_statistics(p_statistics_errn, " output error");
    destroy_struct_statistics(p_statistics_sn);
    destroy_struct_statistics(p_statistics_sn_16);
    destroy_struct_statistics(p_statistics_errn);

}

/*
 * 
 */
int main(int argc, char** argv) {
    compare_band_stop();
    compare_band_pass();
    compare_low_pass();
    compare_high_pass();
    compare_arbitrary();

    return (EXIT_SUCCESS);
}

