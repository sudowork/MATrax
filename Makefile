OUTPUTDIR="$(CURDIR)/bin"
MFILE=MATrax.m

all: matrax

matrax:
	-mkdir -p $(OUTPUTDIR)
	mcc -v -d $(OUTPUTDIR) -m $(MFILE)

clean:
	-rm -fv $(OUTPUTDIR)/*.sh
	-rm -fv $(OUTPUTDIR)/*.txt
	-rm -fv $(OUTPUTDIR)/*.log
	-rm -rfv $(OUTPUTDIR)/*.app
