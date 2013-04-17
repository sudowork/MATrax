OUTPUTDIR="$(CURDIR)/bin"
MFILE=MATrax.m
INCLUDE="$(CURDIR)/util"

all: matrax

matrax:
	-mkdir -p $(OUTPUTDIR)
	mcc -v -I $(INCLUDE) -d $(OUTPUTDIR) -m $(MFILE)

clean:
	-rm -fv $(OUTPUTDIR)/*.sh
	-rm -fv $(OUTPUTDIR)/*.txt
	-rm -fv $(OUTPUTDIR)/*.log
	-rm -rfv $(OUTPUTDIR)/*.app
