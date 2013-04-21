OUTPUTDIR="$(CURDIR)/bin"
MFILE=MATrax.m
INCLUDE="$(CURDIR)/util"
LIB="$(CURDIR)/lib"

all: matrax

matrax:
	-mkdir -p $(OUTPUTDIR)
	mcc -v -I $(LIB) -I $(INCLUDE) -d $(OUTPUTDIR) -m $(MFILE)

clean:
	-rm -fv $(OUTPUTDIR)/*.sh
	-rm -fv $(OUTPUTDIR)/*.txt
	-rm -fv $(OUTPUTDIR)/*.log
	-rm -rfv $(OUTPUTDIR)/*.app
