# WorldGuard Grid Region Generator

A simple Python CLI tool to generate a `regions.yml` file for the Minecraft plugin **:contentReference[oaicite:0]{index=0}** based on a centered, symmetrical grid layout.

This script automatically creates cuboid regions arranged around the world center `(0, 0)` and exports them in valid YAML format, ready to be used in your WorldGuard configuration.

---

## ✨ Features

- Generates a centered grid of cuboid regions
- Enforces **odd** row and column counts (ensures a true center region)
- Automatically calculates region boundaries
- Supports custom region name prefixes
- Imports region flags from a simple `key=value` file
- Automatically sets a `greeting-title` per region
- Outputs clean YAML without anchors/aliases

---

## 📦 Requirements

- Python 3.7+
- PyYAML

Install dependencies:

```bash
pip install pyyaml
```

# Usage
python generate_regions.py \
  --rows 5 \
  --cols 5 \
  --size 100 \
  --gridSize 100 \
  --flags flags.txt \
  --priority 0 \
  --prefix plot \
  --output regions.yml

## Arguments
| Argument     | Required | Description                                            |
| ------------ | -------- | ------------------------------------------------------ |
| `--rows`     | ✅        | Number of rows (**must be odd**)                       |
| `--cols`     | ✅        | Number of columns (**must be odd**)                    |
| `--size`     | ✅        | Size (side length) of each region                      |
| `--gridSize` | ❌        | Distance between region centers (defaults to `--size`) |
| `--prefix`   | ❌        | Optional prefix for region names                       |
| `--flags`    | ✅        | Path to `key=value` flags file                         |
| `--priority` | ❌        | WorldGuard region priority (default: 0)                |
| `--output`   | ❌        | Output YAML filename (default: `regions.yml`)          |

# Grid behavior
- The grid is centered around (0, 0).
- Both rows and columns must be odd numbers.
- The exact center region will always be at: 0/0

Example:
For --rows 3 --cols 3:
|A-1|A-2|A-3|
|B-1|B-2|B-3|
|C-1|C-2|C-3|
The center region is: B-2

# Region naming
Without prefix: 
- A-1
- A-2
- B-1
- B-2
- etc.

With ```--prefix plot```:
- plot-A-1
- plot-A-2
- plot-B-1
- plot-B-2
- etc.

# Flags file format
The flags file must contain simple key=value pairs:
```ini
pvp=deny
mob-spawning=deny
build=allow
```
Blank lines and invalid lines are ignored.

Additionally, the script automatically sets:
```ini
greeting-title=<region-name>
```
if the greeting-title flag is set in any way in the file.

# Output structure
The generated YAML follows this structure:
```YAML
regions:
  plot-A-1:
    type: cuboid
    min:
      x: -150
      y: -64
      z: -150
    max:
      x: -50
      y: 320
      z: -50
    flags:
      pvp: deny
      greeting-title: plot-A-1
    priority: 0
```
- Y range is fixed from -64 to 320
- Regions are centered and symmetrically placed

# How it works
- Validates odd grid dimensions
- Calculates center offsets
- Generates region names (A–Z rows)
- Computes cuboid boundaries
- Loads flags from file
- Writes structured YAML without aliases