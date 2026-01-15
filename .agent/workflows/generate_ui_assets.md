---
description: Generate UI assets and automatically fix transparency issues
---

1. **Generate Images**: Use the `generate_image` tool to create the requested assets based on the prompts in `docs/ASSET_GENERATION_SCRIPT.md` or user request.

2. **Organize Assets**: Move the generated images to their correct directories (e.g., `assets/ui/buttons/`, `assets/ui/9slice/`).

3. **Fix Transparency**: Run the transparency fix script to ensure clean alpha channels.
   // turbo
   ```powershell
   python scripts/fix_transparency.py
   ```

4. **Trim Assets**: Remove excess transparent borders.
   // turbo
   ```powershell
   python scripts/trim_assets.py
   ```

5. **Verify**: Check `lib/features/debug/assets_showcase_screen.dart` or the relevant UI to ensure assets look correct.
