
#include <math.h>
#include <stdio.h>
#include "statistics.h"

void init_statistics(struct_statistics *s, double x) {
    // initialize min, max and sums
    s->max = s->min = x;
    s->pow = s->mean = 0;
    s->nb_sample = 0;
    s->is_finalized = 0; // statistics are not finalized
}

void update_statistics(struct_statistics *s, double x) {
    // update min, max and sums , from new x value
    s->mean += x;
    s->pow += x*x;
    if (x > s->max) {
        s->max = x;
    } else if (x < s->min) {
        s->min = x;
    }
    s->nb_sample++;
}

void finalize_statistics(struct_statistics *s) {
    if (s->nb_sample <= 1) {
        // no enough samples to finalize stats
        s->is_finalized = 0;
        return;
    }
    s->is_finalized = 1;
    s->mean /= s->nb_sample;
    s->pow /= s->nb_sample;
    s->var = s->pow - s->mean * s->mean;
    if (s->var < 0) {
        s->var = 0;
    }
    s->rms = sqrt(s->pow);
    s->sd = sqrt(s->var);
}

void show_statistics(struct_statistics *s, char * name_var) {
    if (s->is_finalized == 0) {
        printf("---------------------------------------------------------\n");
        printf("-impossible d'afficher les statistiques de %s         -\n", name_var);
        printf("----------------------------------------------------------\n");
        return;
    }
    printf("---------------------------------------------------------\n");
    printf("- statistiques de %s , etablies sur %d echantillons     -\n", name_var, s->nb_sample);
    printf("----------------------------------------------------------\n");
    printf("min(%s) = %e ,mean(%s) = %e, max(%s) = %e\n",
            name_var, s->min, name_var, s->mean, name_var, s->max);
    printf("rms(%s ) = %e ,standard deviation(%s) = %e\n",
            name_var, s->rms, name_var, s->sd);

}
