REP_BIN = bin
REP_SRC = src
REP_OBJ = obj
REP_DOC = doc
REP_LIB = lib
NOM_BIN = dignrush
NOM_PROG = dignrush.sh
REPS = $(REP_BIN) $(REP_SRC) $(REP_OBJ) $(REP_DOC) $(REP_LIB)

REP_SDL = $(REP_LIB)/SDL2
REP_SDLINC = $(REP_SDL)/include
REP_SDLBIN = $(REP_SDL)/bin

SYSTEME = $(shell uname)
ifeq ($(SYSTEME), Linux)
	# $(info flags de compilation pour linux…)
	LIB_FLAGS = `$(REP_SDLBIN)/sdl2-config --libs --cflags` -lSDL2_image -lSDL2_ttf -lSDL2_mixer
	INCLUDES = -I$(REP_SRC) -I$(REP_SDLINC)
else ifeq ($(SYSTEME), Darwin)
	# $(info flags de compilation pour mac…)
	LIB_FLAGS = -lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer
	INCLUDES = -I$(REP_SRC)
endif

SOURCES = $(wildcard $(REP_SRC)/*.c)
OBJETS = $(SOURCES:$(REP_SRC)/%.c=$(REP_OBJ)/%.o)
ENTETES = $(REP_SRC)/constantes.h
WARNING_FLAGS = -Wall -Wextra # -Wconversion -Wno-float-conversion -Wno-sign-conversion #-fanalyzer -fsanitize=undefined #-fsanitize=address
DEBUG_FLAGS = 

SOURCES_TEX = $(wildcard $(REP_DOC)/*.tex)
DOXYFILE = $(REP_DOC)/Doxyfile

OUTIL_MESSAGE = outils/bannière.sh

# vérifie présence de compilateurs TeX
TECTONIC := $(shell command -v tectonic 2> /dev/null)
XELATEX := $(shell command -v xelatex 2> /dev/null)

.PHONY = docs docs_tex docs_doxy reps clean remove all
.SILENT = reps

$(NOM_BIN) : $(OBJETS)
	@ $(OUTIL_MESSAGE) Compilation du jeu…
	gcc -o $(REP_BIN)/$@ $^ $(LIB_FLAGS) $(INCLUDES) $(WARNING_FLAGS) $(DEBUG_FLAGS)
$(OBJETS) : $(REP_OBJ)/%.o: $(REP_SRC)/%.c $(ENTETES)
	gcc -o $@ -c $< $(WARNING_FLAGS) $(DEBUG_FLAGS) $(INCLUDES)

docs : docs_tex docs_doxy
docs_tex: $(SOURCES_TEX)
	@ $(OUTIL_MESSAGE) Compilation des fichiers LaTeX…
ifdef XELATEX
	@# se déplacer dans doc/ pour compiler doc/*.tex, le doc/ étant retiré par subst
	@# « -interaction batchmode » pour limiter la loquacité de xelatex
	cd $(REP_DOC) && xelatex -interaction batchmode $(subst $(REP_DOC)/, , $<)
else ifdef TECTONIC
	@# compilateur TeX alternatif utilisé chez Matthieu
	tectonic $<
else
	@echo "pas de compilateur TeX trouvé, docs .tex non compilées"
endif
docs_doxy: $(DOXYFILE)
	@ $(OUTIL_MESSAGE) Génération de la doc Doxygen…
	cd $(REP_DOC) && doxygen $(subst $(REP_DOC)/, , $<)

reps :
	mkdir -p $(REPS)

clean :
	rm -f $(REP_OBJ)/*
remove : clean
	rm $(REP_BIN)/$(NOM_BIN)

all : reps $(NOM_BIN) docs

jeu : $(NOM_BIN)

debug : DEBUG_FLAGS += -g
debug : $(NOM_BIN)

exe : jeu
	@ $(OUTIL_MESSAGE) Lancement du jeu…
	$(REP_BIN)/$(NOM_PROG)
