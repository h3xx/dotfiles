" Vim syntax file
" Language:	Smarty Templates
" Maintainer:	Manfred Stienstra manfred.stienstra@dwerg.net
" Last Change:  Fri Apr 12 10:33:51 CEST 2002 
" Filenames:    *.tpl
" URL:		http://www.dwerg.net/download/vim/smarty.vim

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'smarty'
endif

syn case ignore

runtime! syntax/html.vim
"syn cluster htmlPreproc add=smartyUnZone

syn keyword smartyTagName capture config_load include include_php
syn keyword smartyTagName insert if elseif else ldelim rdelim literal
syn keyword smartyTagName php section sectionelse foreach foreachelse
syn keyword smartyTagName strip cycle config_load assign counter debug
syn keyword smartyTagName eval fetch html_checkboxes html_image
syn keyword smartyTagName html_options html_radios html_select_date
syn keyword smartyTagName html_select_time html_table mailto
syn keyword smartyTagName math popup popup_init textformat

syn keyword smartyInFunc ne eq == != > < >= <= === ! % 

syn match smartyProperty contained "file="
syn match smartyProperty contained "loop="
syn match smartyProperty contained "name="
syn match smartyProperty contained "include="
syn match smartyProperty contained "skip="
syn match smartyProperty contained "section="
syn match smartyProperty contained "from="
syn match smartyProperty contained "item="
syn match smartyProperty contained "key="
syn match smartyProperty contained "once="
syn match smartyProperty contained "global="
syn match smartyProperty contained "scope="
syn match smartyProperty contained "script="
syn match smartyProperty contained "assign="
syn match smartyProperty contained "start="
syn match smartyProperty contained "stop="
syn match smartyProperty contained "max="
syn match smartyProperty contained "show="
syn match smartyProperty contained "step="
syn match smartyProperty contained "var="
syn match smartyProperty contained "value="
syn match smartyProperty contained "skip="
syn match smartyProperty contained "direction="
syn match smartyProperty contained "print="
syn match smartyProperty contained "advance="
syn match smartyProperty contained "delimiter="
syn match smartyProperty contained "reset="
syn match smartyProperty contained "output="
syn match smartyProperty contained "selected="
syn match smartyProperty contained "options="
syn match smartyProperty contained "separator="
syn match smartyProperty contained "labels="
syn match smartyProperty contained "height="
syn match smartyProperty contained "width="
syn match smartyProperty contained "basedir="
syn match smartyProperty contained "alt="
syn match smartyProperty contained "href="
syn match smartyProperty contained "path_prefix="
syn match smartyProperty contained "values="
syn match smartyProperty contained "prefix="
syn match smartyProperty contained "time="
syn match smartyProperty contained "start_year="
syn match smartyProperty contained "end_year="
syn match smartyProperty contained "display_days="
syn match smartyProperty contained "display_months="
syn match smartyProperty contained "display_years="
syn match smartyProperty contained "month_format="
syn match smartyProperty contained "day_format="
syn match smartyProperty contained "day_value_format="
syn match smartyProperty contained "year_as_text="
syn match smartyProperty contained "reverse_years="
syn match smartyProperty contained "day_size="
syn match smartyProperty contained "month_size="
syn match smartyProperty contained "year_size="
syn match smartyProperty contained "day_extra="
syn match smartyProperty contained "month_extra="
syn match smartyProperty contained "year_extra="
syn match smartyProperty contained "field_order="
syn match smartyProperty contained "field_separator="
syn match smartyProperty contained "month_value_format="
syn match smartyProperty contained "year_empty="
syn match smartyProperty contained "month_empty="
syn match smartyProperty contained "day_empty="
syn match smartyProperty contained "display_hours="
syn match smartyProperty contained "display_minutes="
syn match smartyProperty contained "display_seconds="
syn match smartyProperty contained "minute_interval="
syn match smartyProperty contained "second_interval="
syn match smartyProperty contained "field_array="
syn match smartyProperty contained "all_extra="
syn match smartyProperty contained "hour_extra="
syn match smartyProperty contained "minute_extra="
syn match smartyProperty contained "second_extra="
syn match smartyProperty contained "meridian_extra="
syn match smartyProperty contained "display_meridian="
syn match smartyProperty contained "use_24_hours="
syn match smartyProperty contained "cols="
syn match smartyProperty contained "rows="
syn match smartyProperty contained "inner="
syn match smartyProperty contained "caption="
syn match smartyProperty contained "table_attr="
syn match smartyProperty contained "th_attr="
syn match smartyProperty contained "tr_attr="
syn match smartyProperty contained "td_attr="
syn match smartyProperty contained "trailpad="
syn match smartyProperty contained "hdir="
syn match smartyProperty contained "vdir="
syn match smartyProperty contained "address="
syn match smartyProperty contained "text="
syn match smartyProperty contained "encode="
syn match smartyProperty contained "cc="
syn match smartyProperty contained "bcc="
syn match smartyProperty contained "subject="
syn match smartyProperty contained "newsgroups="
syn match smartyProperty contained "followupto="
syn match smartyProperty contained "extra="
syn match smartyProperty contained "equation="
syn match smartyProperty contained "format="
syn match smartyProperty contained "trigger="
syn match smartyProperty contained "sticky="
syn match smartyProperty contained "caption="
syn match smartyProperty contained "fgcolor="
syn match smartyProperty contained "bgcolor="
syn match smartyProperty contained "textcolor="
syn match smartyProperty contained "capcolor="
syn match smartyProperty contained "closecolor="
syn match smartyProperty contained "textfont="
syn match smartyProperty contained "captionfont="
syn match smartyProperty contained "closefont="
syn match smartyProperty contained "textsize="
syn match smartyProperty contained "captionsize="
syn match smartyProperty contained "closesize="
syn match smartyProperty contained "width="
syn match smartyProperty contained "height="
syn match smartyProperty contained "left="
syn match smartyProperty contained "right="
syn match smartyProperty contained "center="
syn match smartyProperty contained "above="
syn match smartyProperty contained "below="
syn match smartyProperty contained "border="
syn match smartyProperty contained "offsetx="
syn match smartyProperty contained "offsety="
syn match smartyProperty contained "fgbackground="
syn match smartyProperty contained "bgbackground="
syn match smartyProperty contained "closetext="
syn match smartyProperty contained "noclose="
syn match smartyProperty contained "status="
syn match smartyProperty contained "autostatus="
syn match smartyProperty contained "autostatuscap="
syn match smartyProperty contained "inarray="
syn match smartyProperty contained "caparray="
syn match smartyProperty contained "capicon="
syn match smartyProperty contained "snapx="
syn match smartyProperty contained "snapy="
syn match smartyProperty contained "fixx="
syn match smartyProperty contained "fixy="
syn match smartyProperty contained "background="
syn match smartyProperty contained "padx="
syn match smartyProperty contained "pady="
syn match smartyProperty contained "fullhtml="
syn match smartyProperty contained "frame="
syn match smartyProperty contained "function="
syn match smartyProperty contained "delay="
syn match smartyProperty contained "hauto="
syn match smartyProperty contained "indent="
syn match smartyProperty contained "indent_first="
syn match smartyProperty contained "indent_char="
syn match smartyProperty contained "wrap="
syn match smartyProperty contained "wrap_char="
syn match smartyProperty contained "vauto="
syn match smartyProperty contained "wrap_cut="




syn match smartyConstant "\$smarty" 

syn match smartyDollarSign      contained "\$"
syn match smartyMaybeDollarSign contained "\([^\\]\|\\\\\)\@<=\$"

syn match smartyVariable      contained "\$\@<=\h\w*"
syn match smartyVariable      contained "\(\$\h\w*\(\.\|\->\|\[.*\]\(\.\|\->\)\)\)\@<=\w*"
syn match smartyMaybeVariable contained "\(\(^\|[^\\]\|\\\\\)\$\)\@<=\h\w*"


syn match smartyEscapedVariable contained "\\$\h\w*"

syn region smartyInBracket    matchgroup=Constant start=+\[+ end=+\]+ contains=smartyVariable contained
syn region smartyInBacktick   matchgroup=Constant start=+\`+ end=+\`+ contains=smartyVariable contained
syn region smartyStringDouble matchgroup=Constant start=+"+  end=+"+  contains=smartyMaybeVariable, smartyInBacktick, smartyMaybeDollarSign contained keepend

syn match smartyGlue "\.\|\->"


syn region smartyModifier  matchgroup=Statement start=+|+   end=+\ze:\|\>+
syn region smartyParameter matchgroup=Statement start=+:+   end=+\s\|}+ contains=smartyVariable, smartyDollarSign, smartyGlue, smartyInBracket, smartyStringDouble
syn region smartyZone     matchgroup=Statement   start="{"   end="}" contains=smartyParameter, smartyProperty, smartyGlue, smartyModifier, smartyDollarSign, smartyInBracket, smartyStringDouble, smartyVariable, smartyString, smartyBlock, smartyTagName, smartyConstant, smartyInFunc
syn region smartyComment  matchgroup=Comment   start="{\*" end="\*}"

syn region  htmlString   contained start=+"+ end=+"+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,smartyZone
syn region  htmlString   contained start=+'+ end=+'+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,smartyZone
  syn region htmlLink start="<a\>\_[^>]*\<href\>" end="</a>"me=e-4 contains=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,javaScript,@htmlPreproc,smartyZone


if version >= 508 || !exists("did_smarty_syn_inits")
  if version < 508
    let did_smarty_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink smartyTagName         Function
  HiLink smartyProperty        Type
  HiLink smartyComment         Comment
  HiLink smartyInFunc          Function
  HiLink smartyBlock           Constant
  HiLink smartyGlue            Statement
  HiLink smartyVariable        Identifier
  HiLink smartyDollarSign      Statement
  HiLink smartyMaybeVariable   Identifier
  HiLink smartyMaybeDollarSign Statement
  HiLink smartyStringDouble    Special
  HiLink smartyInBracket       PreProc
  HiLink smartyInBacktick      Statement
  HiLink smartyModifier        Special
  delcommand HiLink
endif 

let b:current_syntax = "smarty"

if main_syntax == 'smarty'
  unlet main_syntax
endif

" vim: ts=8
