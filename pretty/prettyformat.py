def pretty(command = "??", module="Unknown", description="Somebody please fix this!!", bCustom=True):
    if bCustom:
        pretty_command = "*[%s]" % (command[:6])
    else:
        pretty_command = " [%s]" % (command[:6])

    pretty_module =  "[%s]" % (module[:15])
    if("/" in module):
        mods = module.split("/")
        tail = mods[len(mods)-1]
        mod = tail
        pretty_module = "[%s]" % mod[:10]

    print(" %-9s %-17s %s" % (pretty_command, pretty_module, description));


def readline(finput):
    line = ""
    c = finput.read(1)
    print(c)
