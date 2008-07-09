"" calculate expression entered on command line and give answer, e.g.:
" :Calculate sin (3) + sin (4) ^ 2
command! -nargs=+ Calculate echo "<args> = " . Calculate ("<args>")

"" calculate expression from selection, pick a mapping, or use the Leader form
vnoremap ;bc "ey:call CalcLines(1)<CR>
"vnoremap <Leader>bc "ey:call<SID>CalcBC(1)<CR>

"" calculate expression on current line, pick a mapping, or use the Leader
noremap  ;bc "eyy:call CalcLines(0)<CR>
"noremap  <Leader>bc "eyy:call<SID>CalcBC(0)<CR>

" ---------------------------------------------------------------------
"  Calculate:
"    clean up an expression, pass it to bc, return answer
function! Calculate (s)

	let str = a:s

	" remove newlines and trailing spaces
	let str = substitute (str, "\n",   "", "g")
	let str = substitute (str, '\s*$', "", "g")

	" sub common func names for bc equivalent
	let str = substitute (str, '\csin\s*(',  's (', 'g')
	let str = substitute (str, '\ccos\s*(',  'c (', 'g')
	let str = substitute (str, '\catan\s*(', 'a (', 'g')
	let str = substitute (str, "\cln\s*(",   'l (', 'g')
	let str = substitute (str, '\clog\s*(',  'l (', 'g')
	let str = substitute (str, '\cexp\s*(',  'e (', 'g')

	" alternate exponitiation symbols
	let str = substitute (str, '\*\*', '^', "g")
	let str = substitute (str, '`', '^',    "g")

	" escape chars for shell
	let str = escape (str, '*();&><|')

	let preload = exists ("g:bccalc_preload") ? g:bccalc_preload : ""

	" run bc
	let answer = system ("echo " . str . " \| bc -l " . preload)

	" strip newline
	let answer = substitute (answer, "\n", "", "")

	" strip trailing 0s in decimals
	let answer = substitute (answer, '\.\(\d*[1-9]\)0\+', '.\1', "")

	return answer
endfunction

" ---------------------------------------------------------------------
" CalcLines:
"
" take expression from lines, either visually selected or the current line, as
" passed determined by arg vsl, pass to calculate function, echo or past
" answer after '='
function! CalcLines(vsl)

	let has_equal = 0

	" remove newlines and trailing spaces
	let @e = substitute (@e, "\n", "",   "g")
	let @e = substitute (@e, '\s*$', "", "g")

	" if we end with an equal, strip, and remember for output
	if @e =~ "=$"
		let @e = substitute (@e, '=$', "", "")
		let has_equal = 1
	endif

	" if there is another equal in the line, assume chained equations, remove
	" leading ones
	let @e = substitute (@e, '^.\+=', '', '')

	let answer = Calculate (@e)

	" append answer or echo
	if has_equal == 1
		if a:vsl == 1
			normal `>
		else
			normal $
		endif
		exec "normal a" . answer
	else
		echo "answer = " . answer
	endif
endfunction
