/*----------------------------------------------------------------------------*\
|                                                                              |
| Copyright (C) 2003,  James A. Cureington                                     |
|                      tonycu * users_sourceforge_net                          |
|                                                                              |
| This program is free software; you can redistribute it and/or                |
| modify it under the terms of the GNU General Public License                  |
| as published by the Free Software Foundation; either version 2               |
| of the License, or any later version.                                        |
|                                                                              |
| This program is distributed in the hope that it will be useful,              |
| but WITHOUT ANY WARRANTY; without even the implied warranty of               |
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                |
| GNU General Public License for more details.                                 |
|                                                                              |
| You should have received a copy of the GNU General Public License            |
| along with this program; if not, write to the Free Software                  |
| Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.                    |
|                                                                              |
|                                                                              |
| Tony Cureington                                                              |
| October 31, 2000                                                             |
|                                                                              |
|                                                                              |
| This file is associated with the ezusb2131 Linux downloader project. The     |
| project can be found at http://ezusb2131.sourceforge.net.                    |
|                                                                              |
|                                                                              |
\*----------------------------------------------------------------------------*/

/*******************************************************************************
 *
 * $Id: cam_common.h,v 1.1 2003/02/21 06:50:35 tonycu Exp $
 *
 ******************************************************************************/


#ifndef CAM_COMMON_H
#define CAM_COMMON_H

/* change below ids if running outside of a lab environment - vendor ids
 * are issued by admin@usb.org for registration fee.
 */
#define VENDOR_ID  0x0547    /* you need to get a real vendor id */
#define PRODUCT_ID 0x2131    /* cam control 'cc'                 */

#define CC_COMMAND_MOVE     0x01  /* move the camera             */
#define CC_COMMAND_INFO     0x02  /* return a cc_info over ep1   */
#define CC_COMMAND_STOP     0x04  /* stop the camera from moving */

#define MAX_HORIZONTAL        45  /* interface limits, this is   */
#define MIN_HORIZONTAL       -45  /* just to limit the range of  */
#define MAX_VERTICAL          20  /* motion so cables don't get  */
#define MIN_VERTICAL         -20  /* wrapped in the demo...      */

#define MAX_DEGREES           90  /* firmware x/y limits */
#define MIN_DEGREES          -90

typedef struct
{
	char command;
	char new_horizontal_deg;  /* +90 to -90 */
	char new_vertical_deg; 
} cc_command; /* cam control command */

typedef struct
{
	char current_hdeg;  /* current horizontal degrees                     */ 
	char current_vdeg;  /* current vertical degrees                       */
	char final_hdeg;    /* the final horizontal degrees after servos stop */ 
	char final_vdeg;    /* the final vertical degrees after servos stop   */

} cc_info; /* cam control info */

#endif /* CAM_COMMON_H */

