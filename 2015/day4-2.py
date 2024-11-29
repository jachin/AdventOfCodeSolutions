import hashlib

input = "ckczppom"

i = 0

while True:
    i += 1
    s = "{0}{1}".format(input, i)
    m = hashlib.md5(s)
    answer = m.hexdigest()
    
    if answer[0:6] == "000000":
        print answer
        print i
        break
    