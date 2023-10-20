# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


FROM registry.conarx.tech/containers/postgresql/edge as tsbuilder-base

ENV POSTGRESQL_VER=15.4

# Copy build patches
COPY patches build/patches

RUN set -eux; \
	true "Installing build dependencies"; \
	apk add --no-cache \
		build-base \
		cmake \
		git \
		patch \
		sudo \
		\
		openssl-dev \
		perl-dev \
		\
		diffutils \
		icu-data-full \
		perl-ipc-run \
		; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*

# Download tarballs
RUN set -eux; \
	mkdir -p build; \
	cd build; \
	# TimescaleDB
	git clone https://github.com/timescale/timescaledb.git



FROM tsbuilder-base as tsbuilder-2.12.2

ENV TIMESCALEDB_VER=2.12.2

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck



FROM tsbuilder-base as tsbuilder-2.12.1

ENV TIMESCALEDB_VER=2.12.1

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck






FROM tsbuilder-base as tsbuilder-2.12.0

ENV TIMESCALEDB_VER=2.12.0

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck






FROM tsbuilder-base as tsbuilder-2.11.2

ENV TIMESCALEDB_VER=2.11.2

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck




FROM tsbuilder-base as tsbuilder-2.11.1

ENV TIMESCALEDB_VER=2.11.1

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck



FROM tsbuilder-base as tsbuilder-2.10.1

ENV TIMESCALEDB_VER=2.10.1

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck




FROM tsbuilder-base as tsbuilder-2.9.3

ENV TIMESCALEDB_VER=2.9.3

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck



FROM tsbuilder-base as tsbuilder-2.9.2

ENV TIMESCALEDB_VER=2.9.2

# Checkout the right version
RUN set -eux; \
	cd build; \
	cd timescaledb; \
	git checkout "$TIMESCALEDB_VER"

# Build
RUN set -eux; \
	cd build; \
	cd "timescaledb"; \
# Patching
	# TODO: Patch can maybe be removed in future? 2.10.0+
	patch -p1 < ../patches/disable-partialize_finalize-test.patch; \
	patch -p1 < ../patches/timescaledb-2.9.3_disable-pg_join-test.patch; \
	mkdir build; \
	cd build; \
	\
	cmake ..; \
	make VERBOSE=1 -j$(nproc) -l 8; \
	make DESTDIR="/build/timescaledb-root" install; \
	# We need to install a second time to run timescaledb tests
	echo "Size before stripping..."; \
	du -hs /build/timescaledb-root

# Strip binaries
RUN set -eux; \
	cd build/timescaledb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded; \
	echo "Size after stripping..."; \
	du -hs /build/timescaledb-root

# Testing
RUN set -eux; \
	# Install TimescaleDB so we can run the installcheck tests below
	tar -c -C /build/timescaledb-root . | tar -x -C /; \
	# For testing we need to run the tests as a non-priv user
	cd build; \
	adduser -D pgsqltest; \
	chown -R pgsqltest:pgsqltest "timescaledb"; \
	cd "timescaledb"; \
	cd build; \
	# Test
	sudo -u pgsqltest make VERBOSE=1 -j1 -l8 installcheck




FROM registry.conarx.tech/containers/postgresql/edge


# NK: Versions are reverse ordered so newer ones overwrite data from older ones
COPY --from=tsbuilder-2.9.2 /build/timescaledb-root /
COPY --from=tsbuilder-2.9.3 /build/timescaledb-root /
COPY --from=tsbuilder-2.10.1 /build/timescaledb-root /
COPY --from=tsbuilder-2.11.1 /build/timescaledb-root /
COPY --from=tsbuilder-2.11.2 /build/timescaledb-root /
COPY --from=tsbuilder-2.12.0 /build/timescaledb-root /
COPY --from=tsbuilder-2.12.1 /build/timescaledb-root /
COPY --from=tsbuilder-2.12.2 /build/timescaledb-root /


ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   "edge"
LABEL org.opencontainers.image.base.name "registry.conarx.tech/containers/postgresql/edge"


RUN set -eux; \
	# Add timescaledb shared library and disable telemetry
	echo "# TimescaleDB" >> /usr/share/postgresql/postgresql.conf.sample; \
    echo "shared_preload_libraries = 'timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample; \
    echo "timescaledb.telemetry_level=off" >> /usr/share/postgresql/postgresql.conf.sample


# TimescaleDB
COPY usr/local/share/flexible-docker-containers/pre-init-tests.d/44-postgresql-timescaledb.sh /usr/local/share/flexible-docker-containers/pre-init-tests.d
COPY usr/local/share/flexible-docker-containers/tests.d/44-postgresql-timescaledb.sh /usr/local/share/flexible-docker-containers/tests.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Permissions"; \
	fdc set-perms
