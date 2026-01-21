# Developer User Setup

## Automatic Setup (In Code)
The application is currently configured (`AuthService.dart`) to automatically ensure a test user exists when running in `kDebugMode`.

**Credentials:**
*   **Email**: `barcelos32@gmail.com`
*   **Password**: `teste` (or `teste123` if the project enforces 6+ chars)
*   **Nickname**: `barcelos32`

## Dev Bypass Mode
The app also has a `_enableDevBypass` flag set to `true`.
*   **Behavior**: If no session exists, it automatically logs in as a mock user `dev@duelforge.local` without hitting the backend.
*   **Note**: This mock user (`dev_user_001`) might not have data in Supabase unless manually inserted.

## Manual Setup (Super Admin)
If you want to create a powerful admin user manually in Supabase:

1.  **Go to Supabase Dashboard** -> Authentication -> Users.
2.  **Add User**:
    *   Email: `admin@duelforge.local`
    *   Password: `adminpassword123`
    *   Auto-confirm email: Yes

3.  **Run SQL to Boost Profile**:
    ```sql
    -- Replace 'USER_UUID_HERE' with the actual UUID
    INSERT INTO public.profiles (id, nickname, country_iso2, level, coins, rubies, trophies)
    VALUES (
        'USER_UUID_HERE', 
        'Odin', 
        'NO', 
        13, 
        999999, 
        999999, 
        5000
    )
    ON CONFLICT (id) DO UPDATE 
    SET coins = 999999, rubies = 999999, level = 13;
    ```
