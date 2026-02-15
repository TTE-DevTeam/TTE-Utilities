import argparse
import yaml
import string
import sys

class NoAliasDumper(yaml.SafeDumper):
    def ignore_aliases(self, data):
        return True


def load_flags(flag_file_path):
    """Load key=value pairs from a simple text file."""
    flags = {}
    with open(flag_file_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or "=" not in line:
                continue
            key, value = line.split("=", 1)
            flags[key.strip()] = value.strip()
    return flags


def alphabetical_labels(n):
    """Return A, B, C... for n rows."""
    if n > 26:
        raise ValueError("Row count cannot exceed 26 (A–Z).")
    return list(string.ascii_uppercase[:n])


def generate_regions(args):
    # Validate odd row/column counts
    if args.rows % 2 == 0 or args.cols % 2 == 0:
        print("ERROR: Row and column counts must be ODD.")
        sys.exit(1)

    half_rows = args.rows // 2
    half_cols = args.cols // 2

    row_labels = alphabetical_labels(args.rows)

    regions = {}

    # Loop through rows and columns centered around (0,0)
    for r in range(args.rows):
        row_label = row_labels[r]

        # Row offset from center
        row_offset = r - half_rows

        for c in range(args.cols):
            col_number = c + 1

            # Column offset from center
            col_offset = c - half_cols

            # Region name
            if args.prefix:
                region_name = f"{args.prefix}-{row_label}-{col_number}"
            else:
                region_name = f"{row_label}-{col_number}"

            # Compute center coordinates
            center_x = col_offset * args.gridSize
            center_z = row_offset * args.gridSize

            half = args.size // 2

            min_x = center_x - half
            max_x = center_x + half
            min_z = center_z - half
            max_z = center_z + half

            flags = load_flags(args.flags)
            flags["greeting-title"] = region_name

            regions[region_name] = {
                "type": "cuboid",
                "min": {"x": min_x, "y": -64, "z": min_z},
                "max": {"x": max_x, "y": 320, "z": max_z},
                "flags": flags,
                "priority": args.priority
            }

    # Write YAML
    with open(args.output, "w") as f:
        yaml.dump({"regions": regions}, f, sort_keys=False, Dumper=NoAliasDumper, indent=4)

    print(f"Generated {args.output} with {len(regions)} regions.")
    print(f"Center region is {row_labels[half_rows]}-{half_cols+1} at 0/0.")


def main():
    parser = argparse.ArgumentParser(
        description="Generate WorldGuard region YAML from a centered grid."
    )

    parser.add_argument("--rows", type=int, required=True,
                        help="Number of ROWS (must be odd).")
    parser.add_argument("--cols", type=int, required=True,
                        help="Number of COLUMNS (must be odd).")
    parser.add_argument("--size", type=int, required=True,
                        help="Region cell size (square side length).")
    parser.add_argument("--gridSize", type=int, required=False,
                        help="Sizing of each grid cell.")
    parser.add_argument("--prefix", type=str, default="",
                        help="Optional prefix for region names.")
    parser.add_argument("--flags", type=str, required=True,
                        help="Path to key=value flag file.")
    parser.add_argument("--priority", type=int, default=0,
                        help="Region priority.")
    parser.add_argument("--output", type=str, default="regions.yml",
                        help="Output YAML file name.")

    args = parser.parse_args()

    if not args.gridSize:
        args.gridSize = args.size

    generate_regions(args)


if __name__ == "__main__":
    main()
