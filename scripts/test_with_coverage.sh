# brew install lcov
# run: ./test_with_coverage.sh

#!/bin/bash
set -e

flutter test test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
