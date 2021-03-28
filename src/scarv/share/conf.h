/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_CONF_H
#define __LIBSCARV_CONF_H

/* ------------------------------------------------------------------------- */

/** Set maximum number of limbs in an instance of @p mpz_t.
  */
#define LIBSCARV_CONF_MPZ_MAX_LIMBS              34
/** Set maximum number of limbs in an instance of @p mrz_t.
  */
#define LIBSCARV_CONF_MRZ_MAX_LIMBS              34

/** Use a         Un-integrated (i.e.. separate multiplication then reduction) Montgomery multiplication implementation.
  */
#define LIBSCARV_CONF_MRZ_MUL_REDC               0
/** Use a  Coarsely Integrated Operand Scanning (CIOS)                         Montgomery multiplication implementation.
  */
#define LIBSCARV_CONF_MRZ_MUL_CIOS               1

/* ------------------------------------------------------------------------- */

#endif
