def read_p2_pgm(file_path):
    with open(file_path, 'r') as f:
        # Read magic number
        magic_number = f.readline().strip()
        if magic_number != 'P2':
            raise ValueError('Not a valid P2 PGM file')

        # Skip comments
        line = f.readline()
        while line.startswith('#'):
            line = f.readline()

        # Read width and height
        while line.strip() == '':
            line = f.readline()
        width, height = map(int, line.strip().split())

        # Read max gray value
        max_gray = int(f.readline().strip())
        if max_gray > 127:
            raise ValueError('Maximum gray value must not exceed 127')

        # Read pixel data
        pixels = []
        for line in f:
            if line.startswith('#') or line.strip() == '':
                continue
            pixels.extend(map(int, line.strip().split()))

    return width, height, max_gray, pixels

def write_p5_pgm(output_path, width, height, max_gray, pixels):
    with open(output_path, 'wb') as f:
        # Write header
        f.write(b'P5\n')
        f.write(f'{width} {height}\n'.encode())
        f.write(f'{max_gray}\n'.encode())

        # Write binary pixel data
        if max_gray < 256:
            pixel_bytes = bytearray(pixels)
        else:
            # 2-byte per pixel (big-endian)
            pixel_bytes = bytearray()
            for pix in pixels:
                pixel_bytes.append((pix >> 8) & 0xFF)
                pixel_bytes.append(pix & 0xFF)

        f.write(pixel_bytes)

def convert_p2_to_p5(input_path, output_path):
    width, height, max_gray, pixels = read_p2_pgm(input_path)
    write_p5_pgm(output_path, width, height, max_gray, pixels)
    print(f'Converted {input_path} to {output_path} as P5 format.')

# Example usage:
if __name__ == '__main__':
    import sys
    if len(sys.argv) != 3:
        print("Usage: python p2_to_p5_converter.py input.pgm output.pgm")
    else:
        convert_p2_to_p5(sys.argv[1], sys.argv[2])
