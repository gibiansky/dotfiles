c = get_config()  # noqa

c.TerminalIPythonApp.display_banner = False
c.InteractiveShellApp.log_level = 30
c.InteractiveShellApp.extensions = []
c.InteractiveShellApp.exec_lines = [
    'import numpy',
    'import scipy',
    'from math import *',
    'from __future__ import division',
]
c.InteractiveShellApp.exec_files = []
c.InteractiveShell.autoindent = True
c.InteractiveShell.colors = 'LightBG'
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True
c.InteractiveShell.editor = 'vim'
c.InteractiveShell.xmode = 'Context'

c.PromptManager.in_template = 'In [\#]: '
c.PromptManager.in2_template = '   .\D.: '
c.PromptManager.out_template = 'Out[\#]: '
c.PromptManager.justify = True

c.PrefilterManager.multi_line_specials = True

c.AliasManager.user_aliases = [
    ('la', 'ls -al'),
    ('l', 'ls'),
    ('ll', 'ls -a'),
]
