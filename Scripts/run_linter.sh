if which swiftlint >/dev/null; then
  swiftlint lint --config .swiftlint.yml
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
