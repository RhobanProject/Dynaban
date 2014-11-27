#include <math.h>
#include <stdio.h>
#include "fir.h"
#include "scilab_generated_fir.h"
#include "statistics.h"
#ifndef PI
#define PI 3.14159265358979323846	/* pi */
#endif

void init_fir_int_16(s_fir *s, int_16 gn[], int size_gn, int LC) {
    // initialiser le contenu de la structure
    //  pour quelle fonctionne de maniere autonome
    // 1- copier les echantillons de gn[] dans le tableau de la structure
    // 2- copier le nb d'echantillons
    // 3- initialiser le buffer tournant  ( entrees passees )
}

void end_fir_int_16(s_fir *s) {
    // liberer les ressources employees par le fir,
    // ici il n'y a rien a faire
}

void one_step_fir_int_16(s_fir *s, int_16 en_16) {
    // mettre a jour la sortie sn_32 et les 'memoires= entrees passees' du filtre
        s->sn_32=en_16; // a modifier , et il faudra plus d'une ligne

}

void init_fir_double(s_fir *s, double gn[], int size_gn) {
    // initialiser le contenu de la structure
    //  pour quelle fonctionne de maniere autonome
    // 1- copier les echantillons de gn[] dans le tableau de la structure
    // 2- copier le nb d'echantillons
    // 3- initialiser le buffer tournant  ( entrees passees )
}

void end_fir_double(s_fir *s) {
    // liberer les ressources employees par le fir,
    // ici il n'y a rien a faire
}

void one_step_fir_double(s_fir *s, double en) {
    // mettre a jour la sortie sn et les entrees passes (memoires) dans s
    s->sn=en; // a modifier , et il faudra plus d'une ligne
}

void teste_fir() {
    int N_TEST = 1000, N_MESURE = 10;
    s_fir fir_test;
    double gn[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int_16 gn_16[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    // for sn statistics
    struct_statistics sn_stats, errn_stats;
    double sn, errn,sn_32;
    // entree :
    double en=1.2; // juste pour le test
    // cree un nouveau filtre FIR 
    init_fir_int_16(&fir_test, gn_16, 10, 0);
    init_fir_double(&fir_test, gn, 10);
    // boucle de test du filtre
    for (int n = 0; n < N_TEST; n++) {
        en =n; // entree e(n), en fonction de n, a modifier
        // mise a jour des sorties , en fonction  de la nouvelle entree
        one_step_fir_double(&fir_test, en);
        one_step_fir_int_16(&fir_test, (int_16) en);
        // affichage eventuel des signaux (deconseille, peu informatif)
        sn = fir_test.sn;
        sn_32=fir_test.sn_32;
        errn = fir_test.sn - fir_test.sn_32;
        printf(" e(%d)= %e ; s(%d) = %e; s_32(%d) =%e \n",n,en,n,sn,n,sn_32);
        // mise a jour (muette )des statistiques
        if (n == N_MESURE) {
            init_statistics(&sn_stats, sn);
            init_statistics(&errn_stats, errn);
        }
        if (n >= N_MESURE) {
            update_statistics(&sn_stats, sn);
            update_statistics(&errn_stats, errn);
        }
    }
    // finalise et affiche les statistiques des signaux
    finalize_statistics(&sn_stats);
    finalize_statistics(&errn_stats);
    show_statistics(&sn_stats, "sortie ");
    show_statistics(&errn_stats,"erreur");
    // libere les ressources employees par les filtres fir
    end_fir_double(&fir_test);
    end_fir_int_16(&fir_test);
}
