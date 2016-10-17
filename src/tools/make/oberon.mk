# DO NOT RUN THIS MAKEFILE DIRECTLY.
#
# Always use the makefile in the root of the enlistment. This makefile
# depends on up to date configuration files generated by the root makefile.




# Be independent of any CFLAGS settings in the calling environment
CFLAGS =

# Gnu make has the make initial directory in CURDIR, BSD make has it in .CURDIR.
ROOTDIR = $(CURDIR)$(.CURDIR)

# Configuration.Make is created by src/tools/make/configure.c, which is run on
# *every* build by the makefile in the enlistment root.
include ./Configuration.Make

FLAVOUR  = $(OS).$(DATAMODEL).$(COMPILER)
BUILDDIR = build/$(FLAVOUR)
OBECOMP  = $(ONAME)$(BINEXT)



# Default make target - explain usage
usage:
	@echo ""
	@echo Do not run this makefile directly, always run the makefile in
	@echo the root of the enlistment.




clean:
	@printf "\n\n--- Cleaning branch $(BRANCH) $(OS) $(COMPILER) $(DATAMODEL) ---\n\n"
	rm -rf $(BUILDDIR)
	rm -f $(OBECOMP)




# Assemble: Generate the Vishap Oberon compiler binary by compiling the C sources in the build directory

assemble:
	@printf "\nmake assemble - compiling Oberon compiler c source:\n"
	@printf "  VERSION: %s\n" "$(VERSION)"
	@printf "  BRANCH:  %s\n" "$(BRANCH)"
	@printf "  Target characteristics:\n"
	@printf "    PLATFORM:   %s\n" "$(PLATFORM)"
	@printf "    OS:         %s\n" "$(OS)"
	@printf "    BUILDDIR:   %s\n" "$(BUILDDIR)"
	@printf "    INSTALLDIR: %s\n" "$(INSTALLDIR)"
	@printf "  Oberon characteristics:\n"
	@printf "    MODEL:      %s\n" "$(MODEL)"
	@printf "    ADRSIZE:    %s\n" "$(ADRSIZE)"
	@printf "    ALIGNMENT:  %s\n" "$(ALIGNMENT)"
	@printf "  C compiler:\n"
	@printf "    COMPILER:   %s\n" "$(COMPILER)"
	@printf "    COMPILE:    %s\n" "$(COMPILE)"
	@printf "    DATAMODEL:  %s\n" "$(DATAMODEL)"

	cd $(BUILDDIR) && $(COMPILE) -c SYSTEM.c  Configuration.c Platform.c Heap.c
	cd $(BUILDDIR) && $(COMPILE) -c Out.c     Strings.c       Modules.c  Files.c
	cd $(BUILDDIR) && $(COMPILE) -c Reals.c   Texts.c         VT100.c    errors.c
	cd $(BUILDDIR) && $(COMPILE) -c OPM.c     extTools.c      OPS.c      OPT.c
	cd $(BUILDDIR) && $(COMPILE) -c OPC.c     OPV.c           OPB.c      OPP.c

	cd $(BUILDDIR) && $(COMPILE) $(STATICLINK) Compiler.c -o $(ROOTDIR)/$(OBECOMP) \
	SYSTEM.o  Configuration.o Platform.o Heap.o    Out.o     Strings.o       Modules.o  Files.o \
	Reals.o   Texts.o         VT100.o    errors.o  OPM.o     extTools.o      OPS.o      OPT.o \
	OPC.o     OPV.o           OPB.o      OPP.o

	cp src/runtime/*.[ch] $(BUILDDIR)
	@printf "$(OBECOMP) created.\n"




compilerfromsavedsource:
	@echo Populating clean build directory from bootstrap C sources $(PLATFORM)-$(ADRSIZE)$(ALIGNMENT).
	@mkdir -p $(BUILDDIR)
	@cp bootstrap/$(PLATFORM)-$(ADRSIZE)$(ALIGNMENT)/* $(BUILDDIR)
	@cp bootstrap/*.[ch] $(BUILDDIR)
	@make -f src/tools/make/oberon.mk -s assemble
	@cp bootstrap/*.[ch] $(BUILDDIR)




translate:
# Make sure we have an oberon compiler binary: if we built one earlier we'll use it,
# otherwise use one of the pre-prepared sets of C sources in the bootstrap directory.

	if [ ! -e $(OBECOMP) ]; then make -f src/tools/make/oberon.mk -s compilerfromsavedsource; fi

	@printf "\nmake translate - translating compiler source from Oberon to C:\n"
	@printf "  PLATFORM:  %s\n" $(PLATFORM)
	@printf "  MODEL:     %s\n" $(MODEL)
	@printf "  ADRSIZE:   %s\n" $(ADRSIZE)
	@printf "  ALIGNMENT: %s\n" $(ALIGNMENT)
	@mkdir -p $(BUILDDIR)
	@rm -f $(BUILDDIR)/*.sym

	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../Configuration.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Platform$(PLATFORM).Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfFapx -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Heap.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Strings.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Out.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Modules.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfFx   -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Files.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Reals.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/Texts.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/runtime/VT100.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/errors.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPM.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/extTools.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfFx   -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPS.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPT.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPC.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPV.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPB.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -SsfF    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/OPP.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -Ssfm    -A$(ADRSIZE)$(ALIGNMENT) -O$(MODEL) ../../src/compiler/Compiler.Mod

	@printf "$(BUILDDIR) filled with compiler C source.\n"




browsercmd:
	@printf "\nMaking symbol browser\n"
	@cd $(BUILDDIR); $(ROOTDIR)/$(OBECOMP) -fSm -O$(MODEL) ../../src/tools/browser/BrowserCmd.Mod
	@cd $(BUILDDIR); $(COMPILE) BrowserCmd.c -o showdef \
	  Platform.o Texts.o OPT.o Heap.o Out.o SYSTEM.o OPM.o OPS.o OPV.o \
	  Files.o Reals.o Modules.o VT100.o errors.o Configuration.o Strings.o \
	  OPC.o




FORCE:

# installable: Check for access to the installation directory

installable:
	@rm -rf "S(INSTALLDIR)/test-access-qqq"
	@if ! mkdir -p "$(INSTALLDIR)/test-access-qqq";then echo "\\n\\n   Cannot write to install directory.\\n   Please use sudo or run as root/administrator.\\n\\n"; exit 1;fi
	@rm -rf "S(INSTALLDIR)/test-access-qqq"




# install: Use only after a successful full build. Installs the compiler
#          and libraries in /opt/$(ONAME).
#          May require root access.
install:
	@printf "\nInstalling into \"$(INSTALLDIR)\"\n"
	@rm -rf "$(INSTALLDIR)"

	@mkdir -p "$(INSTALLDIR)/bin"
	@cp $(OBECOMP) "$(INSTALLDIR)/bin/$(OBECOMP)"
	@-cp $(BUILDDIR)/showdef$(BINEXT) "$(INSTALLDIR)/bin"

	@mkdir -p "$(INSTALLDIR)/2/include" && cp $(BUILDDIR)/2/*.h   "$(INSTALLDIR)/2/include/"
	@mkdir -p "$(INSTALLDIR)/2/sym"     && cp $(BUILDDIR)/2/*.sym "$(INSTALLDIR)/2/sym/"
	@mkdir -p "$(INSTALLDIR)/C/include" && cp $(BUILDDIR)/C/*.h   "$(INSTALLDIR)/C/include/"
	@mkdir -p "$(INSTALLDIR)/C/sym"     && cp $(BUILDDIR)/C/*.sym "$(INSTALLDIR)/C/sym/"

	@mkdir -p "$(INSTALLDIR)/lib"
	@cp $(BUILDDIR)/2/lib$(ONAME)* "$(INSTALLDIR)/lib/"
	@cp $(BUILDDIR)/C/lib$(ONAME)* "$(INSTALLDIR)/lib/"
	@if which ldconfig >/dev/null 2>&1; then $(LDCONFIG); fi




# showpath: Describe how to set the PATH variable
showpath:
	@printf "\nNow add $(INSTALLDIR)/bin to your path, for example with the command:\n"
	@printf "export PATH=\"$(INSTALLDIR)/bin:\$$PATH\"\n"
	@printf "\n"




uninstall:
	@printf "\nUninstalling from \"$(INSTALLDIR)\"\n"
	rm -rf "$(INSTALLDIR)"
	rm -f /etc/ld.so.conf/lib$(ONAME)
	if which ldconfig >/dev/null 2>&1; then ldconfig; fi


runtime:
	@printf "\nMaking run time library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Platform$(PLATFORM).Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Heap.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Modules.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Strings.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Out.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/VT100.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Files.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Math.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/MathL.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Reals.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Texts.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/runtime/Oberon.Mod


v4:
	@printf "\nMaking v4 library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/v4/Args.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/v4/Console.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/v4/Printer.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/v4/Sets.Mod

ooc2:
	@printf "\nMaking ooc2 library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2Strings.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2Ascii.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2CharClass.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2ConvTypes.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2IntConv.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2IntStr.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc2/ooc2Real0.Mod

ooc:
	@printf "\nMaking ooc library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLowReal.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLowLReal.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocRealMath.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocOakMath.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLRealMath.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLongInts.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocComplexMath.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLComplexMath.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocAscii.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocCharClass.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocStrings.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocConvTypes.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLRealConv.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocLRealStr.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocRealConv.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocRealStr.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocIntConv.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocIntStr.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocMsg.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocSysClock.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocTime.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocChannel.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocStrings2.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocRts.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocTextRider.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocBinaryRider.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocJulianDay.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocwrapperlibc.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ooc/oocC$(DATAMODEL).Mod

oocX11:
	@printf "\nMaking oocX11 library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/oocX11/oocX11.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/oocX11/oocXutil.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/oocX11/oocXYplane.Mod

ulm:
	@printf "\nMaking ulm library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmObjects.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmPriorities.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmDisciplines.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmServices.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSys.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSYSTEM.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmEvents.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmProcess.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmResources.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmForwarders.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmRelatedEvents.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTypes.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmStreams.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmStrings.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSysTypes.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTexts.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSysConversions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmErrors.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSysErrors.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSysStat.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmASCII.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSets.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmIO.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmAssertions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmIndirectDisciplines.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmStreamDisciplines.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmIEEE.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmMC68881.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmReals.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmPrint.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmWrite.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmConstStrings.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmPlotters.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmSysIO.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmLoader.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmNetIO.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmPersistentObjects.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmPersistentDisciplines.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmOperations.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmScales.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTimes.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmClocks.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTimers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmConditions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmStreamConditions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTimeConditions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmCiphers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmCipherOps.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmBlockCiphers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmAsymmetricCiphers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmConclusions.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmRandomGenerators.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmTCrypt.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/ulm/ulmIntOperations.Mod

pow32:
	@printf "\nMaking pow library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/pow/powStrings.Mod

misc:
	@printf "\nMaking misc library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/misc/crt.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/misc/Listen.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/misc/MersenneTwister.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/misc/MultiArrays.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/misc/MultiArrayRiders.Mod

s3:
	@printf "\nMaking s3 library for -O$(MODEL)\n"
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethBTrees.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethMD5.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethSets.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlib.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlibBuffers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlibInflate.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlibDeflate.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlibReaders.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZlibWriters.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethZip.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethRandomNumbers.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethGZReaders.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethGZWriters.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethUnicode.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethDates.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethReals.Mod
	cd $(BUILDDIR)/$(MODEL); $(ROOTDIR)/$(OBECOMP) -Ffs -O$(MODEL) ../../../src/library/s3/ethStrings.Mod




O2library: runtime v4 ooc2 ooc ulm pow32 misc s3

OClibrary: runtime

library:
	@printf "\nCompiling lib$(ONAME)-O$(MODEL) sources\n"
	rm -rf $(BUILDDIR)/$(MODEL)
	mkdir -p $(BUILDDIR)/$(MODEL)
	cp src/runtime/*.[ch] $(BUILDDIR)/$(MODEL)
	cd $(BUILDDIR)/$(MODEL) && $(COMPILE) -c SYSTEM.c
	@make -f src/tools/make/oberon.mk -s O$(MODEL)library MODEL=$(MODEL)
	@printf "\nMaking lib$(ONAME)-O$(MODEL) .a and .so\n"
	ar rcs "$(BUILDDIR)/$(MODEL)/lib$(ONAME)-O$(MODEL).a" $(BUILDDIR)/$(MODEL)/*.o
	@cd $(BUILDDIR)/$(MODEL) && $(COMPILE) -shared -o lib$(ONAME)-O$(MODEL).so *.o



sourcechanges:
	@cd $(BUILDDIR) && sh $(ROOTDIR)/src/tools/make/sourcechanges.sh $(ROOTDIR)/bootstrap/$(PLATFORM)-$(ADRSIZE)$(ALIGNMENT)




RUNTEST = COMPILER=$(COMPILER) OBECOMP="$(OBECOMP) -O$(MODEL)" FLAVOUR=$(FLAVOUR) BRANCH=$(BRANCH) sh ./test.sh "$(INSTALLDIR)"

confidence:
	@printf "\n\n--- Confidence tests ---\n\n"
	cd src/test/confidence/hello;           $(RUNTEST)
	cd src/test/confidence/out;             $(RUNTEST)
	cd src/test/confidence/math;            $(RUNTEST)
	cd src/test/confidence/intsyntax;       $(RUNTEST)
	cd src/test/confidence/language;        $(RUNTEST)
	cd src/test/confidence/texts;           $(RUNTEST)
	cd src/test/confidence/math;            $(RUNTEST)
	cd src/test/confidence/library;         $(RUNTEST)
	cd src/test/confidence/lola;            $(RUNTEST)
	cd src/test/confidence/arrayassignment; $(RUNTEST)
	if [ "$(PLATFORM)" != "windows" ] ; then cd src/test/confidence/signal; $(RUNTEST); fi
	@printf "\n\n--- Confidence tests passed ---\n\n"
