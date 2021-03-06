;+ 
; NAME: 
; RAD_GRD_READ
;
; PURPOSE: 
; This procedure reads gridded radar data into the variables of the structure RAD_GRD_DATA in
; the common block RAD_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_GRD_READ, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; NORTH: Set this keyword to read grid data for the northern hemisphere only.
; This is the default.
;
; SOUTH: Set this keyword to read grid data for the southern hemisphere only.
;
; HEMISPHERE: Set this keyword to 0 to read grid data for the northern hemisphere only,
; set it to 1 to read grid data for the southern hemisphere only.
;
; BOTH: Set this keyword to read grid data for the northern and southern hemisphere.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; RAD_DATA_BLK, i.e. even if RAD_GRD_CHECK_LOADED returns true.
;
; FILENAME: Set this to a string containing the name of the grd file to read.
;
; FILEGRDEX: Set this keyword to indicate that the file in FILENAME is in the grdEX
; file format.
;
; FILEAPLGRD: Set this keyword to indicate that the file in FILENAME is in the APLGRD
; file format.
;
; FILEDATE: Set this to a date in YYYMMDD format to indicate that the file in FILENAME
; contains data from that date.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; RADARINFO: The common block holding data about all radar sites (from RST).
;
; EXAMPLE:
;
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's ARCHIVE_MP.
; Written by Lasse Clausen, Dec, 10 2009
;-
pro rad_grd_read, date, time=time, north=north, south=south, hemisphere=hemisphere, both=both, $
	long=long, silent=silent, filename=filename, filedate=filedate, force=force, $
	filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd

; if the user wants to load both hemispheres
; just call RAD_MAP_READ with /NORTH, then /SOUTH and return
if keyword_set(both) then begin
	rad_grd_read, date, time=time,/north, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd, force=force
	rad_grd_read, date, time=time,/south, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd, force=force
	return
endif

common rad_data_blk
common radarinfo

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
rad_grd_info[int_hemi].nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	if ~keyword_set(filename) then begin
		prinfo, 'Must give date.'
		return
	endif
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; calculate the maximum records the data array will hold
MAX_RECS = GETENV('RAD_MAX_HOURS')*125L

; wether the file is in the old ascii format
oldgrd = !false

if ~keyword_set(filename) then begin
	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_grd_check_loaded(date, hemisphere, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = rad_grd_find_files(date, hemisphere=hemisphere, time=time, $
		long=long, file_count=fc, aplgrd=aplgrd, vtgrd=vtgrd, grdex=grdex)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 0, 8))
		endelse
	endfor
	if keyword_set(filegrdex) then begin
		grdex = !true
		aplgrd = !false
		vtgrd = !false
	endif else if keyword_set(fileaplgrd) then begin
		grdex = !false
		aplgrd = !true
		vtgrd = !false
	endif else if keyword_set(filevtgrd) then begin
		grdex = !false
		aplgrd = !false
		vtgrd = !true
	endif else begin
		prinfo, 'I have no idea in which format the file is, grdEX or APLgrd. Guessing grdEX.', /force
		grdex = !true
		aplgrd = !false
		vtgrd = !false
	endelse
	files = filename
	no_delete = !false
endelse

; make arrays holding data
sjuls = make_array(MAX_RECS, /double)
mjuls = make_array(MAX_RECS, /double)
fjuls = make_array(MAX_RECS, /double)
sysec = make_array(MAX_RECS, /long)
mysec = make_array(MAX_RECS, /long)
fysec = make_array(MAX_RECS, /long)
stnum = make_array(MAX_RECS, /int)
vcnum = make_array(MAX_RECS, /int)
gvecs = make_array(MAX_RECS, /ptr)
nrecs = 0L

; set up variables needed for reading grid
GridMakePrm, prm
oldgrd = vtgrd

;lib=getenv('LIB_GRDIDL')
;if strcmp(lib, '') then begin
;		prinfo, 'Cannot find LIB_GRDIDL'
;	return
;endif

for i=0, fc-1 do begin
	file_base = file_basename(files[i])
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+file_base
	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	; open grid file
	if oldgrd then $
		ilun = OldGridOpen(o_file, /read) $
	else $
		ilun = GridOpen(o_file, /read)
	if ilun eq 0 then begin
		prinfo, 'Could not open file: ' + files[i] + $
			'->('+o_file+')', /force
		if files[i] ne o_file then $
			file_delete, o_file
		continue
	endif
	; read all data entries
	while !true do begin

		; read data record
		if oldgrd then begin
			ret = oldgridread(ilun, prm, stvec, gvec)
		endif else begin
;			ret = rad_grd_read_record(ilun, lib, prm, stvec, gvec)
			ret = gridread(ilun, prm, stvec, gvec)
		endelse

		; exit if all read
		if ret eq -1 then $
			break

		sjuls[nrecs] = julday(prm.stme.mo,prm.stme.dy,prm.stme.yr,prm.stme.hr,prm.stme.mt,prm.stme.sc)
		fjuls[nrecs] = julday(prm.etme.mo,prm.etme.dy,prm.etme.yr,prm.etme.hr,prm.etme.mt,prm.etme.sc)
		mjuls[nrecs] = (sjuls[nrecs] + fjuls[nrecs])/2.d
		stnum[nrecs] = prm.stnum
		vcnum[nrecs] = prm.vcnum
		gvecs[nrecs] = ptr_new(gvec)
		nrecs += 1L
		if nrecs ge MAX_RECS then begin
			prinfo, 'Too many maps in file: '+string(nrecs)
			break
		endif
	endwhile
  free_lun, ilun
	if files[i] ne o_file then $
		file_delete, o_file
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	if aplgrd then begin
		prinfo, 'GRD file is in ASCII format. Cannot read. Must convert to binary grdmap file using the RST command gridtogrdmap.', /force
	endif
	return
endif

; set up temporary structure
rad_grd_data_hemi = { $
	sjuls: dblarr(nrecs), $
	mjuls: dblarr(nrecs), $
	fjuls: dblarr(nrecs), $
	stnum: intarr(nrecs), $
	vcnum: intarr(nrecs), $
	gvecs: ptrarr(nrecs) $
}

; populate structure
rad_grd_data_hemi.sjuls = sjuls[0:nrecs-1L]
rad_grd_data_hemi.mjuls = mjuls[0:nrecs-1L]
rad_grd_data_hemi.fjuls = fjuls[0:nrecs-1L]
rad_grd_data_hemi.stnum = stnum[0:nrecs-1L]
rad_grd_data_hemi.vcnum = vcnum[0:nrecs-1L]
rad_grd_data_hemi.gvecs = gvecs[0:nrecs-1L]

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(rad_grd_data[int_hemi]) then begin
	for i=0L, n_elements((*rad_grd_data[int_hemi]).gvecs)-1L do begin
		if ptr_valid((*rad_grd_data[int_hemi]).gvecs[i]) then $
			ptr_free, (*rad_grd_data[int_hemi]).gvecs[i]
	endfor
	ptr_free, rad_grd_data[int_hemi]
endif
rad_grd_data[int_hemi] = ptr_new(rad_grd_data_hemi)

rad_grd_info[int_hemi].sjul = (*rad_grd_data[int_hemi]).mjuls[0L]
rad_grd_info[int_hemi].fjul = (*rad_grd_data[int_hemi]).mjuls[nrecs-1L]
rad_grd_info[int_hemi].grd = (aplgrd or vtgrd)
rad_grd_info[int_hemi].grdex = grdex
rad_grd_info[int_hemi].nrecs = nrecs

END
