import re
import sys

regex = re.compile('^(\S+) (\S+) (\S+) \[([\w:/]+\s[+\-]\d{4})\] \"(\S+) (\S+)\s*(\S+)?\s*\" (\d{3}) (\S+) \"(\S+)\" \"(\S+) \((.+)\) (.+)')

for line in sys.stdin:
    try:
        line = line.strip()
        res = regex.match(line)
        print('\t'.join(list(res.groups())))
    except:
        print('bad line')