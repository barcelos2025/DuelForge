from PIL import Image
import numpy as np

def remove_black_background(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    data = np.array(img)
    
    # Define what is considered "black" (e.g., sum of RGB channels is low)
    # We'll use a simple threshold. If R+G+B < threshold, make it transparent.
    # Or better, use the brightness as alpha.
    
    red, green, blue, alpha = data.T
    
    # Calculate brightness
    brightness = (red.astype(float) + green.astype(float) + blue.astype(float)) / 3.0
    
    # Create a mask for black pixels (adjust threshold as needed, e.g., < 10)
    black_areas = (red < 15) & (green < 15) & (blue < 15)
    
    # Set alpha to 0 for black areas
    data[..., 3][black_areas.T] = 0
    
    # Save the result
    new_img = Image.fromarray(data)
    new_img.save(output_path, "PNG")
    print(f"Processed image saved to {output_path}")

if __name__ == "__main__":
    remove_black_background("assets/ui/icons/info_icon_original.jpg", "assets/ui/icons/info_icon.png")
