
"" Markdown用
call lexima#add_rule({'at': '- \%#', 'char': '[', 'input': '[ ]<Space>', 'filetype': 'markdown'})
call lexima#add_rule({'at': '- \%#', 'char': ']', 'input': '[x]<Space>', 'filetype': 'markdown'})

"" TABで綴じカッコの後ろに
call lexima#add_rule({'at': '\%#)',  'char': '<TAB>', 'leave': 1})
call lexima#add_rule({'at': '\%#"',  'char': '<TAB>', 'leave': 1})
call lexima#add_rule({'at': '\%#''', 'char': '<TAB>', 'leave': 1})
call lexima#add_rule({'at': '\%#]',  'char': '<TAB>', 'leave': 1})
call lexima#add_rule({'at': '\%#}',  'char': '<TAB>', 'leave': 1})

"" 文末以外は無効
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '{', 'input': '{'})
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '[', 'input': '['})
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '(', 'input': '('})
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '''', 'input': ''''})
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '"', 'input': '"'})
call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '`', 'input': '`'})
