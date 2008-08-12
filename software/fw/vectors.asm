;*----------------------------------------------------------------------------*\
;                                                                              |
; Copyright (C) 2002, 2003  James A. Cureington                                |
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
	.area CODE (ABS)
 	.org	0x00
	ljmp	0x800                ;; jump to start of compiled code

;	ljmp	allow_ram_rw

; 	.org	0x43
;	ljmp	autovector_table ; autovector replaces byte 0x45
				              ; see ez-usb tech ref manual v1.9 
                          ; page 9-11 (174) for autovector info


	
;	.area CODE (ABS)
; 	.org	0x100
;autovector_table:               ; from ez-usb TRM figure 6-7
;	ljmp	_sudav_isr	;00
;	.db	0
;	ljmp	_sof_isr	   ;04
;	.db	0
;	ljmp	_sutok_isr	;08
;	.db	0
;	ljmp	_susp_isr	;0C
;	.db	0
;	ljmp	_ures_isr	;10
;	.db	0
;	ljmp	_spare_isr	;14
;	.db	0
;	ljmp	_ep0in_isr	;18
;	.db	0
;	ljmp	_ep0out_isr	;1C
;	.db	0
;	ljmp	_ep1in_isr	;20
;	.db	0
;	ljmp	_ep1out_isr	;24
;	.db	0
;	ljmp	_ep2in_isr	;28
;	.db	0
;	ljmp	_ep2out_isr	;2C
;	.db	0
;	ljmp	_ep3in_isr	;30
;	.db	0
;	ljmp	_ep3out_isr	;34
;	.db	0
;	ljmp	_ep4in_isr	;38
;	.db	0
;	ljmp	_ep4out_isr	;3C
;	.db	0
;	ljmp	_ep5in_isr	;40
;	.db	0
;	ljmp	_ep5out_isr	;44
;	.db	0
;	ljmp	_ep6in_isr	;48
;	.db	0
;	ljmp	_ep6out_isr	;4C
;	.db	0
;	ljmp	_ep7in_isr	;50
;	.db	0
;	ljmp	_ep7out_isr	;54
;	.db	0

	;; we must allow R/W pins so __sdcc_init_data can init the data
	;; in external RAM...                                          
;allow_ram_rw:
; 	.area   CODE (ABS)
;	.org	  0x160
;	mov     0x92,#0x7F           ;; allows movx to access external memory
;
;	mov     dptr,#0x7F93         ;; set PORTA_CONFIG regs to alt function
;	mov     a,#0xFF              ;; this allows R/W pins on port C
;	movx    @dptr,a
;
;	mov     dptr,#0x7F94         ;; set PORTB_CONFIG regs to alt function
;	mov     a,#0xFF              ;; this allows R/W pins on port C
;	movx    @dptr,a
;
;	mov     dptr,#0x7F95         ;; set PORTC_CONFIG regs to alt function
;	mov     a,#0xFF              ;; this allows R/W pins on port C
;	movx    @dptr,a
;
;	ljmp	  0x800                ;; jump to start of compiled code

