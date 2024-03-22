REP_BIN = bin
REP_SRC = src
REP_OBJ = obj
REP_DOC = doc
REP_LIB = lib
NOM_BIN = dignrush
NOM_PROG = dignrush.sh
REPS = $(REP_BIN) $(REP_SRC) $(REP_OBJ) $(REP_DOC) $(REP_LIB)

REP_SDL = $(REP_LIB)/SDL2
REP_SDLLIB = $(REP_SDL)/lib
REP_SDLINC = $(REP_SDL)/include
REP_SDLBIN = $(REP_SDL)/bin
REP_SDLIMG = $(REP_LIB)/SDL2_image
REP_SDLIMGLIB = $(REP_SDLIMG)/lib
REP_SDLIMGINC = $(REP_SDLIMG)/include
REP_SDLTTF = $(REP_LIB)/SDL2_ttf
REP_SDLTTFLIB = $(REP_SDLTTF)/lib
REP_SDLTTFINC = $(REP_SDLTTF)/include

SOURCES = $(wildcard $(REP_SRC)/*.c)
OBJETS = $(SOURCES:$(REP_SRC)/%.c=$(REP_OBJ)/%.o)
ENTETES = $(REP_SRC)/constantes.h
LIB_FLAGS = `sdl2-config --libs --cflags` -lSDL2_image -lSDL2_ttf -L$(REP_SDLLIB) -L$(REP_SDLIMGLIB) -L$(REP_SDLTTFLIB)
WARNING_FLAGS = -Wall -Wextra -Wconversion -Wno-float-conversion -Wno-sign-conversion #-fanalyzer -fsanitize=undefined #-fsanitize=address
SOURCES_TEX = $(wildcard $(REP_DOC)/*.tex)
DOXYFILE = $(REP_DOC)/Doxyfile
INCLUDES = -I$(REP_SRC) -I$(REP_SDLINC) -I$(REP_SDLIMGINC) -I$(REP_SDLTTFINC)

# vérifie présence de compilateurs TeX
TECTONIC := $(shell command -v tectonic 2> /dev/null)
XELATEX := $(shell command -v xelatex 2> /dev/null)

.PHONY = docs docs_tex docs_doxy reps clean remove all
.SILENT = reps

$(NOM_BIN) : $(OBJETS)
	@echo "\n>>>> Compilation du jeu…\n"
	gcc -o $(REP_BIN)/$@ $^ $(LIB_FLAGS) $(INCLUDES) $(WARNING_FLAGS)
$(OBJETS) : $(REP_OBJ)/%.o: $(REP_SRC)/%.c $(ENTETES)
	gcc -o $@ -c $< $(WARNING_FLAGS)
docs : docs_tex docs_doxy
docs_tex: $(SOURCES_TEX)
	@echo "\n>>>> Compilation des fichiers LaTeX…\n"
ifdef XELATEX
	# se déplacer dans doc/ pour compiler doc/*.tex, le doc/ étant retiré par subst
	# « -interaction batchmode » pour limiter la loquacité de xelatex
	cd $(REP_DOC) && xelatex -interaction batchmode $(subst $(REP_DOC)/, , $<)
else ifdef TECTONIC
	# compilateur TeX alternatif utilisé chez Matthieu
	tectonic $<
else
	@echo "pas de compilateur TeX trouvé, docs .tex non compilées"
endif
docs_doxy: $(DOXYFILE)
	@echo "\n>>>> Génération de la doc Doxygen…\n"
	doxygen $<
reps :
	mkdir -p $(REPS)

clean :
	rm -f $(REP_OBJ)/*
remove : clean
	rm $(REP_BIN)/$(NOM_BIN)

all : reps $(NOM_BIN) docs

exe : all
	@echo "\n>>>> Lancement du jeu…\n"
	$(REP_BIN)/$(NOM_PROG)
