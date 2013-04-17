OUTPUTDIR="$(CURDIR)/bin"
MFILE=MATrax.m

all: matrax
matrax:
	mcc -v -d $(OUTPUTDIR) -m $(MFILE)
clean:
	-rm -fv $(OUTPUTDIR)/*.sh
	-rm -fv $(OUTPUTDIR)/*.txt
	-rm -fv $(OUTPUTDIR)/*.log
	-rm -fv $(OUTPUTDIR)/*.exe
	-rm -rfv $(OUTPUTDIR)/*.app
