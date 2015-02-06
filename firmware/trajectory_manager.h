/*************************************************************************
*  File Name	: 'trajectory_manager.h'
*  Author	    : Remi FABRE
*  Contact      : remi.fabre@labri.fr
*  Created	    : vendredi, février  6 2015
*  Licence	    : http://creativecommons.org/licenses/by-nc-sa/3.0/
*
*  Notes:
*************************************************************************/

#include <wirish/wirish.h>
#if !defined(TRAJECTORY_MANAGER_H)
#define TRAJECTORY_MANAGER_H

uint16 traj_constant_speed(uint16 pDistance, uint16 pTotalTime, uint16 pTime);
uint16 traj_min_jerk(uint16 pTime);


#endif
