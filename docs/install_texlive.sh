#!/bin/bash

TL_MIRROR="https://texlive.info/CTAN/systems/texlive/tlnet"

mkdir "/tmp/texlive" 
cd "/tmp/texlive"
wget "$TL_MIRROR/install-tl-unx.tar.gz"
tar xzvf ./install-tl-unx.tar.gz
( \
    echo "selected_scheme scheme-minimal" && \
    echo "instopt_adjustpath 0" && \
    echo "tlpdbopt_install_docfiles 0" && \
    echo "tlpdbopt_install_srcfiles 0" && \
    echo "TEXDIR /opt/texlive/" && \
    echo "TEXMFLOCAL /opt/texlive/texmf-local" && \
    echo "TEXMFSYSCONFIG /opt/texlive/texmf-config" && \
    echo "TEXMFSYSVAR /opt/texlive/texmf-var" && \
    echo "TEXMFHOME ~/.texmf" \
) > "/tmp/texlive.profile"

"./install-tl-"*"/install-tl" --location "$TL_MIRROR" -profile "/tmp/texlive.profile" 

export PATH="${PATH}:/opt/texlive/bin/x86_64-linux"

tlmgr install scheme-small standalone luatex85 lualatex-math dvips dvisvgm

# rm -vf "/opt/texlive/install-tl" 
# rm -vf "/opt/texlive/install-tl.log"
# rm -vrf /tmp/*