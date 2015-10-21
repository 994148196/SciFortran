FC=gfortran
FFLAGS=-O2 -funroll-all-loops -static
PLAT=gnu
OBJ_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/SRC/obj_gnu
BLAS_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/BLAS/blas_gnu
LAPACK_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/LAPACK/lapack_gnu
UTIL_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/UTIL/util_gnu
PUTIL_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/PARPACK/UTIL/MPI/util_gnu
POBJ_INSTALL=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install/PARPACK/SRC/MPI/obj_gnu

home=/home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/_install/opt/parpack/_install
COMMLIB     = MPI

BLASdir      = $(home)/BLAS
LAPACKdir    = $(home)/LAPACK
UTILdir      = $(home)/UTIL
SRCdir       = $(home)/SRC
PSRCdir      = $(home)/PARPACK/SRC/$(COMMLIB)
PUTILdir     = $(home)/PARPACK/UTIL/$(COMMLIB)
DIRS   = $(BLASdir) $(LAPACKdir) $(UTILdir) $(SRCdir)


#  The name of the libraries to be created/linked to
ARPACKLIB  = /home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/gnu/lib/libarpack.a
PARPACKLIB = /home/amaricci/projects_src/officina/SCIFOR_beta/scifor_wlib/gnu/lib/libparpack.a
LAPACKLIB = 
BLASLIB = 
ALIBS =  $(ARPACKLIB) $(LAPACKLIB) $(BLASLIB) 


# Libraries needed for Parallel ARPACK - MPI for SUN4
MPILIBS = #-L/opt/mpich2-1.4.1/intel/lib 
PLIBS = $(PARPACKLIB) $(ALIBS) $(MPILIBS)


#  Make our own suffixes list.
#.SUFFIXES:
#.SUFFIXES:.f .o

#
#  Default command.
#
.DEFAULT:
	@$(ECHO) "Unknown target $@, try:  make help"

#
#  Command to build .o files from .f files.
#
.f.o:
	@$(ECHO) Making $@ from $<
	@$(FC) -c $(FFLAGS) $<

#
#  Various compilation programs and flags.
#  You need to make sure these are correct for your system.
LDFLAGS = 
CD	= cd
AR      = ar 
ARFLAGS  = cvq
CHMOD	= chmod
CHFLAGS	= -f
COMPRESS= compress

CP	= cp
CPP	 = /lib/cpp
CPPFLAGS =
ECHO	 = echo
LN	 = ln
LNFLAGS	 = -s
#MAKE	 = /bin/make
MKDIR	 = mkdir
MDFLAGS	 = -p
MV	 = mv
MVFLAGS	 = -f
RM	 = rm
RMFLAGS  = -f
SHELL	 = /bin/sh
TAR	 = tar
RANLIB   = ranlib


help:
	@$(ECHO) "usage: make ?"
