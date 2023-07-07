let s:line_start = -1
let s:line_end = -1
let s:col_start = -1
let s:col_end = -1
let s:selected_text = ""

function! rubyformatter#Format(range) abort
	if a:range == 0 && s:line_start == -1
		echom "Nothing selected"
		return
	endif

	if a:range != 0
		let s:selected_text = rubyformatter#GetSelectedText()
	endif

	let match_pattern = 0

	for group in g:rules2
		for pattern in group
			if s:selected_text =~ pattern[0]
				call rubyformatter#ApplyRules(pattern[1])
				let match_pattern = 1
				break
			endif	
		endfor
		if match_pattern == 1
			break
		endif
	endfor

	if match_pattern == 0
		echom "No matching pattern"
		return
	endif
endfunction

function! rubyformatter#GetSelectedText() abort
	let [line_start, column_start] = getpos("'<")[1:2]
	if line_start < 1
		return ""
	endif
	let s:line_start = line_start
	let s:col_start = column_start
    	let [line_end, column_end] = getpos("'>")[1:2]
	let s:line_end = line_end
	let s:col_end = column_end
    	let lines = getline(line_start, line_end)
	let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)] 
  	let lines[0] = lines[0][column_start - 1:] 
  	let selection = join(lines,'\n')
	return selection
endfunction

function! rubyformatter#ApplyRules(rules) abort
	let new_value = s:selected_text
	for [old, new] in items(a:rules)
		let new_value = substitute(new_value, old, new, 'g')		
	endfor	

	exe s:line_start.','.s:line_end.'s/'.escape(s:selected_text, '.[]').'/'.escape(new_value, '.[]').'/g'

	let new_line_count = len(split(new_value, '\r'))
	let s:line_end = s:line_start + new_line_count - 1
	let s:selected_text = substitute(new_value, '\r', '\\n', 'g')
	echom s:selected_text
endfunction

