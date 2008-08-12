;*----------------------------------------------------------------------------*\
;                                                                              |
; Copyright (C) 2001, 2003  James A. Cureington                                |
;                           tonycu@users.sourceforge.net                       |
;                                                                              |
; This program is free software; you can redistribute it and/or                |
; modify it under the terms of the GNU General Public License                  |
; as published by the Free Software Foundation; either version 2               |
; of the License, or any later version.                                        |
;                                                                              |
; This program is distributed in the hope that it will be useful,              |
; but WITHOUT ANY WARRANTY; without even the implied warranty of               |
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                |
; GNU General Public License for more details.                                 |
;                                                                              |
; You should have received a copy of the GNU General Public License            |
; along with this program; if not, write to the Free Software                  |
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.                    |
;                                                                              |
;                                                                              |
; Tony Cureington                                                              |
; October 31, 2000                                                             |
;                                                                              |
;                                                                              |
; This file is associated with the ezusb2131 Linux downloader project. The     |
; project can be found at http://sourceforge.net/projects/ezusb2131.           |
;                                                                              |
;*----------------------------------------------------------------------------*/

;******************************************************************************\
; 
;
;******************************************************************************/
;
; Timing loop derived from the buttons and lights example in USB Design 
; by Example.
; Number of milli-seconds to wait is passed in first parameter.
;
; TODO: this needs to be re-calculated
;
	.globl	_wait_msec	

	.area DSEG (DATA)
_wait_msec_Msecs:	.ds	2

	.area CSEG (CODE)
_wait_msec:
	mov	_wait_msec_Msecs,dpl	  ; first parameter passed to routine
	mov	(_wait_msec_Msecs+1),dph  ; is in dptr; see sdccman.txt or
                                          ; sdccman.txt for info on params
Wait1msec:			; A delay loop
	;mov	dptr,#-1200
	mov	dph,#0xFB       ; prevent large constant warning cause by above
	mov	dpl,#0x50
More:   inc	dptr		;   3 cycles
	mov	a,dpl		; + 2
	orl	a,dph		; + 2
	jnz	More		; + 3 = 10 cycles x 1200 = 1msec
	djnz	_wait_msec_Msecs,Wait1msec

	ret


