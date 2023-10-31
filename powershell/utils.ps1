
#** Init **#

# ensure packages are installed
Ensure-Pkg cargo rust
$null = cargo binstall --help
if (-NOT($?)) {
  Write-Error "[ERROR]: cargo-binstall not found."
  exit 2
}

Write-Host "[INFO]: installing rust binaries"
# cargo binstall bat -y 
# cargo binstall ripgrep -y 
# cargo binstall fd-find -y 
# cargo binstall du-dust -y 
# cargo binstall git-delta -y 

if ((Confirm "Do you want to install Rust Coreutils?") -eq 1) {
  Write-Host "[WARN]: skipping Coreutils install"
  exit 0
}

# install coreutils
Write-Host "[INFO]: cloning coreutils"
if (-NOT(Test-Path coreutils)) {
  git clone https://github.com/uutils/coreutils
}

Write-Host "[INFO]: building coreutils"
cd coreutils
cargo build --release --features windows

Write-Host "[INFO]: installing coreutils"
cargo install --path . --locked

Write-Host "[INFO]: cleaning up build-dir"
$null = Remove-Item -LiteralPath coreutils -Force -Recurse
