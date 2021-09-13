import sys
import re

# check arguments
if len(sys.argv) != 6:
    print("Wrong arguments\nmmi_gen in out bus-width mem-size part")
    exit()

fin = sys.argv[1]
fout = sys.argv[2]
bwidth= int(sys.argv[3])
msize = int(sys.argv[4])
dpart = sys.argv[5]
# read the ramb search result
f = open(fin, "r")
lines = f.readlines()
f.close()

rams = []
n=0
for i, line in enumerate(lines):
    ram_match = re.match(r"composed_soc/memory_reg_(\d+)", line)
    if ram_match:
        loc_match = re.match(r"LOC[\w\s]+RAMB(\d+)_X(\d+)Y(\d+)", lines[i+2])
        if loc_match:
            rams.append((n, loc_match.group(2), loc_match.group(3)))
            n = n + 1

# get the bit-width of each
if bwidth % len(rams) != 0:
    print("Cannot divide memory bus evenly into BRAMs!")
    exit()

DW = bwidth / len(rams)
MS = "%#010x"%(msize - 1)
BS = (msize*8)/bwidth
rams = sorted(rams, key=lambda r: r[0], reverse=True)

f = open(fout, "w")
f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
f.write('<MemInfo Version="1" Minor="0">\n')
f.write('\t<Processor Endianness="Little" InstPath="dummy">\n')
f.write('\t\t<AddressSpace Name="composed_soc/memory" Begin="0" End="{0}">\n'.format(msize-1))
f.write('\t\t\t<BusBlock>\n')
#f.write('ADDRESS_SPACE BOOTRAM RAMB32 [0x00000000:{0}]\n'.format(MS))
#f.write("  BUS_BLOCK\n")
for r in rams:
    #f.write('    ram_reg_{0} [{1}:{2}] LOC = X{3}Y{4};\n'.format(r[0], r[0]*DW+DW-1, r[0]*DW, r[1], r[2]))
    f.write('\t\t\t\t<BitLane MemType="RAMB32" Placement="X{0}Y{1}">\n'.format(r[1], r[2]))
    f.write('\t\t\t\t\t<DataWidth MSB="{0}" LSB="{1}"/>\n'.format(int(r[0]*DW+DW-1), int(r[0]*DW)))
    f.write('\t\t\t\t\t<AddressRange Begin="0" End="{0}"/>\n'.format(int(BS-1)))
    f.write('\t\t\t\t\t<Parity ON="false" NumBits="0"/>\n')
    f.write('\t\t\t\t</BitLane>\n')
f.write('\t\t\t</BusBlock>\n')
f.write('\t\t</AddressSpace>\n')
f.write('\t</Processor>\n')
f.write('<Config>\n')
f.write('\t<Option Name="Part" Val="{0}"/>\n'.format(dpart))
f.write('</Config>\n')
f.write('</MemInfo>\n')
#f.write("  END_BUS_BLOCK;\n")
#f.write("END_ADDRESS_SPACE;\n")

f.close()
