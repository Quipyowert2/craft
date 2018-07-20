#======================================================================#
#= CHANGES AND UPDATES                                                =#
#======================================================================#
#= date   person file       subject                                   =#
#=--------------------------------------------------------------------=#
#=                                                                    =#
#= 204093 hua    Makefile   created                                   =#
#=             							      =#
#======================================================================#


.KEEP_STATE:

.SUFFIXES: .a .batch .hc .x .inc .lib .o .pre .shell .h


#
#	include directories:
#

GCC_EXEC=/vol/src/ArchiveTape/gnu/gcc-2.5.8/bin/gcc

CPPFLAGS= \
	-I/home/janus/includes  \
	-I/vol/X11R5/include \
	-I/vol/src/ArchiveTape/gnu/gcc-2.5.8/include 
#
#	optimization flags:
#

CFLAGS_OPTIM = \
	-O2 \
	-fexpensive-optimizations \
	-finline-functions

CFLAGS_G = \
	-g

CFLAGS_P = \
	-pg

#
#	link directories:
#

LDFLAGS = \
	-L/vol/src/ArchiveTape/gnu/gcc-2.5.8/lib 

#
#	default libraries:
#

LDLIBS0	= \
	-ltermcap \
	-lg++2 \
	-lm


#
#	default choices (optimized janus) :
#

CFLAGS	= $(CFLAGS_OPTIM)
LDLIBS	= $(LDLIBS0)

.hc.o:  
	@rm -f $*.wrn
	/home/janus/bin/refine  -CODE $(GCC_EXEC) $(CFLAGS) -pipe $(CPPFLAGS) -c $*
	@rm -f $*.err

hcc:	   	hcc.hc hcc.o
		$(GCC_EXEC) $(CFLAGS) $(LDFLAGS) -o hcc  \
		$(BINDING) hcc.o 

all:	        $(SRCS)
		hcc

.DONE: 
	sound /home/hua/sound/clink

.FAILED:  
	sound /home/hua/sound/splat

  
  

