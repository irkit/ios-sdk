
OUT = connect.png learn-ir-signal.png send-ir-signal.png ir-state.png one-create-icon.png

all: $(OUT)

.SUFFIXES: .msc .png .gv

.msc.png:
	mscgen -T png -i $<

.gv.png:
	dot -Tpng $< -o $@
