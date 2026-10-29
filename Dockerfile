FROM debian:bookworm

ARG handy_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG HANDY_RELEASE
ARG LIBC_MIN
ARG LIBSTDCXX_MIN

RUN mkdir -p /output/DEBIAN

# Upstream's .deb, extracted by build_debian.sh: usr/bin/handy, its private
# libraries and resources in usr/lib/Handy (found through the binary's
# RUNPATH, so the directory keeps upstream's name), icons and the .desktop file
COPY ${HANDY_RELEASE}/usr /output/usr/
# Upstream leaves Categories empty, which files the launcher under "Other"
RUN sed -i -e "s/^Categories=.*/Categories=Utility;Accessibility;AudioVideo;/" \
           -e "s/^Comment=.*/Comment=Offline speech-to-text/" \
           /output/usr/share/applications/Handy.desktop
RUN mkdir -p /output/usr/share/doc/handy

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/handy/
COPY output/changelog.Debian /output/usr/share/doc/handy/
COPY output/README.md /output/usr/share/doc/handy/

RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/handy/changelog.Debian
RUN sed -i "s/handy_VERSION/$handy_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control
RUN sed -i "s/LIBC_MIN/$LIBC_MIN/" /output/DEBIAN/control
RUN sed -i "s/LIBSTDCXX_MIN/$LIBSTDCXX_MIN/" /output/DEBIAN/control

RUN dpkg-deb -Zxz --build /output /handy_${FULL_VERSION}.deb
