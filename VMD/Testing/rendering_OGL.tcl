# VMD for LINUXAMD64, version 1.9.2 (December 29, 2014)
# Log file '/users/jfavre/Projects/VMD/renderings.tcl', created by user jfavre
display resize 1024 800
display projection Orthographic

mol new {/users/jfavre/Projects/VMD/ubiquitin.psf} type {psf} first 0 last -1 step 1 waitfor 1
animate style Loop
mol addfile {/users/jfavre/Projects/VMD/pulling.dcd} type {dcd} first 0 last -1 step 1 waitfor 1 0

mol addrep 0

mol modcolor 0 0 Structure
mol modstyle 0 0 NewCartoon 0.300000 10.000000 4.100000 0
mol color Structure
mol representation NewCartoon 0.300000 10.000000 4.100000 0
mol selection protein
mol material Opaque
mol modstyle 0 0 NewCartoon 0.300000 10.000000 4.100000 0
mol modcolor 0 0 Structure
mol modselect 0 0 protein
mol modmaterial 0 0 Opaque
mol color Structure
mol representation NewCartoon 0.300000 10.000000 4.100000 0
mol selection protein
mol material Opaque
mol addrep 0
mol modstyle 1 0 CPK 1.000000 0.300000 12.000000 12.000000
mol color Structure
mol representation CPK 1.000000 0.300000 12.000000 12.000000
mol selection protein
mol material Opaque
mol modstyle 1 0 CPK 1.000000 0.300000 12.000000 12.000000
mol modcolor 1 0 Structure
mol modselect 1 0 protein
mol modmaterial 1 0 Opaque

axes location Off
color Display Background white

display antialias on
display depthcue off
animate goto 0
display resetview
scale by 5

# OpenGL display
render snapshot render_0.png

exit
