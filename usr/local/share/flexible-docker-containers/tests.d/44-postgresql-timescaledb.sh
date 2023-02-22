#!/bin/bash
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


# Test creating a table
fdc_test_start postgresql "Test create timeseries table..."
if ! echo "CREATE TABLE testtimeseries (time TIMESTAMPTZ, temperature DOUBLE PRECISION NULL);" | psql --set=ON_ERROR_STOP=ON --host=127.0.0.1 --user="$POSTGRES_USER" "$POSTGRES_DATABASE"; then
    fdc_test_fail postgresql "Failed to create timeseries table 'testtimeseries'"
    false
fi
fdc_test_pass postgresql "Test timeseries table created"


# Test converting a table to a hypertable
fdc_test_start postgresql "Test timeseries table convert to hypertable..."
if ! echo "SELECT create_hypertable('testtimeseries', 'time');" | psql --set=ON_ERROR_STOP=ON --host=127.0.0.1 --user="$POSTGRES_USER" "$POSTGRES_DATABASE"; then
    fdc_test_fail postgresql "Failed to create table 'testtimeseries'"
    false
fi
fdc_test_pass postgresql "Test timeseries table converted to hypertable"


# Test inserting data
fdc_test_start postgresql "Test insert data in timeseries table..."
if ! echo "INSERT INTO testtimeseries (time, temperature) VALUES (NOW(), 30);" | psql --set=ON_ERROR_STOP=ON --host=127.0.0.1 --user="$POSTGRES_USER" "$POSTGRES_DATABASE"; then
    fdc_test_fail postgresql "Failed to insert data into test table 'testtimeseries'"
    false
fi
fdc_test_pass postgresql "Test data inserted into timeseries table"


# Test selecting data
fdc_test_start postgresql "Test SELECT on inserted timeseries data..."
if ! echo "SELECT * FROM testtimeseries;" | psql --set=ON_ERROR_STOP=ON --host=127.0.0.1 --user="$POSTGRES_USER" "$POSTGRES_DATABASE"; then
    fdc_test_fail postgresql "Failed to SELECT timeseries data"
    false
fi
fdc_test_pass postgresql "Test SELECT on inserted timeseries data worked"
