# Dev project workflow on this NixOS config

This setup keeps the base system small and puts language versions inside each
project. The system provides `direnv` for automatic project environments, and
Home Manager provides `mise` as a convenience tool for non-Nix projects.

## Recommended workflow

1. Create or enter a project.

   ```sh
   mkdir my-app
   cd my-app
   git init
   ```

2. Add a project `flake.nix`.

   ```nix
   {
     description = "my-app development environment";

     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

     outputs = { nixpkgs, ... }:
       let
         system = "x86_64-linux";
         pkgs = nixpkgs.legacyPackages.${system};
       in {
         devShells.${system}.default = pkgs.mkShell {
           packages = with pkgs; [
             python312
             uv
             go
             jdk21
             nodejs_22
             rustc
             cargo
             ghc
             cabal-install
           ];
         };
       };
   }
   ```

3. Enter the environment manually.

   ```sh
   nix develop
   ```

   Check the selected tools:

   ```sh
   python --version
   uv --version
   go version
   java --version
   node --version
   npm --version
   rustc --version
   cargo --version
   ghc --version
   cabal --version
   ```

4. Enable automatic loading with `direnv`.

   Create `.envrc`:

   ```sh
   use flake
   ```

   Allow it once:

   ```sh
   direnv allow
   ```

   After this, entering the directory loads the project tools automatically.
   Leaving the directory unloads them.

5. Commit the environment files.

   ```sh
   git add flake.nix flake.lock .envrc
   git commit -m "Add Nix development environment"
   ```

## Dependency management

Use Nix for the toolchain and each language's normal project files for
application dependencies.

Python:

```sh
uv init
uv add requests
```

Node:

```sh
npm init -y
npm install express
```

Go:

```sh
go mod init example.com/my-app
go get github.com/gin-gonic/gin
```

Java:

```sh
gradle init
```

Rust:

```sh
cargo init
cargo add anyhow
```

Haskell:

```sh
cabal init
cabal build
```

## Changing versions

Edit the package names in `flake.nix`, then reload the environment.

Examples:

```nix
python313
nodejs_24
jdk17
jdk21
```

Reload:

```sh
direnv reload
```

or:

```sh
nix develop
```

## When to use mise

Prefer a project `flake.nix` when the project is yours or when reproducibility
matters.

Use `mise` when:

- a project already uses `.tool-versions` or `mise.toml`
- you need to work quickly in a non-Nix project
- an upstream project expects common version-manager behavior

Examples:

```sh
mise use node@22
mise use python@3.12
mise use java@21
```

For long-lived projects, move those versions into `flake.nix` when practical.

## Verifying this NixOS config

Before switching the system after config changes, run:

```sh
nix flake check
```

Then switch:

```sh
sudo nixos-rebuild switch --flake .#nixos
```

Rollback if needed:

```sh
sudo nixos-rebuild switch --rollback
```
