
/*************************************************************************
*  File Name	: 'trajectory_manager.cpp'
*  Author	: Remi FABRE
*  Contact      : remi.fabre@labri.fr
*  Created	: vendredi, février  6 2015
*  Licence	: http://creativecommons.org/licenses/by-nc-sa/3.0/
*
*  Notes:
*************************************************************************/

#include "trajectory_manager.h"


uint16 traj_constant_speed(uint16 pDistance, uint16 pTotalTime, uint16 pTime) {
    return ((float)pDistance/(float)pTotalTime) * pTime;
}

uint16 traj_min_jerk(uint16 pTime) {
    float time   = ((float)pTime)/10000.0;
    float time_3 = time*time*time;
    float time_4 = time_3*time;
    float time_5 = time_4*time;
    int16 a3     = 20480;
    int16 a4     = -30720;
    int16 a5     = 12288;

    return time_3*a3 + time_4*a4 + time_5*a5;
}
